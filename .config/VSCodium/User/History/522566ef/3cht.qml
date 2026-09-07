import QtQuick
import Quickshell.Services.Pipewire

Item {
    property var sink: Pipewire.defaultAudioSink

    Text {
        anchors.centerIn: parent

        color: "white"
        font.family: "JetBrainsMono Nerd Font"
        font.pixelSize: 16

        text: sink !== null && sink.audio !== null
            ? Math.round(sink.audio.volume * 100) + "%"
            : ""
    }
}