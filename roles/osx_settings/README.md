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
requires an array, and Finder launched without ever opening a window.

Stick to scalar keys when using `osx_defaults`. Nested values go through
`plutil -replace -json`, which maps JSON numbers to `<integer>` and JSON arrays
to `<array>`, as the toolbar task now does.

## Finder toolbar

The toolbar layout lives in `osx_finder_toolbar` (`defaults/main.yml`) and is
applied by the `Configure Finder toolbar` block. Writes go through
`defaults export` / `defaults import` rather than editing
`~/Library/Preferences/com.apple.finder.plist` directly, because `cfprefsd`
caches that file in memory and silently overwrites in-place edits. Idempotence
comes from comparing the live value against the desired one and skipping the
write when they already match.

Toolbar item identifiers are undocumented, vary between macOS releases, and
Finder silently drops any it does not recognise. So capture the value rather
than hand-writing it: customise the toolbar via **View > Customize Toolbar**,
then read back what Finder wrote and paste it into `defaults/main.yml`.

```bash
defaults read com.apple.finder "NSToolbar Configuration Browser"
```

If Finder ever fails to open a window again, clear the key and restart it:

```bash
defaults delete com.apple.finder "NSToolbar Configuration Browser" && killall Finder
```

## Verification

For any preference managed by this role, verify with:

```bash
defaults read <domain> <key>
```

## References

- [Ты используешь Finder неправильно. 10 настроек которые это исправят (You're using Finder wrong. 10 settings to fix it)](https://www.youtube.com/watch?v=CzLpFft-JFA)
