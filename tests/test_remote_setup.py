"""Verify remote setup without installing system packages or changing accounts."""
import os
from pathlib import Path
import shutil
import subprocess
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[1]


class RemoteSetupTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory(prefix="remote-dotfiles-")
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name).resolve()
        self.bin = self.root / "bin"
        self.bin.mkdir()
        self.log = self.root / "calls"
        self.env = dict(os.environ, PATH=f"{self.bin}:{os.environ['PATH']}", DOTFILES_TEST_LOG=str(self.log))

    def stub(self, name, body):
        path = self.bin / name
        path.write_text("#!/bin/sh\n" + body + "\n")
        path.chmod(0o755)

    def linux(self, arch="x86_64"):
        self.stub("uname", f'if [ "$1" = "-m" ]; then echo {arch}; else echo Linux; fi')

    def run_script(self, path, *args):
        return subprocess.run(["/bin/bash", str(path), *map(str, args)], env=self.env, capture_output=True, text=True)

    def test_setup_rejects_non_linux_before_installing_anything(self):
        self.stub("uname", "echo UnsupportedOS")
        result = self.run_script(ROOT / "setup.sh")
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("Linux servers", result.stderr)
        self.assertFalse(self.log.exists())

    def test_linux_setup_runs_dependencies_before_linking(self):
        self.linux()
        repo = self.root / "repo"
        (repo / "install").mkdir(parents=True)
        shutil.copy2(ROOT / "setup.sh", repo / "setup.sh")
        for name in ("apt", "neovim", "stow"):
            path = repo / "install" / f"{name}.sh"
            path.write_text(f'#!/bin/sh\necho {name} >> "$DOTFILES_TEST_LOG"\n')
            path.chmod(0o755)
        result = self.run_script(repo / "setup.sh")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(self.log.read_text().splitlines(), ["apt", "neovim", "stow"])

    def test_apt_installs_cli_dependencies_without_changing_login_shell(self):
        self.linux()
        self.stub("id", "echo 0")
        self.stub("apt-get", 'echo "apt-get $*" >> "$DOTFILES_TEST_LOG"')
        self.stub("chsh", 'echo UNEXPECTED_CHSH >> "$DOTFILES_TEST_LOG"; exit 1')
        result = self.run_script(ROOT / "install/apt.sh")
        self.assertEqual(result.returncode, 0, result.stderr)
        calls = self.log.read_text()
        self.assertIn("apt-get update", calls)
        self.assertIn("--no-install-recommends", calls)
        self.assertIn("clangd", calls)
        self.assertIn("python3-pylsp", calls)
        self.assertNotIn("UNEXPECTED_CHSH", calls)

    def test_existing_neovim_entry_is_preserved_and_repeat_is_idempotent(self):
        self.linux()
        prefix = self.root / "local"
        binary = prefix / "opt/nvim-v0.11.5/bin/nvim"
        binary.parent.mkdir(parents=True)
        binary.write_text("#!/bin/sh\necho 'NVIM v0.11.5'\n")
        binary.chmod(0o755)
        (prefix / "bin").mkdir()
        (prefix / "bin/nvim").write_text("existing executable")
        self.stub("curl", "exit 99")
        for _ in range(2):
            result = self.run_script(ROOT / "install/neovim.sh", prefix)
            self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual((prefix / "bin/nvim").resolve(), binary)
        backups = list((prefix / "bin").glob("nvim.backup.*"))
        self.assertEqual(len(backups), 1)
        self.assertEqual(backups[0].read_text(), "existing executable")

    @unittest.skipUnless(shutil.which("sha256sum"), "sha256sum is required")
    def test_corrupt_neovim_download_does_not_change_existing_entry(self):
        self.linux()
        prefix = self.root / "local"
        (prefix / "bin").mkdir(parents=True)
        (prefix / "bin/nvim").write_text("keep existing")
        self.stub("curl", 'while [ "$#" -gt 0 ]; do if [ "$1" = "--output" ]; then shift; printf corrupt > "$1"; exit 0; fi; shift; done; exit 1')
        result = self.run_script(ROOT / "install/neovim.sh", prefix)
        self.assertNotEqual(result.returncode, 0)
        self.assertEqual((prefix / "bin/nvim").read_text(), "keep existing")
        self.assertFalse((prefix / "opt").exists())

    @unittest.skipUnless(shutil.which("zsh"), "zsh is required")
    def test_shell_preserves_forwarded_agent_terminal_and_locale(self):
        # Exclude the user's optional local additions from the isolated check.
        code = (ROOT / "stow/zsh/.zshrc").read_text().split('[[ ! -f "$HOME/.zshrc.local" ]]')[0]
        code += '\nprint -r -- "STATE:$SSH_AUTH_SOCK:$TERM:$LANG:$LC_ALL"\n'
        env = dict(self.env, PATH=f"{self.bin}:/usr/bin:/bin", ZDOTDIR=str(self.root),
                   SSH_AUTH_SOCK="/forwarded/agent", TERM="negotiated-terminal", LANG="C", LC_ALL="C")
        self.stub("ssh-agent", "exit 99")
        result = subprocess.run([shutil.which("zsh"), "-f", "-c", code], env=env, capture_output=True, text=True)
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(result.stderr, "")
        self.assertIn("STATE:/forwarded/agent:negotiated-terminal:C:C", result.stdout)


if __name__ == "__main__":
    unittest.main()
