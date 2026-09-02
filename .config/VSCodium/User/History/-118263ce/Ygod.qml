
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
        // Change the system volume
        if (direction > 0) {
            volumeUp.running = true
        } else {
            volumeDown.running = true
        }

        // Automatically reveal the island
        islandVisible = true

        // Show volume UI
        volumeVisible = true

        // Restart timers on every volume change
        volumeHideTimer.restart()
        volumeUpdateTimer.restart()
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

    // Wait briefly for wpctl to update,
    // then read the new volume.
    Timer {
        id: volumeUpdateTimer

        interval: 100
        repeat: false

        onTriggered: {
            volumeGet.running = true
        }
    }

    // Hide the volume interface after 2 seconds.
    Timer {
        id: volumeHideTimer

        interval: 2000
        repeat: false

        onTriggered: {
            root.volumeVisible = false

            // If the mouse isn't hovering the island,
            // hide the island as well.
            if (!root.islandHovered) {
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
            // Volume takes priority temporarily
            if (root.volumeVisible) {
                return 320
            }

            // Normal idle mode
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

        // Slide the island down/up
        y: root.islandVisible ? 8 : -height

        // =========================
        // ANIMATIONS
        // =========================

        Behavior on width {
            NumberAnimation {
                duration: 250
                easing.type: Easing.OutCubic
            }
        }

        Behavior on y {
            NumberAnimation {
                duration: 250
                easing.type: Easing.OutCubic
            }
        }

        // =========================
        // NORMAL MODE
        // =========================

        // Workspace emoji
        Text {
            id: normalWorkspaceEmoji

            visible: !root.mediaPlaying
                     && !root.volumeVisible

            text: root.workspaceEmoji

            font.pixelSize: 20

            // Keep the clock centered.
            anchors.right: centeredClock.left
            anchors.rightMargin: 12
            anchors.verticalCenter: centeredClock.verticalCenter

            // Fine visual alignment.
            anchors.verticalCenterOffset: 3
        }

        // Center clock
        Text {
            id: centeredClock

            anchors.centerIn: parent

            visible: !root.mediaPlaying
                     && !root.volumeVisible

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

        // =========================
        // MEDIA MODE
        // =========================

        Row {
            id: leftContent

            anchors.left: parent.left
            anchors.leftMargin: 25
            anchors.verticalCenter: parent.verticalCenter

            spacing: 12

            visible: root.mediaPlaying
                     && !root.volumeVisible

            // Workspace emoji
            Text {
                text: root.workspaceEmoji

                font.pixelSize: 20

                // Fine visual adjustment.
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

        // =========================
        // MEDIA TITLE
        // =========================

        Text {
            id: mediaText

            anchors.right: parent.right
            anchors.rightMargin: 25
            anchors.verticalCenter: parent.verticalCenter

            visible: root.mediaPlaying
                     && !root.volumeVisible

            width: Math.max(
                0,
                parent.width - 165
            )

            text: root.mediaTitle

            color: "#F5F5F5"

            font.family: root.mainFont
            font.pixelSize: 17
            font.weight: Font.Medium
            font.letterSpacing: 0

            renderType: Text.NativeRendering

            elide: Text.ElideRight
            horizontalAlignment: Text.AlignRight
        }

        // =========================
        // VOLUME MODE
        // =========================

        Item {
            id: volumeContent

            anchors.fill: parent

            visible: root.volumeVisible

            // Volume label
            Text {
                id: volumeLabel

                anchors.left: parent.left
                anchors.leftMargin: 25
                anchors.verticalCenter: parent.verticalCenter

                text: "VOL"

                color: "#FFFFFF"

                font.family: root.mainFont
                font.pixelSize: 16
                font.weight: Font.DemiBold

                renderType: Text.NativeRendering
            }

            // Volume percentage
            Text {
                id: volumePercent

                anchors.left: volumeLabel.right
                anchors.leftMargin: 12
                anchors.verticalCenter: parent.verticalCenter

                text: Math.round(
                    root.volumeValue * 100
                ) + "%"

                color: "#FFFFFF"

                font.family: root.mainFont
                font.pixelSize: 16
                font.weight: Font.DemiBold

                renderType: Text.NativeRendering
            }

            // Volume background
            Rectangle {
                id: volumeBar

                anchors.left: volumePercent.right
                anchors.leftMargin: 18

                anchors.right: parent.right
                anchors.rightMargin: 25

                anchors.verticalCenter: parent.verticalCenter

                height: 8
                radius: height / 2

                color: "#333333"

                // Filled volume
                Rectangle {
                    width:
                        parent.width
                        * root.volumeValue

                    height: parent.height

                    radius: height / 2

                    color: "#FFFFFF"

                    Behavior on width {
                        NumberAnimation {
                            duration: 150
                            easing.type: Easing.OutCubic
                        }
                    }
                }
            }
        }

        // =========================
        // ISLAND HOVER AREA
        // =========================

        MouseArea {
            anchors.fill: parent

            hoverEnabled: true

            onEntered: {
                root.islandHovered = true
                root.islandVisible = true
            }

            onExited: {
                root.islandHovered = false

                // Don't hide while the volume popup
                // is still active.
                if (!root.volumeVisible) {
                    root.islandVisible = false
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
    // VOLUME SHORTCUTS
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
