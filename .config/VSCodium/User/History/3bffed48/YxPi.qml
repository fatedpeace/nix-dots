import QtQuick

Text {
    color: "White"
    text: Qt.formatTime(newDate(), "HH:MM")

    Timer {
        interval: 1000
        running: true
        repeat: true

        onTriggered: {
            Qt.formatTime(newDate(), "HH:MM")
        }
    }
    
}