/*
 * SPDX-FileCopyrightText: 2020 George Florea Bănuș <georgefb899@gmail.com>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import QtQml 2.12

import org.kde.kirigami 2.11 as Kirigami
import org.kde.haruna 1.0

import "Menus"

ToolBar {
    id: root

    property var audioTracks
    property var subtitleTracks

    position: ToolBar.Header
    visible: !window.isFullScreen() && GeneralSettings.showHeader

    RowLayout {
        id: headerRow

        width: parent.width

        Loader {
            active: !menuBarLoader.visible && header.visible
            visible: active
            sourceComponent: HamburgerMenu {
                position: HamburgerMenu.Position.Header
            }
        }

        ToolButton {
            action: appActions.openFileAction
            focusPolicy: Qt.NoFocus
        }

        ToolButton {
            action: appActions.openUrlAction
            focusPolicy: Qt.NoFocus
            MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.MiddleButton
                onClicked: {
                    openUrlTextField.clear()
                    openUrlTextField.paste()
                    window.openFile(openUrlTextField.text, true, false)
                }
            }
        }

        ToolSeparator {
            padding: vertical ? 10 : 2
            topPadding: vertical ? 2 : 10
            bottomPadding: vertical ? 2 : 10

            contentItem: Rectangle {
                implicitWidth: parent.vertical ? 1 : 24
                implicitHeight: parent.vertical ? 24 : 1
                color: Kirigami.Theme.textColor
            }
        }

        ToolButton {
            id: subtitleMenuButton

            text: i18n("Subtitles")
            icon.name: "add-subtitle"
            focusPolicy: Qt.NoFocus

            onReleased: {
                subtitleMenu.visible = !subtitleMenu.visible
            }

            Menu {
                id: subtitleMenu

                y: parent.height
                closePolicy: Popup.CloseOnReleaseOutsideParent

                MenuItem { action: appActions.openSubtitlesFileAction }

                Instantiator {
                    id: primarySubtitleMenuInstantiator
                    model: mpv.subtitleTracksModel
                    onObjectAdded: subtitleMenu.addItem( object )
                    onObjectRemoved: subtitleMenu.removeItem( object )
                    delegate: MenuItem {
                        enabled: model.id !== mpv.secondarySubtitleId || model.id === 0
                        checkable: true
                        checked: model.id === mpv.subtitleId
                        text: model.text
                        onTriggered: mpv.subtitleId = model.id
                    }
                }
            }
        }

        ToolButton {
            text: i18n("Audio")
            icon.name: "audio-volume-high"
            focusPolicy: Qt.NoFocus

            onReleased: {
                audioMenu.visible = !audioMenu.visible
            }

            Menu {
                id: audioMenu

                y: parent.height
                closePolicy: Popup.CloseOnReleaseOutsideParent

                Instantiator {
                    id: audioMenuInstantiator

                    model: mpv.audioTracksModel
                    onObjectAdded: audioMenu.insertItem( index, object )
                    onObjectRemoved: audioMenu.removeItem( object )
                    delegate: MenuItem {
                        id: audioMenuItem
                        checkable: true
                        checked: model.id === mpv.audioId
                        text: model.text
                        onTriggered: mpv.audioId = model.id
                    }
                }
            }
        }

        Item {
            Layout.fillWidth: true
        }

        ToolButton {
            action: appActions.configureAction
            focusPolicy: Qt.NoFocus
        }
    }
}
