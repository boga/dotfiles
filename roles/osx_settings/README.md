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

This broke Finder twice: `NSToolbar Configuration Browser` was written with
`TB Item Identifiers` as a string, Finder's `NSToolbar` deserializer requires an
array, and Finder launched without ever opening a window.

The second time was a deliberate reproduction. With the live value perturbed by a
single item, the task reported changed and rewrote both nested lists as strings,
leaving the surrounding scalars as `<integer>`. Two details make this hard to
catch: the corrupted plist still passes `plutil -lint`, and the module compares
before it writes, so the task is silently well-behaved on any machine whose live
value already matches. It only misfires when a write is genuinely required —
which is exactly what provisioning a new machine does.

`plutil -replace -json` writes such keys correctly, mapping JSON numbers to
`<integer>` and JSON arrays to `<array>`.

## Finder toolbar

The toolbar layout lives in `osx_finder_toolbar` (`defaults/main.yml`) and is
applied by the `Configure Finder toolbar` task in `tasks/main.yml`. Reads and
writes go through `defaults export` / `defaults import` over stdin/stdout,
piped through `plutil -replace -json`, rather than editing
`~/Library/Preferences/com.apple.finder.plist` directly, because `cfprefsd`
caches that file in memory and silently overwrites in-place edits. No temp file
is involved, since `plutil` accepts `-` for both its input and output plist.
Idempotence comes from comparing the live value against the desired one and
skipping the write when they already match, so the `Restart Finder` handler
fires only on a real change.

The desired state is exact rather than merged, since `plutil -replace` swaps the
whole dictionary.

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
