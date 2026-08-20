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

## Pitfall: nested values and `type: dict`

Do not manage nested preferences with `community.general.osx_defaults`. Its
`_dict_value_to_args` helper types only `int` and `float`, then falls through to
`-string str(val)` for every other value. Lists and nested dicts are written as
Python `repr()` strings rather than plist `<array>` / `<dict>` nodes.

This broke Finder once already: `NSToolbar Configuration Browser` was written
with `TB Item Identifiers` as a string, Finder's `NSToolbar` deserializer
requires an array, and Finder launched without ever opening a window. The role
now deletes that key instead of setting it.

Stick to scalar keys here. If a nested value genuinely must be managed, write it
with `plutil -replace <key> -xml '<dict>...</dict>'` so the types survive, and
guard idempotence with an explicit `changed_when` comparison.

## Verification

For any preference managed by this role, verify with:

```bash
defaults read <domain> <key>
```

## References

- [Ты используешь Finder неправильно. 10 настроек которые это исправят (You're using Finder wrong. 10 settings to fix it)](https://www.youtube.com/watch?v=CzLpFft-JFA)
