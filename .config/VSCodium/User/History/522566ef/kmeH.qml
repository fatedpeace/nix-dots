import QtQuick
import Quickshell.Services.Pipewire

Item {
    property var sink: Pipewire.defaultAudioSink

    Component.onCompleted: {
        console.log("Volume:", sink.audio.volume)
        console.log("Muted:", sink.audio.muted)
    }
}