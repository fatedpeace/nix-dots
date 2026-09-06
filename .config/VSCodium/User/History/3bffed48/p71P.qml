import QtQuick

Text {
    color: "white"
    font.family: "Google Sans Code"
    font.pixelSize: 16
    font.weight: Font.Bold

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