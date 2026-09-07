import QtQuick

Item {
    width: 50
    height: 24

    Row {
        anchors.centerIn: parent
        spacing: 4

        Repeater {
            model: 7

            Rectangle {
                width: 4
                height: 2
                radius: 2
                color: "white"

                anchors.verticalCenter: parent.verticalCenter
            }
        }
    }
}