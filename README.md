# noctalia-overlay

Custom patches for the [noctalia-shell](https://github.com/soramanew/noctalia) Quickshell
shell, stored as a small overlay you can re-apply after a machine switch or a
package upgrade.

> **Noctalia v5:** v5 is a ground-up C++ rewrite and no longer uses
> Quickshell/QML, so the QML overlay below only applies to the v4 shell. For v5
> the lock-screen stats are recreated as a plugin — no patched shell needed:
> see [`v5/noctalia-lockscreen-stats/`](v5/noctalia-lockscreen-stats/README.md).

## What this changes

On the lock screen, above the password panel, adds live system stats:

- **CPU usage**, **CPU temperature**, and **RAM usage** as circular `NCircleStat`
  ring gauges (colors follow the system stats colors).
- **Network** download/upload speeds as a text row underneath.

Related changes:

- `SystemStatService.qml` allows polling while the lock screen is active when the
  `"lockscreen"` consumer is registered (otherwise the lock screen would show
  stale/zeroed stats).
- `LockScreen.qml` notification toasts are shifted up so they don't overlap the
  stats row.

Only the non-compact lock screen shows stats. Opt out at runtime by adding
`"lockScreenShowSystemStats": false` to the `general` section of
`~/.config/noctalia/settings.json`.

## Layout

```
apply.sh                     copies the system shell and overlays the files below
noctalia-shell/              mirrors paths relative to the shell config root
├── Modules/LockScreen/
│   ├── LockScreen.qml                notification offsets
│   ├── LockScreenPanel.qml           stats row + container height
│   └── LockScreenSystemStats.qml     NEW - the stats widget
└── Services/System/
    └── SystemStatService.qml         lock-screen polling gate
```

## How it works

Quickshell resolves `qs -c noctalia-shell` to the first match of
`<config-dir>/quickshell/noctalia-shell/shell.qml` from `[~/.config, /etc/xdg]`,
so a copy in `~/.config/quickshell/noctalia-shell/` takes precedence over the
system copy in `/etc/xdg/quickshell/noctalia-shell/` and survives package updates.

`apply.sh` always copies the **current** system shell first, then overwrites the
custom files on top. This keeps compatibility with the installed
noctalia-shell version.

## Apply

```sh
~/noctalia-overlay/apply.sh
```

Then restart the shell (also printed by the script):

```sh
pkill -f 'qs -c noctalia-shell'
setsid -f qs -c noctalia-shell >/tmp/qs.log 2>&1 </dev/null
```

Test the lock screen with:

```sh
qs -c noctalia-shell ipc call lockScreen lock
```

## Caveat

If a future noctalia-shell release heavily rewrites `LockScreenPanel.qml` or
`LockScreen.qml`, the overlay may need a manual re-merge (the overlay files
replace the upstream files wholesale).
