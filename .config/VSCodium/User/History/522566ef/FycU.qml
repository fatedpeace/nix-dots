import QtQuick
import Quickshell.Services.Pipewire

Item {
    width: 320
    height: 50

    property var sink: Pipewire.defaultAudioSink
    property real currentVolume: 0

    signal volumeChangedByPipewire()

    PwObjectTracker {
        objects: sink !== null ? [sink] : []
    }

    Connections {
        target: sink !== null ? sink.audio : null

        function onVolumeChanged() {
            if (sink === null)
                return

            currentVolume = sink.audio.volume

            console.log("Volume changed:", currentVolume)

            volumeChangedByPipewire()
        }
    }

    Row {
        anchors.centerIn: parent
        spacing: 10

        Text {
            text: ""
            color: "white"
            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: 17
            anchors.verticalCenter: parent.verticalCenter
        }

        Rectangle {
            width: 230
            height: 6
            radius: 99
            color: "#333333"

            anchors.verticalCenter: parent.verticalCenter

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

        Text {
            text: Math.round(currentVolume * 100) + "%"
            color: "white"
            font.family: "Roboto Mono"
            font.pixelSize: 14
            font.weight: Font.Bold
            anchors.verticalCenter: parent.verticalCenter
        }
    }
}
