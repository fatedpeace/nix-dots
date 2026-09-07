import QtQuick
import Quickshell.Services.Pipewire

Item {
    width: 180
    height: 20
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

    Rectangle {
    width: 180
    height: 6
    radius: 99

    color: "#333333"

        Rectangle {
            width: parent.width * currentVolume
            height: parent.height
            radius: 99

            color: "white"

            Behavior on width {
                NumberAnimation {
                    duration: 150
                    easing.type: Easing.OutCubic
                }
            }
        }
    }
}