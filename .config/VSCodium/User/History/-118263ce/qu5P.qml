
import Quickshell
import Quickshell.Hyprland
import Quickshell.Services.Mpris
import Quickshell.Io
import QtQuick

PanelWindow {
    id: root

    // =========================
    // PANEL
    // =========================

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

        if (direction > 0) {
            volumeUp.running = true
        } else {
            volumeDown.running = true
        }

        // Reveal the island
        islandVisible = true

        // Show volume UI
        volumeVisible = true

        // Refresh volume shortly after command
        volumeUpdateTimer.restart()

        // Reset auto-hide timer
        volumeHideTimer.restart()
    }

    // =========================
    // WORKSPACE EMOJIS
    // =========================

    property var workspaceEmojis: [
        "🌐",
        "💻",
        "📁",
        "🎵",
        "💬",
        "🎮",
        "🎬",
        "📝",
        "⚙️",
        "🏠"
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

    // Wait briefly for wpctl to apply the change
    Timer {
        id: volumeUpdateTimer

        interval: 100
        repeat: false

        onTriggered: {
            volumeGet.running = true
        }
    }

    // Volume UI auto-hide
    Timer {
        id: volumeHideTimer

        // Tuned to feel quick but still readable
        interval: 900
        repeat: false

        onTriggered: {
            root.volumeVisible = false

            // If mouse isn't over the island,
            // start the normal hide delay.
            if (!root.islandHovered) {
                islandHideTimer.restart()
            }
        }
    }

    // Island hover exit delay
    Timer {
        id: islandHideTimer

        // Prevent the island disappearing instantly
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
            // Volume mode
            if (root.volumeVisible) {
                return 320
            }

            // Idle mode
            if (!root.mediaPlaying) {
                return minimumWidth
            }

            // Media mode
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

        // Hidden above the screen
        y: root.islandVisible ? 8 : -height

        // =========================
        // ISLAND ANIMATIONS
        // =========================

        Behavior on width {
            NumberAnimation {
                duration: 360
                easing.type: Easing.OutCubic
            }
        }

        Behavior on y {
            NumberAnimation {
                duration: 260
                easing.type: Easing.OutCubic
            }
        }

        // =========================
        // IDLE CONTENT
        // =========================

        Item {
            id: normalContent

            anchors.fill: parent

            visible: !root.mediaPlaying
                     && !root.volumeVisible

            opacity: visible ? 1 : 0
            x: visible ? 0 : -8

            Behavior on opacity {
                NumberAnimation {
                    duration: 180
                    easing.type: Easing.OutCubic
                }
            }

            Behavior on x {
                NumberAnimation {
                    duration: 180
                    easing.type: Easing.OutCubic
                }
            }

            // Workspace emoji
            Text {
                id: normalWorkspaceEmoji

                text: root.workspaceEmoji

                anchors.right: centeredClock.left
                anchors.rightMargin: 12
                anchors.verticalCenter: centeredClock.verticalCenter
                anchors.verticalCenterOffset: 3

                font.pixelSize: 20
            }

            // Clock
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
            id: mediaContent

            anchors.fill: parent

            visible: root.mediaPlaying
                     && !root.volumeVisible

            opacity: visible ? 1 : 0
            x: visible ? 0 : 8

            Behavior on opacity {
                NumberAnimation {
                    duration: 220
                    easing.type: Easing.OutCubic
                }
            }

            Behavior on x {
                NumberAnimation {
                    duration: 220
                    easing.type: Easing.OutCubic
                }
            }

            Row {
                id: leftContent

                anchors.left: parent.left
                anchors.leftMargin: 25
                anchors.verticalCenter: parent.verticalCenter

                spacing: 12

                // Workspace emoji
                Text {
                    text: root.workspaceEmoji

                    font.pixelSize: 20
                    anchors.verticalCenterOffset: 3
                }

                // Clock
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

            // Media title
            Text {
                id: mediaText

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
            id: volumeContent

            anchors.fill: parent

            visible: root.volumeVisible

            opacity: visible ? 1 : 0
            x: visible ? 0 : 8

            Behavior on opacity {
                NumberAnimation {
                    duration: 180
                    easing.type: Easing.OutCubic
                }
            }

            Behavior on x {
                NumberAnimation {
                    duration: 180
                    easing.type: Easing.OutCubic
                }
            }

            Rectangle {
                id: volumeBar

                anchors.centerIn: parent

                width: parent.width - 50
                height: 8

                radius: height / 2

                color: "#333333"

                Rectangle {
                    id: volumeFill

                    width:
                        parent.width
                        * root.volumeValue

                    height: parent.height

                    radius: height / 2

                    color: "#FFFFFF"

                    Behavior on width {
                        NumberAnimation {
                            duration: 220
                            easing.type: Easing.OutCubic
                        }
                    }
                }
            }
        }

        // =========================
        // HOVER AREA
        // =========================

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true

            onEntered: {
                // Cancel pending hide
                islandHideTimer.stop()

                root.islandHovered = true
                root.islandVisible = true
            }

            onExited: {
                root.islandHovered = false

                // Don't hide instantly
                if (!root.volumeVisible) {
                    islandHideTimer.restart()
                }
            }
        }
    }

    // =========================
    // TOP EDGE TRIGGER
    // =========================

    MouseArea {
        id: topTrigger

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
    // CLOCK TIMER
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
