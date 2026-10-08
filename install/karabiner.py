#!/usr/bin/env python3
"""Keep Karabiner's mutable configuration independent of Git branch changes."""
import argparse
import json
import os
from pathlib import Path
import shutil
import tempfile


def configure(source, target):
    target.parent.mkdir(parents=True, exist_ok=True)
    if target.is_symlink():
        backup = Path(tempfile.mkdtemp(prefix='karabiner.backup.', dir=target.parent))
        if target.is_dir():
            shutil.copytree(target, backup, dirs_exist_ok=True)
        # Remove the link only after preserving its contents.
        target.unlink()
        target.mkdir()
        shutil.copytree(backup, target, dirs_exist_ok=True)
        print(f'Previous configuration preserved in {backup}')
    elif target.exists() and not target.is_dir():
        raise ValueError(f'Expected a directory: {target}')
    else:
        target.mkdir(exist_ok=True)

    config = target / 'karabiner.json'
    content = config.read_text() if config.exists() else (source / 'karabiner.json').read_text()
    data = json.loads(content)
    profiles = data.setdefault('profiles', [])
    if not profiles:
        profiles.append({'name': 'Default profile', 'selected': True})
    mapping = {'from': {'key_code': 'caps_lock'}, 'to': [{'key_code': 'escape'}]}
    for profile in profiles:
        rules = profile.setdefault('simple_modifications', [])
        rules[:] = [rule for rule in rules if rule.get('from', {}).get('key_code') != 'caps_lock']
        rules.append(mapping)
        # Device-specific rules take precedence over the profile-wide rule.
        for device in profile.get('devices', []):
            for rule in device.get('simple_modifications', []):
                if rule.get('from', {}).get('key_code') == 'caps_lock':
                    rule['to'] = [{'key_code': 'escape'}]

    if config.is_symlink() or not config.exists() or json.loads(content) != data:
        if config.exists():
            backup = Path(tempfile.mkdtemp(prefix='karabiner.config-backup.', dir=target.parent))
            shutil.copy2(config, backup / 'karabiner.json')
            print(f'Previous JSON preserved in {backup}')
        fd, temporary = tempfile.mkstemp(prefix='.karabiner-', dir=target)
        try:
            with os.fdopen(fd, 'w') as stream:
                json.dump(data, stream, indent=2)
                stream.write('\n')
            os.replace(temporary, config)
        finally:
            if os.path.exists(temporary):
                os.unlink(temporary)
    print(f'Caps Lock maps to Escape for all keyboards: {config}')


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--source', type=Path, required=True)
    parser.add_argument('--target', type=Path, required=True)
    arguments = parser.parse_args()
    configure(arguments.source, arguments.target)
