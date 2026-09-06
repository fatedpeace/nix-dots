import QtQuick

Text {
    color: "white"
    text: Qt.formatTime(new Date(), "HH:mm")

    Timer {
        interval: 1000
        running: true
        repeat: true

        onTriggered: {
            Qt.formatTime(new Date(), "HH:mm") 
        }
    }
}