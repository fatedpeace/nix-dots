import QtQuick

Text {
    color: "white"
    font.family: "Roboto Mono"
    font.pixelSize: 20
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