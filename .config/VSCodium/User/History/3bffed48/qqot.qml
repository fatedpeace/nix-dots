import QtQuick
import Quickshell

Text {
    color: "white"

    font.family: "Roboto Mono"
    font.pixelSize: 20
    font.weight: Font.Bold

    SystemClock {
        id: clock
        precision: SystemClock.Minutes
    }

    text: Qt.formatDateTime(clock.date, "HH:mm")
}