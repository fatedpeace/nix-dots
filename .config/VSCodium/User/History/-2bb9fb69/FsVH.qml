import QtQuick
import Quickshell.Hyprland

Text {
    color: "white"

    font.family: "Roboto Mono"
    font.pixelSize: 20

    text: Hyprland.monitors.values.length > 0
        ? Hyprland.monitors.values[0].activeWorkspace.id
        : ""
}