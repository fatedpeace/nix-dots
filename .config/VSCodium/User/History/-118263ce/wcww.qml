
import Quickshell
import Quickshell.Hyprland
import Quickshell.Services.Mpris
import Quickshell.Io
import QtQuick

ShellRoot {
    PanelWindow {
        id: root

        // ========================================================
        // PANEL SETTINGS
        // ========================================================

        anchors.top: true

        // The island floats over the desktop instead of reserving
        // permanent space at the top of the screen.
        exclusiveZone: 0

        // Prevent the PanelWindow itself from drawing a background.
        color: "transparent"

        // Keep the actual window as narrow as the island.
        implicitWidth: island.width

        // 50px island + 8px top gap.
        implicitHeight: 58


        // ========================================================
        // FONTS
        // ========================================================

        // Used for the clock and media text.
        property string mainFont: "Roboto Mono"

        // Used ONLY for workspace Nerd Font icons.
        property string iconFont: "Iosevka Nerd Font"


        // ========================================================
        // ISLAND STATE
        // ========================================================

        property bool islandVisible: false
        property bool islandHovered: false


        // ========================================================
        // VOLUME STATE
        // ========================================================

        property bool volumeVisible: false

        // Volume is stored as a value between 0.0 and 1.0.
        property real volumeValue: 0.5


        // ========================================================
        // WORKSPACE ICONS
        // ========================================================

        // Workspace order:
        //
        //  1 = Terminal
        //  2 = Code
        //  3 = Documents
        //  4 = Virtual Machine
        //  5 = Files
        //  6 = Packages
        //  7 = Music / Media
        //  8 = NixOS
        //  9 = System / Configuration
        // 10 = Random / Scratch
        property var workspaceIcons: [
            "", // 1 - Terminal
            "󰘐", // 2 - Code
            "", // 3 - Documents
            "", // 4 - Virtual Machine
            "", // 5 - Files
            "", // 6 - Packages
            "", // 7 - Music / Media
            "", // 8 - NixOS
            "󰭹", // 9 - System / Config
            ""  // 10 - Random / Scratch
        ]

        // Current focused Hyprland workspace.
        property int workspaceId: {
            if (Hyprland.focusedWorkspace)
                return Hyprland.focusedWorkspace.id

            return 1
        }

        // Pick the correct icon for the active workspace.
        property string workspaceIcon: {
            if (workspaceId >= 1
                    && workspaceId <= workspaceIcons.length) {
                return workspaceIcons[workspaceId - 1]
            }

            // Fallback icon for workspaces outside 1–10.
            return "󰋜"
        }


        // ========================================================
        // MEDIA
        // ========================================================

        // Use the first available MPRIS player.
        property var mediaPlayer:
            Mpris.players.values.length > 0
            ? Mpris.players.values[0]
            : null

        // Only enter media mode when something is actively playing.
        property bool mediaPlaying:
            mediaPlayer !== null
            && mediaPlayer.isPlaying

        property string mediaTitle:
            mediaPlayer !== null
            ? mediaPlayer.trackTitle
            : ""


        // ========================================================
        // VOLUME FUNCTION
        // ========================================================

        function changeVolume(direction) {
            // Cancel any pending hide/reset.
            islandHideTimer.stop()
            volumeHideTimer.stop()
            volumeResetTimer.stop()

            // Change volume by 5%.
            if (direction > 0)
                volumeUp.running = true
            else
                volumeDown.running = true

            // Show the island immediately.
            islandVisible = true

            // Switch smoothly to volume mode.
            volumeVisible = true

            // Read the new volume after wpctl has updated it.
            volumeUpdateTimer.restart()

            // Restart the auto-hide timer.
            volumeHideTimer.restart()
        }


        // ========================================================
        // VOLUME COMMANDS
        // ========================================================

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

        // Read the current PipeWire volume.
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

        // Give wpctl a moment to update before reading the value.
        Timer {
            id: volumeUpdateTimer

            interval: 100
            repeat: false

            onTriggered: volumeGet.running = true
        }

        // How long the volume UI remains visible.
        Timer {
            id: volumeHideTimer

            interval: 1100
            repeat: false

            onTriggered: {
                if (!root.islandHovered) {
                    // Slide away while keeping the volume UI visible.
                    // This prevents a flash back to the normal content.
                    root.islandVisible = false
                    volumeResetTimer.restart()
                } else {
                    // If the mouse is over the island, return to
                    // normal content instead.
                    root.volumeVisible = false
                }
            }
        }

        // Reset volume mode after the slide-out animation finishes.
        Timer {
            id: volumeResetTimer

            interval: 300
            repeat: false

            onTriggered: root.volumeVisible = false
        }

        // Small delay before hiding after leaving the island.
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


        // ========================================================
        // DYNAMIC ISLAND
        // ========================================================

        Rectangle {
            id: island

            property real minimumWidth: 200
            property real maximumWidth: 500

            // Approximate width required for the media title.
            property real titleWidth:
                root.mediaTitle.length * 9


            // ====================================================
            // DYNAMIC WIDTH
            // ====================================================

            width: {
                // Volume mode needs room for the slider.
                if (root.volumeVisible)
                    return 320

                // Normal idle state.
                if (!root.mediaPlaying)
                    return minimumWidth

                // Grow based on the media title, up to 500px.
                return Math.min(
                    maximumWidth,
                    Math.max(
                        minimumWidth,
                        180 + titleWidth
                    )
                )
            }

            height: 50

            // Keep the island centered horizontally.
            anchors.horizontalCenter: parent.horizontalCenter


            // ====================================================
            // APPEARANCE
            // ====================================================

            radius: height / 2

            // Soft near-black.
            color: "#111111"


            // ====================================================
            // SHOW / HIDE
            // ====================================================

            // Visible = 8px from the top.
            // Hidden = completely above the screen.
            y: root.islandVisible ? 8 : -height


            // ====================================================
            // ANIMATIONS
            // ====================================================

            Behavior on width {
                NumberAnimation {
                    duration: 360
                    easing.type: Easing.InOutCubic
                }
            }

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

                visible: !root.mediaPlaying
                         && !root.volumeVisible


                // ------------------------------------------------
                // WORKSPACE ICON
                // ------------------------------------------------

                Text {
                    id: normalWorkspaceIcon

                    text: root.workspaceIcon

                    // Explicit Nerd Font for workspace glyphs.
                    font.family: root.iconFont
                    font.pixelSize: 23

                    // White icon.
                    color: "#FFFFFF"

                    // Place the icon just left of the clock.
                    anchors.right: centeredClock.left
                    anchors.rightMargin: 14

                    anchors.verticalCenter:
                        centeredClock.verticalCenter

                    // Optical correction for Nerd Font glyph alignment.
                    anchors.verticalCenterOffset: 1

                    renderType: Text.NativeRendering
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

                    // Roboto Mono for clean clock text.
                    font.family: root.mainFont
                    font.pixelSize: 18
                    font.weight: Font.DemiBold
                    font.letterSpacing: 0.2

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
                // LEFT: WORKSPACE + CLOCK
                // ------------------------------------------------

                Row {
                    anchors.left: parent.left
                    anchors.leftMargin: 25

                    anchors.verticalCenter:
                        parent.verticalCenter

                    spacing: 12


                    // Workspace Nerd Font icon.
                    Text {
                        text: root.workspaceIcon

                        font.family: root.iconFont
                        font.pixelSize: 23

                        color: "#FFFFFF"

                        // Optical alignment adjustment.
                        anchors.verticalCenterOffset: 1

                        renderType: Text.NativeRendering
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

                    // Leave room for the icon and clock.
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

                    // Long titles end cleanly with "...".
                    elide: Text.ElideRight

                    horizontalAlignment:
                        Text.AlignRight
                }
            }


            // ====================================================
            // VOLUME CONTENT
            // ====================================================

            Item {
                anchors.fill: parent

                visible: root.volumeVisible

                Rectangle {
                    anchors.centerIn: parent

                    width: parent.width - 50
                    height: 8

                    radius: height / 2

                    // Volume track.
                    color: "#333333"


                    // Filled portion of the volume bar.
                    Rectangle {
                        width:
                            parent.width
                            * root.volumeValue

                        height: parent.height

                        radius: height / 2

                        color: "#FFFFFF"


                        // Smooth slider movement.
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
            // ISLAND HOVER
            // ====================================================

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

                    // Only hide normally when volume mode isn't active.
                    if (!root.volumeVisible)
                        islandHideTimer.restart()
                }
            }
        }


        // ========================================================
        // 1PX TOP EDGE TRIGGER
        // ========================================================

        MouseArea {
            id: topTrigger

            // The trigger only covers the width of the island.
            // It won't interfere with the rest of the top edge.
            width: island.width
            height: 1

            anchors.top: parent.top
            anchors.horizontalCenter:
                parent.horizontalCenter

            hoverEnabled: true

            onEntered: {
                islandHideTimer.stop()
                root.islandVisible = true
            }
        }


        // ========================================================
        // CLOCK UPDATE
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

            onPressed: root.changeVolume(1)
        }

        GlobalShortcut {
            name: "volume-down"
            description: "Decrease volume"

            onPressed: root.changeVolume(-1)
        }
    }
}

