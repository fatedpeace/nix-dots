import QtQuick

Text { // text
    color: "white" // colored white
    font.family: "Roboto Mono" // cool font can also use google sans code
    font.pixelSize: 20 // font size
    font.weight: Font.Bold // font weight

    SystemClock {
        id: clock
        precision: SystemClock.Minutes
    }

    text: Qt.formatDateTime(clock.date, "HH:mm")
}