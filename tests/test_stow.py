"""Exercise the real Stow installer against disposable home directories."""

import os
from pathlib import Path
import shutil
import subprocess
import tempfile
import unittest


ROOT = Path(__file__).resolve().parents[1]


@unittest.skipUnless(shutil.which("stow"), "GNU Stow is required")
class StowMigrationTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory(prefix="dotfiles-stow-")
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name).resolve()
        self.repo = self.root / "repository with spaces"
        self.target = self.root / "target with spaces"
        self.target.mkdir()
        shutil.copytree(ROOT / "stow", self.repo / "stow")
        (self.repo / "install").mkdir()
        shutil.copy2(ROOT / "install/stow.sh", self.repo / "install/stow.sh")

    def run_installer(self, *args, success=True):
        result = subprocess.run(
            ["/bin/bash", str(self.repo / "install/stow.sh"),
             "--target", str(self.target), *args],
            capture_output=True, text=True,
        )
        if success:
            self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        else:
            self.assertNotEqual(result.returncode, 0)
        return result

    def assert_link(self, relative, package_relative):
        dest = self.target / relative
        self.assertTrue(dest.is_symlink(), relative)
        self.assertEqual(dest.resolve(), self.repo / "stow" / package_relative)

    def test_fresh_install_and_repeat_keep_runtime_files_outside_repo(self):
        self.run_installer()
        self.assert_link(".zshrc", "zsh/.zshrc")
        self.assert_link(".config/tmux/tmux.conf", "tmux/.config/tmux/tmux.conf")
        self.assertFalse((self.target / ".config/nvim").is_symlink())
        runtime = self.target / ".config/tmux/plugins/local-state"
        runtime.parent.mkdir(parents=True)
        runtime.write_text("keep me")
        self.run_installer()
        self.assertEqual(runtime.read_text(), "keep me")
        self.assertFalse((self.repo / "stow/tmux/.config/tmux/plugins").exists())
        self.assertEqual(list(self.target.glob(".dotfiles-backup.*")), [])

    def test_legacy_links_are_migrated_and_tmux_plugins_preserved(self):
        legacy = {
            ".zshrc": "config/zshrc",
            ".config/nvim": "config/nvim",
            ".config/tmux/tmux.conf": "config/tmux/tmux.conf",
        }
        for dest, source in legacy.items():
            path = self.target / dest
            path.parent.mkdir(parents=True, exist_ok=True)
            path.symlink_to(self.repo / source)
        runtime = self.target / ".config/tmux/plugins/local-state"
        runtime.parent.mkdir(parents=True)
        runtime.write_text("keep me")
        self.run_installer()
        self.assert_link(".config/nvim/init.lua", "nvim/.config/nvim/init.lua")
        self.assert_link(".zshrc", "zsh/.zshrc")
        self.assertEqual(runtime.read_text(), "keep me")
        self.assertEqual(list(self.target.glob(".dotfiles-backup.*")), [])

    def test_conflicts_are_backed_up_without_touching_unmanaged_files(self):
        (self.target / ".zshrc").write_text("my shell config")
        nvim = self.target / ".config/nvim"
        nvim.mkdir(parents=True)
        (nvim / "init.lua").write_text("my editor config")
        (nvim / "unmanaged.txt").write_text("leave alone")
        self.run_installer()
        backups = list(self.target.glob(".dotfiles-backup.*"))
        self.assertEqual(len(backups), 1)
        self.assertEqual((backups[0] / ".zshrc").read_text(), "my shell config")
        self.assertEqual((backups[0] / ".config/nvim/init.lua").read_text(), "my editor config")
        self.assertEqual((nvim / "unmanaged.txt").read_text(), "leave alone")
        self.run_installer()
        self.assertEqual(list(self.target.glob(".dotfiles-backup.*")), backups)

    def test_dry_run_leaves_conflicts_and_legacy_links_untouched(self):
        (self.target / ".zshrc").write_text("preserve")
        (self.target / ".config").mkdir()
        link = self.target / ".config/nvim"
        link.symlink_to(self.repo / "config/nvim")
        self.run_installer("--dry-run")
        self.assertEqual((self.target / ".zshrc").read_text(), "preserve")
        self.assertEqual(os.readlink(link), str(self.repo / "config/nvim"))
        self.assertEqual(list(self.target.glob(".dotfiles-backup.*")), [])
        self.assertFalse((self.target / ".config/tmux").exists())

    def test_shared_config_file_is_backed_up_once(self):
        (self.target / ".config").write_text("unexpected file")
        self.run_installer()
        backups = list(self.target.glob(".dotfiles-backup.*"))
        self.assertEqual(len(backups), 1)
        self.assertEqual((backups[0] / ".config").read_text(), "unexpected file")
        self.assert_link(".config/tmux/tmux.conf", "tmux/.config/tmux/tmux.conf")

    def test_shared_config_symlink_is_preserved_on_failure(self):
        external = self.root / "external-config"
        external.mkdir()
        (external / "keep").write_text("keep")
        (self.target / ".config").symlink_to(external)
        (self.target / ".zshrc").write_text("keep shell")
        self.run_installer(success=False)
        self.assertTrue((self.target / ".config").is_symlink())
        self.assertEqual((external / "keep").read_text(), "keep")
        self.assertEqual((self.target / ".zshrc").read_text(), "keep shell")
        self.assertEqual(list(self.target.glob(".dotfiles-backup.*")), [])


if __name__ == "__main__":
    unittest.main()
