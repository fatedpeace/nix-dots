import QtQuick
import Quickshell.Hyprland

Text {
    color: "white"

    font.family: "Roboto Mono"
    font.pixelSize: 20

    property var workspaceIcons: ({
        1: "" // terminal
        2: "" // codium
        3: "" // browser
        4: "" // music
        5: "" //msgs
    })

    text: Hyprland.monitors.values.length > 0
        ? Hyprland.monitors.values[0].activeWorkspace.id
        : ""
}
