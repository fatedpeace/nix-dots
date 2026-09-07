import QtQuick
import Quickshell.Hyprland


Text {
    text: "󰆍"
    color: "white"

    font.family: "Roboto Mono"
    font.pixelSize: 20

    Component.onCompleted: {
        console.log("Workspace:", Hyprland.monitors.values[0].activeWorkspace.id)
    }
}