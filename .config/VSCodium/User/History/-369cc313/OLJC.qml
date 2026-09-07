import QtQuick

Item {
    width: 50
    height: 24

    Row {
        anchors.center.In: parent
        spacing: 4

        Repeated {
            model: 7

            Rectangle {
                width: 4
                height: 2
                raidus: 2
                color: "white"

                anchors.verticalCenter: parent.verticalCenter
            }
        }
    }
}