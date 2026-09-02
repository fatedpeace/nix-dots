
import Quickshell
import Quickshell.Hyprland
import Quickshell.Services.Mpris
import Quickshell.Io
import QtQuick

ShellRoot {

    // ============================================================
    // MAIN DYNAMIC ISLAND
    // ============================================================

    PanelWindow {
        id: root

        // --------------------------------------------------------
        // PANEL SETTINGS
        // --------------------------------------------------------

        // Attach the panel to the top of the monitor.
        anchors.top: true

        // Do not reserve permanent screen space.
        // This allows windows to use the area behind the island.
        exclusiveZone: 0

        // Transparent PanelWindow background.
        color: "transparent"

        // The window automatically follows the island width.
        implicitWidth: island.width

        // 50px island + 8px top margin.
        implicitHeight: 58


        // ========================================================
        // GENERAL SETTINGS
        // ========================================================

        property string mainFont: "Roboto Mono"

        // Controls whether the island is visible.
        property bool islandVisible: false

        // True while the mouse is over the visible island.
        property bool islandHovered: false


        // ========================================================
        // VOLUME
        // ========================================================

        // Controls whether the temporary volume UI is shown.
        property bool volumeVisible: false

        // Current volume between 0.0 and 1.0.
        property real volumeValue: 0.5


        // --------------------------------------------------------
        // CHANGE VOLUME
        // --------------------------------------------------------

        function changeVolume(direction) {

            // Cancel any animations/timers currently trying to hide
            // or reset the volume interface.
            islandHideTimer.stop()
            volumeHideTimer.stop()
            volumeResetTimer.stop()

            // Change volume by 5%.
            if (direction > 0) {
                volumeUp.running = true
            } else {
                volumeDown.running = true
            }

            // Reveal the island.
            islandVisible = true

            // Switch to the volume UI.
            volumeVisible = true

            // Read the updated volume shortly after wpctl changes it.
            volumeUpdateTimer.restart()

            // Restart the timeout every time the user changes volume.
            volumeHideTimer.restart()
        }


        // ========================================================
        // WORKSPACE EMOJIS
        // ========================================================

        property var workspaceEmojis: [
            "", // 1
            "💻", // 2
            "📁", // 3
            "🎵", // 4
            "💬", // 5
            "🎮", // 6
            "🎬", // 7
            "📝", // 8
            "⚙️", // 9
            "🏠"  // 10
        ]


        // Current focused Hyprland workspace.
        property int workspaceId: {
            if (Hyprland.focusedWorkspace)
                return Hyprland.focusedWorkspace.id

            return 1
        }


        // Select the emoji matching the current workspace.
        property string workspaceEmoji: {
            if (workspaceId >= 1
                    && workspaceId <= workspaceEmojis.length) {
                return workspaceEmojis[workspaceId - 1]
            }

            // Fallback for workspaces outside 1–10.
            return "📍"
        }


        // ========================================================
        // MEDIA
        // ========================================================

        // Select the first available MPRIS player.
        property var mediaPlayer:
            Mpris.players.values.length > 0
            ? Mpris.players.values[0]
            : null


        // Only switch into media mode while something is playing.
        property bool mediaPlaying:
            mediaPlayer !== null
            && mediaPlayer.isPlaying


        // Current track title.
        property string mediaTitle:
            mediaPlayer !== null
            ? mediaPlayer.trackTitle
            : ""


        // ========================================================
        // VOLUME COMMANDS
        // ========================================================

        // Increase volume.
        Process {
            id: volumeUp

            command: [
                "wpctl",
                "set-volume",
                "@DEFAULT_AUDIO_SINK@",
                "5%+"
            ]
        }


        // Decrease volume.
        Process {
            id: volumeDown

            command: [
                "wpctl",
                "set-volume",
                "@DEFAULT_AUDIO_SINK@",
                "5%-"
            ]
        }


        // Read the current volume.
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


        // ========================================================
        // TIMERS
        // ========================================================

        // Wait briefly for wpctl to finish before reading volume.
        Timer {
            id: volumeUpdateTimer

            interval: 100
            repeat: false

            onTriggered: {
                volumeGet.running = true
            }
        }


        // --------------------------------------------------------
        // VOLUME DISPLAY TIME
        // --------------------------------------------------------

        Timer {
            id: volumeHideTimer

            // Long enough to see the change, short enough to feel fast.
            interval: 1100
            repeat: false

            onTriggered: {

                // IMPORTANT:
                // Keep the volume UI visible while the island slides away.
                // This prevents the ugly "volume -> clock -> disappear"
                // flash from earlier versions.
                if (!root.islandHovered) {
                    root.islandVisible = false
                    volumeResetTimer.restart()
                } else {

                    // If the user is actively hovering the island,
                    // smoothly return to the normal content.
                    root.volumeVisible = false
                }
            }
        }


        // Reset the volume state AFTER the hide animation finishes.
        Timer {
            id: volumeResetTimer

            // Matches the island hide animation.
            interval: 300
            repeat: false

            onTriggered: {
                root.volumeVisible = false
            }
        }


        // --------------------------------------------------------
        // NORMAL HIDE DELAY
        // --------------------------------------------------------

        Timer {
            id: islandHideTimer

            // Gives the UI a comfortable delay when leaving it.
            interval: 650
            repeat: false

            onTriggered: {
                if (!root.islandHovered
                        && !root.volumeVisible) {
                    root.islandVisible = false
                }
            }
        }


        // ========================================================
        // DYNAMIC ISLAND
        // ========================================================

        Rectangle {
            id: island


            // ====================================================
            // SIZE SETTINGS
            // ====================================================

            property real minimumWidth: 200
            property real maximumWidth: 500


            // Approximate media title width.
            property real titleWidth:
                root.mediaTitle.length * 9


            // ----------------------------------------------------
            // DYNAMIC WIDTH
            // ----------------------------------------------------

            width: {

                // Volume mode has a fixed comfortable width.
                if (root.volumeVisible)
                    return 320

                // Normal idle mode.
                if (!root.mediaPlaying)
                    return minimumWidth

                // Media mode grows with the title.
                return Math.min(
                    maximumWidth,
                    Math.max(
                        minimumWidth,
                        180 + titleWidth
                    )
                )
            }


            height: 50

            // Keep the island horizontally centered.
            anchors.horizontalCenter: parent.horizontalCenter


            // ====================================================
            // APPEARANCE
            // ====================================================

            radius: height / 2

            // Near-black looks softer than pure black.
            color: "#111111"

            // ----------------------------------------------------
            // SHOW / HIDE POSITION
            // ----------------------------------------------------

            // Visible: 8px below top.
            // Hidden: completely above the screen.
            y: root.islandVisible ? 8 : -height


            // ====================================================
            // SMOOTH ANIMATIONS
            // ====================================================

            // Smooth width transitions.
            Behavior on width {
                NumberAnimation {
                    duration: 360
                    easing.type: Easing.InOutCubic
                }
            }


            // Smooth slide in/out.
            Behavior on y {
                NumberAnimation {
                    duration: 300
                    easing.type: Easing.OutCubic
                }
            }


            // ====================================================
            // IDLE CONTENT
            // ====================================================

            Item {
                id: idleContent

                anchors.fill: parent

                // Only visible when:
                // - No media is playing
                // - Volume UI isn't active
                visible: !root.mediaPlaying
                         && !root.volumeVisible


                // ------------------------------------------------
                // WORKSPACE EMOJI
                // ------------------------------------------------

                Text {
                    id: normalWorkspaceEmoji

                    text: root.workspaceEmoji

                    // Positioned just to the left of the clock.
                    anchors.right: centeredClock.left
                    anchors.rightMargin: 12

                    anchors.verticalCenter:
                        centeredClock.verticalCenter

                    // Fine adjustment for emoji font rendering.
                    anchors.verticalCenterOffset: 3

                    font.pixelSize: 20
                }


                // ------------------------------------------------
                // CLOCK
                // ------------------------------------------------

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

                    // Usually produces cleaner desktop text.
                    renderType: Text.NativeRendering
                }
            }


            // ====================================================
            // MEDIA CONTENT
            // ====================================================

            Item {
                id: mediaContent

                anchors.fill: parent

                visible: root.mediaPlaying
                         && !root.volumeVisible


                // ------------------------------------------------
                // LEFT SIDE: WORKSPACE + CLOCK
                // ------------------------------------------------

                Row {
                    anchors.left: parent.left
                    anchors.leftMargin: 25

                    anchors.verticalCenter:
                        parent.verticalCenter

                    spacing: 12


                    // Workspace emoji.
                    Text {
                        text: root.workspaceEmoji

                        font.pixelSize: 20

                        // Align emoji visually with clock.
                        anchors.verticalCenterOffset: 3
                    }


                    // Clock.
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


                // ------------------------------------------------
                // MEDIA TITLE
                // ------------------------------------------------

                Text {
                    anchors.right: parent.right
                    anchors.rightMargin: 25

                    anchors.verticalCenter:
                        parent.verticalCenter

                    // Prevent text from colliding with the clock.
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

                    // Long titles end with ...
                    elide: Text.ElideRight

                    horizontalAlignment:
                        Text.AlignRight
                }
            }


            // ====================================================
            // VOLUME CONTENT
            // ====================================================

            Item {
                id: volumeContent

                anchors.fill: parent

                visible: root.volumeVisible


                // ------------------------------------------------
                // VOLUME BAR
                // ------------------------------------------------

                Rectangle {
                    id: volumeBar

                    anchors.centerIn: parent

                    width: parent.width - 50
                    height: 8

                    radius: height / 2

                    // Track.
                    color: "#333333"


                    // Volume fill.
                    Rectangle {
                        width:
                            parent.width
                            * root.volumeValue

                        height: parent.height

                        radius: height / 2
                        color: "#FFFFFF"


                        // Smoothly animate volume changes.
                        Behavior on width {
                            NumberAnimation {
                                duration: 220
                                easing.type:
                                    Easing.OutCubic
                            }
                        }
                    }
                }
            }


            // ====================================================
            // ISLAND HOVER AREA
            // ====================================================

            MouseArea {
                anchors.fill: parent

                hoverEnabled: true


                onEntered: {

                    // Stop pending disappearance.
                    islandHideTimer.stop()

                    root.islandHovered = true
                    root.islandVisible = true
                }


                onExited: {

                    root.islandHovered = false

                    // Don't interrupt volume mode.
                    if (!root.volumeVisible) {
                        islandHideTimer.restart()
                    }
                }
            }
        }


        // ========================================================
        // EXACT TOP EDGE TRIGGER
        // ========================================================

        MouseArea {
            id: topTrigger

            // Only active directly above the island.
            width: island.width

            // One physical QML pixel high.
            height: 1

            anchors.top: parent.top
            anchors.horizontalCenter:
                parent.horizontalCenter

            hoverEnabled: true


            onEntered: {

                // Cancel any pending hide.
                islandHideTimer.stop()

                // Reveal island.
                root.islandVisible = true
            }
        }


        // ========================================================
        // CLOCK TIMER
        // ========================================================

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


        // ========================================================
        // GLOBAL VOLUME SHORTCUTS
        // ========================================================

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
}
