import QtQuick
import Quickshell.Services.Mpris

Item { // invisible container that can or cannot display anything
    width: 50 // dimensions for container
    height: 24 // dimensions for container

    property var player: {
        for (let p of Mpris.players.values) {
            if (p.isPlaying)
                return p
        }
        return null 
    }
    
    opacity: player !== null && player.isPlaying ? 1 : 0

    Behavior on opacity {
        NumberAnimation {
            duration: 400
            easing.type: Easing.InOutCubic
        }
    }

    Row { // layout container so everything in this will be inline horizontally
        anchors.centerIn: parent // anchored to the center of parent
        spacing: 4 // how far apart each thing is

        Repeater { // repeats
            model: 4 // repeats 4 times

            Rectangle { // visible rectangle
                property int targetHeight: 8
                property int maxHeight: 16

                Timer {
                    interval: 500
                    running: player !== null && player.isPlaying
                    repeat: true

                    onTriggered: {
                        targetHeight = 4 + Math.random() * maxHeight
                    }
                }

                width: 4
                height: targetHeight

                radius: 99
                color: "white"

                anchors.verticalCenter: parent.verticalCenter

                Behavior on height {
                    NumberAnimation {
                        duration: 500
                        easing.type: Easing.InOutSine
                    }
                }
            }
        }
    }
}