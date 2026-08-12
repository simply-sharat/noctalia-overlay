# Lock Screen Stats

System statistics widget for the Noctalia v5 lock screen: CPU / RAM / temperature
gauges and network speeds, re-rendered once per second while the lock is visible.
It is a v5 port of the v4 overlay in this repo (`noctalia-shell/`), which was
built against the Quickshell/QML shell and does not apply to v5.

The widget is a single [[desktop_widget]] plugin entry (`lockscreen_stats`),
which runs on the lock screen as a layer-shell surface. It uses only the
built-in plugin API — no patched shell binary is required.

## Requirements

- Noctalia v5. The manifest declares `plugin_api = 20` (the maximum the v5.0.0
  release accepts); it also loads on newer builds, which simply treat it as an
  older-API plugin. No source patches needed.
- `[system.monitor]` enabled in the Noctalia config so CPU/RAM/network and
  sensor data are sampled. If it is disabled, the widget stays empty.

## Install

Enable the plugin, then add it to the lock screen. Either of these works:

**Option A — path source (tracks this repo):**

```sh
noctalia msg plugins source add noctalia-overlay-v5 path "$HOME/noctalia-overlay/v5"
noctalia msg plugins enable sharat/noctalia-lockscreen-stats
```

**Option B — local plugins dir:**

```sh
mkdir -p "$HOME/.local/share/noctalia/plugins"
cp -r v5/noctalia-lockscreen-stats "$HOME/.local/share/noctalia/plugins/"
```

Then enable it in Settings → Plugins (or `noctalia msg plugins enable`).
`sharat/` is just the plugin author segment — rename it freely.

## Add it to the lock screen

Placement is stored in the **app-owned** lockscreen widget state, which overrides
`config.toml` once it exists — so on an existing install edit
`~/.local/state/noctalia/settings.toml` (the Settings app writes here too), or
use the widget editor described below:

```toml
[lockscreen_widgets]
enabled = true
widget_order = [ "lockscreen_stats", "lockscreen-login-box@DP-1" ]

    [lockscreen_widgets.widget.lockscreen_stats]
    box_width = 0.0
    box_height = 0.0
    cx = 1280.0
    cy = 1000.0
    output = "DP-1"
    rotation = 0.0
    type = "sharat/noctalia-lockscreen-stats:lockscreen_stats"
```

Replace `output` with your monitor and pick `cx`/`cy` (widget center in output
coordinates) so it sits above the login box. `noctalia msg session lock` shows
the result; no restart is needed for the state file.

**Easier:** open the lock screen widget editor while unlocked
(`noctalia msg lockscreen-widgets-edit`, close with `lockscreen-widgets-exit`)
and drag the widget into place. On a *fresh* config with no app-owned
`[lockscreen_widgets]` state yet, the same keys under `[lockscreen_widgets]` in
`~/.config/noctalia/config.toml` act as the seed (note: there is no `scale`
key on widgets).

## Settings

All settings are editable per-widget in the lock screen widget editor:

| Key           | Type    | Default    | Effect                          |
| ------------- | ------- | ---------- | ------------------------------- |
| `show_cpu`    | bool    | `true`     | Show the CPU usage gauge        |
| `show_temp`   | bool    | `true`     | Show the CPU temperature gauge  |
| `show_ram`    | bool    | `true`     | Show the RAM usage gauge        |
| `show_network`| bool    | `true`     | Show download/upload speeds     |
| `accent`      | color   | `primary`  | Fill color of the gauges        |

## Notes

- The v4 overlay used `NCircleStat` rings; v5's UI toolkit has no ring widget,
  so the gauges are pill progress bars instead.
- The temperature gauge reads `stats.cpu.tempC` (from the sensor probe). If no
  CPU sensor is present the gauge is hidden rather than showing a bogus value.
- Network speeds read `stats.net.rxBytesPerSec` / `txBytesPerSec`.
- While the lock screen is on screen, `systemStats()` retains the CPU/GPU probe
  so the temperature stays live; the probes are released when the lock screen
  is dismissed.
