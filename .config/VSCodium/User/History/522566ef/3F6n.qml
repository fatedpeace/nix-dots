import QtQuick
import Quickshell.Services.Pipewire

Item {
    property var sink: Pipewire.defaultAudioSink
    property real currentVolume: 0

    PwObjectTracker {
        objects: sink !== null ? [sink] : []
    }

    Connections {
        target: sink !== null ? sink.audio : null

        function onVolumeChanged() {
            currentVolume = sink.audio.volume
            console.log("Volume changed:", currentVolume)
        }
    }

    Text {
        anchors.centerIn: parent

        color: "white"
        font.family: "JetBrainsMono Nerd Font"
        font.pixelSize: 16

        text: Math.round(currentVolume * 100) + "%"
    }
}