import QtQuick
import Quickshell.Services.Pipewire

Item {
    property var sink: Pipewire.defaultAudioSink

    PwObjectTracker {
        objects: sink !== null ? [sink] : []
    }

    Connections {
        target: sink !== null ? sink.audio : null

        function onVolumeChanged() {
            console.log("Volume changed:", sink.audio.volume)
        }
    }

    Text {
        anchors.centerIn: parent

        color: "white"
        font.family: "JetBrainsMono Nerd Font"
        font.pixelSize: 16

        text: sink !== null && sink.audio !== null
            ? Math.round(sink.audio.volume * 100) + "%"
            : "NO SINK"
    }
}