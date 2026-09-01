
import Quickshell
import Quickshell.Hyprland
import Quickshell.Services.Mpris
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
                && workspaceId <= workspaceEmojis.length)
            return workspaceEmojis[workspaceId - 1]

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
    // DYNAMIC ISLAND
    // =========================

    Rectangle {
        id: island

        property real minimumWidth: 200
        property real maximumWidth: 500

        property real titleWidth:
            root.mediaTitle.length * 9

        width: {
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

        // Show / hide
        y: root.islandVisible ? 8 : -height

        // =========================
        // ANIMATIONS
        // =========================

        Behavior on width {
            NumberAnimation {
                duration: 300
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
        // WORKSPACE + CLOCK
        // =========================

        Row {
            id: normalContent

            anchors.centerIn: parent

            spacing: 12

            visible: !root.mediaPlaying

            // Workspace emoji
            Text {
                text: root.workspaceEmoji

                font.pixelSize: 20

                // Fix vertical alignment
                anchors.verticalCenterOffset: 2
            }

            // Clock
            Text {
                id: centeredClock

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
        // MEDIA MODE
        // WORKSPACE + CLOCK
        // =========================

        Row {
            id: leftContent

            anchors.left: parent.left
            anchors.leftMargin: 25
            anchors.verticalCenter: parent.verticalCenter

            spacing: 12

            visible: root.mediaPlaying

            // Workspace emoji
            Text {
                text: root.workspaceEmoji

                font.pixelSize: 20

                // Fix vertical alignment
                anchors.verticalCenterOffset: 2
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
        // ISLAND HOVER AREA
        // =========================

        MouseArea {
            anchors.fill: parent

            hoverEnabled: true

            onEntered: {
                root.islandVisible = true
            }

            onExited: {
                root.islandVisible = false
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
}
