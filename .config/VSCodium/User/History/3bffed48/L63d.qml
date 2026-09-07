import QtQuick
import Quickshell

Text {
    color: "white" // color of the text to be white

    font.family: "Roboto Mono" // sets font to roboto mono
    font.pixelSize: 20 // sets font size to 20px
    font.weight: Font.Bold // sets font weight to bold

    SystemClock { //clock
        id: clock // names it clock
        precision: SystemClock.Minutes // updates only every minute
    }

    text: Qt.formatDateTime(clock.date, "HH:mm") // makes the text the time that updates every mintue
}