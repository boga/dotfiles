# osx_settings

Configures macOS system preferences via `defaults` (through the
`community.general.osx_defaults` module) for the currently logged-in user.
Runs without `become: true` so preferences apply to the invoking user's
domain, not root.

## Requirements

```bash
ansible-galaxy collection install community.general
```

## What it does

Applies macOS system preferences via `community.general.osx_defaults`. Each
task that touches a Finder default notifies the `Restart Finder` handler
(`handlers/main.yml`), which runs `killall Finder` once at the end of the
play only if at least one preference actually changed, so the role stays
idempotent.

## Verification

For any preference managed by this role, verify with:

```bash
defaults read <domain> <key>
```

## References

- [Ты используешь Finder неправильно. 10 настроек которые это исправят (You're using Finder wrong. 10 settings to fix it)](https://www.youtube.com/watch?v=CzLpFft-JFA)
