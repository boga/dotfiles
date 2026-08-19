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

Applies macOS system preferences via `community.general.osx_defaults`,
restarting the affected app only when a preference actually changed, so
each task stays idempotent.

## Verification

For any preference managed by this role, verify with:

```bash
defaults read <domain> <key>
```
