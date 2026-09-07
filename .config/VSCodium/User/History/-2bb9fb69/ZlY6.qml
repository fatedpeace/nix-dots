import QtQuick
import Quickshell.Hyprland

Text {
    color: "white"

    font.family: "JetBrainsMono Nerd Font"
    font.pixelSize: 22
    renderType: Text.NativeRendering


    property var workspaceIcons: ({
        1: "", // terminal
        2: "", // codium
        3: "", // browser
        4: "󰓇 ", // music
        5: " " //msgs
    })

    text: Hyprland.monitors.values.length > 0
        ? workspaceIcons[Hyprland.monitors.values[0].activeWorkspace.id]
        : ""
}
