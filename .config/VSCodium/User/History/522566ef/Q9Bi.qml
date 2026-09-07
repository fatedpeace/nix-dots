import QtQuick
import Quickshell.Services.Pipewire

Item {
    property var sink: Pipewire.defaultAudioSink

    Component.onCompleted: {
        console.log("Pipewire ready:", Pipewire.ready)
        console.log("Default sink:", sink)
        console.log("Audio:", sink !== null ? sink.audio : null)
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