
import Quickshell
import QtQuick

ShellRoot {
    id: root

    PanelWindow {
        id: panel

        anchors.top: true
        exclusiveZone: 0
        margins.top: 8

        implicitWidth: 500
        implicitHeight: 40

        Rectangle {
            anchors.fill: parent

            radius: height / 2
            color: "#111111"

            Text {
                anchors.centerIn: parent

                text: Qt.formatTime(new Date(), "HH:mm")

                color: "white"
                font.pixelSize: 15
                font.bold: true
            }

            Timer {
                interval: 1000
                running: true
                repeat: true

                onTriggered: {
                    // Forces the Text binding to update by changing
                    // the current time source.
                }
            }
        }
    }
}
```
