import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.Commons
import qs.Services.System
import qs.Widgets

// Compact system stats for the lock screen: CPU / temp / RAM ring gauges
// plus a live network speed readout. Colors follow the SystemStatService
// warning/critical palette so high usage highlights like the rest of the shell.
Item {
  id: root

  // Slightly larger than the system-monitor card gauges for lock screen legibility.
  readonly property real contentScale: 1.1 * Style.uiScaleRatio

  Component.onCompleted: SystemStatService.registerComponent("lockscreen")
  Component.onDestruction: SystemStatService.unregisterComponent("lockscreen")

  implicitWidth: statsColumn.implicitWidth
  implicitHeight: statsColumn.implicitHeight

  ColumnLayout {
    id: statsColumn
    anchors.fill: parent
    spacing: Style.marginXS

    RowLayout {
      Layout.alignment: Qt.AlignHCenter
      spacing: Style.marginL

      NCircleStat {
        id: cpuGauge
        ratio: SystemStatService.cpuUsage / 100
        icon: "cpu-usage"
        contentScale: root.contentScale
        fillColor: SystemStatService.cpuColor
        tooltipText: I18n.tr("system-monitor.cpu-usage") + `: ${Math.round(SystemStatService.cpuUsage)}%`
      }

      NCircleStat {
        id: tempGauge
        ratio: SystemStatService.cpuTemp / 100
        suffix: "°C"
        icon: "cpu-temperature"
        contentScale: root.contentScale
        fillColor: SystemStatService.tempColor
        visible: SystemStatService.cpuTemp > 0
        tooltipText: I18n.tr("system-monitor.cpu-temp") + `: ${Math.round(SystemStatService.cpuTemp)}°C`
      }

      NCircleStat {
        id: memGauge
        ratio: SystemStatService.memPercent / 100
        icon: "memory"
        contentScale: root.contentScale
        fillColor: SystemStatService.memColor
        tooltipText: I18n.tr("common.memory") + `: ${Math.round(SystemStatService.memPercent)}%`
      }
    }

    // Network speeds readout (download / upload)
    RowLayout {
      Layout.alignment: Qt.AlignHCenter
      spacing: Style.marginM

      NIcon {
        icon: "download-speed"
        pointSize: Style.fontSizeM
        color: Color.mOnSurfaceVariant
      }

      NText {
        text: SystemStatService.formatSpeed(SystemStatService.rxSpeed).replace(/([0-9.]+)([A-Za-z]+)/, "$1 $2") + "/s"
        pointSize: Style.fontSizeS
        font.family: Settings.data.ui.fontFixed
        color: Color.mOnSurfaceVariant
        horizontalAlignment: Text.AlignHCenter
      }

      NIcon {
        icon: "upload-speed"
        pointSize: Style.fontSizeM
        color: Color.mOnSurfaceVariant
        Layout.leftMargin: Style.marginXS
      }

      NText {
        text: SystemStatService.formatSpeed(SystemStatService.txSpeed).replace(/([0-9.]+)([A-Za-z]+)/, "$1 $2") + "/s"
        pointSize: Style.fontSizeS
        font.family: Settings.data.ui.fontFixed
        color: Color.mOnSurfaceVariant
        horizontalAlignment: Text.AlignHCenter
      }
    }
  }
}
