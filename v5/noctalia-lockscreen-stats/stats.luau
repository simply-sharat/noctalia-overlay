--!nonstrict
-- Lock-screen system stats: CPU / RAM / temperature gauges and network speeds.
--
-- A [[desktop_widget]] plugin entry. It is hosted on the lock screen as a
-- layer-shell surface, re-rendering once per second while the lock is visible.
-- Setting the update interval opts this widget into one update() call per
-- tick (noctalia.setUpdateInterval); each update() polls noctalia.systemStats()
-- and paints a declarative ui.* tree via desktopWidget.render(). The host diffs
-- the tree, so re-rendering unchanged values is free.
--
-- The first noctalia.systemStats() call also opts this host into the optional
-- CPU/GPU sensor probes, so temperature stays available while the lock screen
-- is on screen and the probes are released again when it is not.

noctalia.setUpdateInterval(1000)

local COLOR_NEUTRAL = "on_surface_variant"

local function readConfig()
  return {
    showCpu     = noctalia.getConfig("show_cpu"),
    showTemp    = noctalia.getConfig("show_temp"),
    showRam     = noctalia.getConfig("show_ram"),
    showNetwork = noctalia.getConfig("show_network"),
    accent      = noctalia.getConfig("accent"),
  }
end

local config = readConfig()

local function formatBytesPerSec(bps)
  if bps >= 1e9 then
    return string.format("%.1f GB/s", bps / 1e9)
  elseif bps >= 1e6 then
    return string.format("%.1f MB/s", bps / 1e6)
  elseif bps >= 1e3 then
    return string.format("%.1f KB/s", bps / 1e3)
  else
    return string.format("%d B/s", bps)
  end
end

local function pct(value)
  return math.clamp(value or 0, 0, 100)
end

-- One pill gauge: a caption on top, a thin progress bar below.
local function gauge(caption, value, color)
  return ui.column({ gap = 4, align = "center" }, {
    ui.label({ text = caption, fontSize = 13, color = COLOR_NEUTRAL }),
    ui.progress({
      progress = pct(value) / 100,
      fill     = color,
      track    = color .. "/0.25",
      width    = 120,
      height   = 6,
      radius   = 3,
    }),
  })
end

local function render()
  local stats = noctalia.systemStats()
  if stats == nil then
    -- [system.monitor] is disabled; there is nothing to sample.
    desktopWidget.render(ui.column({}, {}))
    return
  end

  local children = {}

  local gauges = {}
  if config.showCpu then
    table.insert(gauges, gauge("CPU", stats.cpu.usagePercent, config.accent))
  end
  if config.showTemp and stats.cpu.tempC ~= nil then
    table.insert(gauges, gauge(string.format("%d°C", math.round(stats.cpu.tempC)), stats.cpu.tempC, config.accent))
  end
  if config.showRam then
    table.insert(gauges, gauge("RAM", stats.ram.usagePercent, config.accent))
  end

  if #gauges > 0 then
    table.insert(children, ui.row({ gap = 12, align = "center" }, gauges))
  end

  if config.showNetwork then
    table.insert(children, ui.row({ gap = 10, align = "center" }, {
      ui.glyph({ name = "download", size = 13, color = COLOR_NEUTRAL }),
      ui.label({ text = formatBytesPerSec(stats.net.rxBytesPerSec), fontSize = 12, color = COLOR_NEUTRAL }),
      ui.glyph({ name = "upload", size = 13, color = COLOR_NEUTRAL }),
      ui.label({ text = formatBytesPerSec(stats.net.txBytesPerSec), fontSize = 12, color = COLOR_NEUTRAL }),
    }))
  end

  desktopWidget.render(ui.column({ gap = 8, align = "center" }, children))
end

-- The host invokes update() once per update interval while the widget lives.
function update()
  render()
end

-- Live-setting changes (widget editor) re-read the config and repaint.
function onConfigChanged()
  config = readConfig()
  render()
end

render()
