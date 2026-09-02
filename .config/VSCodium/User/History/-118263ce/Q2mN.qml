
import Quickshell
import Quickshell.Hyprland
import Quickshell.Services.Mpris
import Quickshell.Io
import QtQuick

ShellRoot {

    // =========================
    // MAIN DYNAMIC ISLAND
    // =========================

    PanelWindow {
        id: root

        anchors.top: true
        exclusiveZone: 0
        color: "transparent"

        implicitWidth: island.width
        implicitHeight: 58

        // =========================
        // SETTINGS
        // =========================

        property string mainFont: "Roboto Mono"

        property bool islandVisible: false
        property bool islandHovered: false

        // =========================
        // VOLUME
        // =========================

        property bool volumeVisible: false
        property real volumeValue: 0.5

        function changeVolume(direction) {
            islandHideTimer.stop()
            volumeHideTimer.stop()
            volumeResetTimer.stop()

            if (direction > 0) {
                volumeUp.running = true
            } else {
                volumeDown.running = true
            }

            islandVisible = true
            volumeVisible = true

            volumeUpdateTimer.restart()
            volumeHideTimer.restart()
        }

        // =========================
        // WORKSPACE EMOJIS
        // =========================

        property var workspaceEmojis: [
            "🌐", "💻", "📁", "🎵", "💬",
            "🎮", "🎬", "📝", "⚙️", "🏠"
        ]

        property int workspaceId: {
            if (Hyprland.focusedWorkspace)
                return Hyprland.focusedWorkspace.id

            return 1
        }

        property string workspaceEmoji: {
            if (workspaceId >= 1
                    && workspaceId <= workspaceEmojis.length) {
                return workspaceEmojis[workspaceId - 1]
            }

            return "📍"
        }

        // =========================
        // MEDIA
        // =========================

        property var mediaPlayer:
            Mpris.players.values.length > 0
            ? Mpris.players.values[0]
            : null

        property bool mediaPlaying:
            mediaPlayer !== null
            && mediaPlayer.isPlaying

        property string mediaTitle:
            mediaPlayer !== null
            ? mediaPlayer.trackTitle
            : ""

        // =========================
        // VOLUME COMMANDS
        // =========================

        Process {
            id: volumeUp

            command: [
                "wpctl",
                "set-volume",
                "@DEFAULT_AUDIO_SINK@",
                "5%+"
            ]
        }

        Process {
            id: volumeDown

            command: [
                "wpctl",
                "set-volume",
                "@DEFAULT_AUDIO_SINK@",
                "5%-"
            ]
        }

        Process {
            id: volumeGet

            command: [
                "wpctl",
                "get-volume",
                "@DEFAULT_AUDIO_SINK@"
            ]

            stdout: SplitParser {
                onRead: data => {
                    const parts = data.trim().split(/\s+/)

                    if (parts.length >= 2) {
                        const value = parseFloat(parts[1])

                        if (!isNaN(value)) {
                            root.volumeValue = Math.max(
                                0,
                                Math.min(1, value)
                            )
                        }
                    }
                }
            }
        }

        // =========================
        // TIMERS
        // =========================

        Timer {
            id: volumeUpdateTimer

            interval: 100
            repeat: false

            onTriggered: {
                volumeGet.running = true
            }
        }

        Timer {
            id: volumeHideTimer

            interval: 1100
            repeat: false

            onTriggered: {
                if (root.islandHovered) {
                    root.volumeVisible = false
                } else {
                    root.islandVisible = false
                    volumeResetTimer.restart()
                }
            }
        }

        Timer {
            id: volumeResetTimer

            interval: 280
            repeat: false

            onTriggered: {
                root.volumeVisible = false
            }
        }

        Timer {
            id: islandHideTimer

            interval: 650
            repeat: false

            onTriggered: {
                if (!root.islandHovered
                        && !root.volumeVisible) {
                    root.islandVisible = false
                }
            }
        }

        // =========================
        // DYNAMIC ISLAND
        // =========================

        Rectangle {
            id: island

            property real minimumWidth: 200
            property real maximumWidth: 500

            property real titleWidth:
                root.mediaTitle.length * 9

            width: {
                if (root.volumeVisible)
                    return 320

                if (!root.mediaPlaying)
                    return minimumWidth

                return Math.min(
                    maximumWidth,
                    Math.max(
                        minimumWidth,
                        180 + titleWidth
                    )
                )
            }

            height: 50

            anchors.horizontalCenter: parent.horizontalCenter

            radius: height / 2
            color: "#111111"

            y: root.islandVisible ? 8 : -height

            Behavior on width {
                NumberAnimation {
                    duration: 340
                    easing.type: Easing.InOutCubic
                }
            }

            Behavior on y {
                NumberAnimation {
                    duration: 280
                    easing.type: Easing.OutCubic
                }
            }

            // =========================
            // IDLE CONTENT
            // =========================

            Item {
                anchors.fill: parent

                visible: !root.mediaPlaying
                         && !root.volumeVisible

                Text {
                    id: normalWorkspaceEmoji

                    text: root.workspaceEmoji

                    anchors.right: centeredClock.left
                    anchors.rightMargin: 12
                    anchors.verticalCenter: centeredClock.verticalCenter
                    anchors.verticalCenterOffset: 3

                    font.pixelSize: 20
                }

                Text {
                    id: centeredClock

                    anchors.centerIn: parent

                    text: Qt.formatTime(
                        new Date(),
                        "HH:mm"
                    )

                    color: "#FFFFFF"

                    font.family: root.mainFont
                    font.pixelSize: 18
                    font.weight: Font.DemiBold
                    font.letterSpacing: 0.2

                    renderType: Text.NativeRendering
                }
            }

            // =========================
            // MEDIA CONTENT
            // =========================

            Item {
                anchors.fill: parent

                visible: root.mediaPlaying
                         && !root.volumeVisible

                Row {
                    anchors.left: parent.left
                    anchors.leftMargin: 25
                    anchors.verticalCenter: parent.verticalCenter

                    spacing: 12

                    Text {
                        text: root.workspaceEmoji

                        font.pixelSize: 20
                    }

                    Text {
                        id: mediaClock

                        text: Qt.formatTime(
                            new Date(),
                            "HH:mm"
                        )

                        color: "#FFFFFF"

                        font.family: root.mainFont
                        font.pixelSize: 18
                        font.weight: Font.DemiBold
                        font.letterSpacing: 0.2

                        renderType: Text.NativeRendering
                    }
                }

                Text {
                    anchors.right: parent.right
                    anchors.rightMargin: 25
                    anchors.verticalCenter: parent.verticalCenter

                    width: Math.max(
                        0,
                        parent.width - 165
                    )

                    text: root.mediaTitle

                    color: "#F5F5F5"

                    font.family: root.mainFont
                    font.pixelSize: 17
                    font.weight: Font.Medium

                    renderType: Text.NativeRendering

                    elide: Text.ElideRight
                    horizontalAlignment: Text.AlignRight
                }
            }

            // =========================
            // VOLUME CONTENT
            // =========================

            Item {
                anchors.fill: parent

                visible: root.volumeVisible

                Rectangle {
                    anchors.centerIn: parent

                    width: parent.width - 50
                    height: 8

                    radius: height / 2
                    color: "#333333"

                    Rectangle {
                        width: parent.width
                               * root.volumeValue

                        height: parent.height

                        radius: height / 2
                        color: "#FFFFFF"

                        Behavior on width {
                            NumberAnimation {
                                duration: 240
                                easing.type: Easing.OutCubic
                            }
                        }
                    }
                }
            }

            // =========================
            // HOVER
            // =========================

            MouseArea {
                anchors.fill: parent
                hoverEnabled: true

                onEntered: {
                    islandHideTimer.stop()

                    root.islandHovered = true
                    root.islandVisible = true
                }

                onExited: {
                    root.islandHovered = false

                    if (!root.volumeVisible)
                        islandHideTimer.restart()
                }
            }
        }

        // =========================
        // TOP EDGE TRIGGER
        // =========================

        MouseArea {
            width: island.width
            height: 1

            anchors.top: parent.top
            anchors.horizontalCenter: parent.horizontalCenter

            hoverEnabled: true

            onEntered: {
                islandHideTimer.stop()
                root.islandVisible = true
            }
        }

        // =========================
        // CLOCK
        // =========================

        Timer {
            interval: 1000
            running: true
            repeat: true

            onTriggered: {
                const time = Qt.formatTime(
                    new Date(),
                    "HH:mm"
                )

                centeredClock.text = time
                mediaClock.text = time
            }
        }

        // =========================
        // GLOBAL VOLUME SHORTCUTS
        // =========================

        GlobalShortcut {
            name: "volume-up"
            description: "Increase volume"

            onPressed: {
                root.changeVolume(1)
            }
        }

        GlobalShortcut {
            name: "volume-down"
            description: "Decrease volume"

            onPressed: {
                root.changeVolume(-1)
            }
        }
    }

    // =========================
    // TOP-RIGHT CONTROL CENTER
    // =========================

    ControlCenter {
    }
}
