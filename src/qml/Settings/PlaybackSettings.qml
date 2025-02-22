/*
 * SPDX-FileCopyrightText: 2020 George Florea Bănuș <georgefb899@gmail.com>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12

import org.kde.kirigami 2.11 as Kirigami
import org.kde.haruna 1.0
import Haruna.Components 1.0

SettingsBasePage {
    id: root

    hasHelp: true
    helpFile: ":/PlaybackSettings.html"
    docPage: "help:/haruna/PlaybackSettings.html"

    GridLayout {
        id: content

        columns: 2

        // Seek Small Step
        Label {
            text: i18n("Seek small step")
            Layout.alignment: Qt.AlignRight
        }

        SpinBox {
            id: seekSmallStep
            editable: true
            from: 0
            to: 100
            value: GeneralSettings.seekSmallStep
            onValueChanged: {
                GeneralSettings.seekSmallStep = seekSmallStep.value
                GeneralSettings.save()
            }
        }

        // Seek Medium Step
        Label {
            text: i18n("Seek medium step")
            Layout.alignment: Qt.AlignRight
        }

        RowLayout {

            SpinBox {
                id: seekMediumStep
                editable: true
                from: 0
                to: 100
                value: GeneralSettings.seekMediumStep
                onValueChanged: {
                    GeneralSettings.seekMediumStep = seekMediumStep.value
                    GeneralSettings.save()
                }
            }

            ToolButton {
                icon.name: "documentinfo"
                checkable: true
                checked: false

                Layout.preferredHeight: seekMediumStep.height

                ToolTip {
                    text: i18n("This is also used for mouse wheel seeking, when mouse is over the progress bar")
                    visible: parent.checked
                    delay: 0
                    timeout: -1
                    closePolicy: Popup.NoAutoClose
                }
            }
        }

        // Seek Big Step
        Label {
            text: i18n("Seek big step")
            Layout.alignment: Qt.AlignRight
        }

        SpinBox {
            id: seekBigStep
            editable: true
            from: 0
            to: 100
            value: GeneralSettings.seekBigStep
            onValueChanged: {
                GeneralSettings.seekBigStep = seekBigStep.value
                GeneralSettings.save()
            }
        }

        Item { width: 1 }

        CheckBox {
            id: loadLastPlayedFileCheckBox

            text: i18n("Open last played file on startup")
            checked: PlaybackSettings.openLastPlayedFile
            onCheckedChanged: {
                PlaybackSettings.openLastPlayedFile = checked
                PlaybackSettings.save()
            }
        }

        Item { width: 1 }

        CheckBox {
            id: seekToLastPositionCheckBox

            text: i18n("Seek to last playback position")
            checked: PlaybackSettings.seekToLastPosition
            onCheckedChanged: {
                PlaybackSettings.seekToLastPosition = checked
                PlaybackSettings.save()
            }

            ToolTip {
                text: i18n("When opening a file that was played before, seek at the position it was last time.")
            }
        }

        Item { width: 1 }

        CheckBox {
            id: playOnResumeCheckBox

            text: i18n("Start playing")
            checked: PlaybackSettings.playOnResume
            enabled: seekToLastPositionCheckBox.checked
            onCheckedChanged: {
                PlaybackSettings.playOnResume = checked
                PlaybackSettings.save()
            }

            ToolTip {
                text: i18n("When opening a file that was played before, start playing it automatically.")
            }
        }

        Item { width: 1 }

        CheckBox {
            id: pauseOnMinimizeCheckBox

            text: i18n("Pause on minimize")
            checked: PlaybackSettings.pauseWhileMinimized
            onCheckedChanged: {
                PlaybackSettings.pauseWhileMinimized = checked
                PlaybackSettings.save()
            }

            ToolTip {
                text: i18n("Pauses the player while the window is minimized, playback resumes when restored.")
            }
        }

        Label {
            text: i18n("Hardware decoding")
            Layout.alignment: Qt.AlignRight
        }

        CheckBox {
            id: hwDecodingCheckBox
            text: checked ? i18n("Enabled") : i18n("Disabled")
            checked: PlaybackSettings.useHWDecoding
            onCheckedChanged: {
                mpv.hwDecoding = checked
                PlaybackSettings.useHWDecoding = checked
                PlaybackSettings.save()
            }
        }

        Item { width: 1 }

        ComboBox {
            id: hwDecodingComboBox

            enabled: hwDecodingCheckBox.checked
            textRole: "key"
            model: ListModel {
                id: hwDecModel
                ListElement { key: "auto"; }
                ListElement { key: "auto-safe"; }
                ListElement { key: "auto-copy"; }
                ListElement { key: "vdpau"; }
                ListElement { key: "vdpau-copy"; }
                ListElement { key: "vaapi"; }
                ListElement { key: "vaapi-copy"; }
                ListElement { key: "videotoolbox"; }
                ListElement { key: "videotoolbox-copy"; }
                ListElement { key: "dxva2"; }
                ListElement { key: "dxva2-copy"; }
                ListElement { key: "d3d11va"; }
                ListElement { key: "d3d11va-copy"; }
                ListElement { key: "mediacodec"; }
                ListElement { key: "mediacodec-copy"; }
                ListElement { key: "mmal"; }
                ListElement { key: "mmal-copy"; }
                ListElement { key: "nvdec"; }
                ListElement { key: "nvdec-copy"; }
                ListElement { key: "cuda"; }
                ListElement { key: "cuda-copy"; }
                ListElement { key: "crystalhd"; }
                ListElement { key: "rkmpp"; }
            }

            onActivated: {
                PlaybackSettings.hWDecoding = model.get(index).key
                PlaybackSettings.save()
                mpv.setProperty("hwdec", PlaybackSettings.hWDecoding)
            }

            Component.onCompleted: {
                for (let i = 0; i < hwDecModel.count; ++i) {
                    if (hwDecModel.get(i).key === PlaybackSettings.hWDecoding) {
                        currentIndex = i
                        break
                    }
                }
            }
        }

        Label {
            text: i18n("Remember time position")
            Layout.alignment: Qt.AlignRight
        }

        RowLayout {
            SpinBox {
                id: timePositionSaving
                from: -1
                to: 9999
                value: PlaybackSettings.minDurationToSavePosition

                onValueChanged: {
                    PlaybackSettings.minDurationToSavePosition = value
                    PlaybackSettings.save()
                }
            }

            LabelWithTooltip {
                text: {
                    if (timePositionSaving.value === -1) {
                        return i18n("Disabled")
                    } else if (timePositionSaving.value === 0) {
                        return i18n("For all files")
                    } else {
                        return i18np("For files longer than %1 minute",
                                     "For files longer than %1 minutes",
                                     timePositionSaving.value)
                    }
                }
                elide: Text.ElideRight
                Layout.fillWidth: true
            }
        }

        Item { width: 1 }

        RowLayout {
            enabled: timePositionSaving.value >= 0
            SpinBox {
                id: timePositionSaveInterval
                from: 1
                to: 300
                value: PlaybackSettings.savePositionInterval

                onValueChanged: {
                    PlaybackSettings.savePositionInterval = value
                    PlaybackSettings.save()
                }
            }

            LabelWithTooltip {
                text: i18np("Save position every %1 second",
                            "Save position every %1 seconds",
                            timePositionSaveInterval.value)
                elide: Text.ElideRight
                Layout.fillWidth: true
            }
        }

        Label {
            text: i18n("Skip chapters")
            Layout.alignment: Qt.AlignRight
        }

        CheckBox {
            id: skipChaptersCheckBox
            text: checked ? i18n("Enabled") : i18n("Disabled")
            checked: PlaybackSettings.skipChapters
            onCheckedChanged: {
                PlaybackSettings.skipChapters = checked
                PlaybackSettings.save()
            }
        }

        Item { width: 1 }

        CheckBox {
            text: i18n("Show osd message on skip")
            enabled: skipChaptersCheckBox.checked
            checked: PlaybackSettings.showOsdOnSkipChapters
            onCheckedChanged: {
                PlaybackSettings.showOsdOnSkipChapters = checked
                PlaybackSettings.save()
            }
        }

        Label {
            text: i18n("Skip words")
            enabled: skipChaptersCheckBox.checked
            Layout.alignment: Qt.AlignRight
        }

        TextField {
            text: PlaybackSettings.chaptersToSkip
            placeholderText: i18n("op, ed, chapter 1")
            enabled: skipChaptersCheckBox.checked
            Layout.fillWidth: true
            onEditingFinished: {
                PlaybackSettings.chaptersToSkip = text
                PlaybackSettings.save()
            }

            ToolTip {
                text: i18n("Skip chapters containing these words. Comma separated list.")
            }
        }

        // ------------------------------------
        // Youtube-dl format settings
        // ------------------------------------

        SettingsHeader {
            text: i18n("Youtube-dl")
            Layout.columnSpan: 2
            Layout.fillWidth: true
        }

        Label {
            text: i18n("Format selection")
            Layout.alignment: Qt.AlignRight
        }

        ComboBox {
            id: ytdlFormatComboBox
            property string hCurrentvalue: ""
            textRole: "key"
            model: ListModel {
                id: leftButtonModel
                ListElement { key: "Custom"; value: "" }
                ListElement { key: "Default"; value: "bestvideo+bestaudio/best" }
                ListElement { key: "2160"; value: "bestvideo[height<=2160]+bestaudio/best" }
                ListElement { key: "1440"; value: "bestvideo[height<=1440]+bestaudio/best" }
                ListElement { key: "1080"; value: "bestvideo[height<=1080]+bestaudio/best" }
                ListElement { key: "720"; value: "bestvideo[height<=720]+bestaudio/best" }
                ListElement { key: "480"; value: "bestvideo[height<=480]+bestaudio/best" }
            }
            ToolTip {
                text: i18n("Selects the best video with a height lower than or equal to the selected value.")
            }

            onActivated: {
                hCurrentvalue = model.get(index).value
                if (index === 0) {
                    ytdlFormatField.text = PlaybackSettings.ytdlFormat
                }
                if(index > 0) {
                    ytdlFormatField.focus = true
                    ytdlFormatField.text = model.get(index).value
                }
                PlaybackSettings.ytdlFormat = ytdlFormatField.text
                PlaybackSettings.save()
                mpv.setProperty("ytdl-format", PlaybackSettings.ytdlFormat)
            }

            Component.onCompleted: {
                let i = hIndexOfValue(PlaybackSettings.ytdlFormat)
                currentIndex = (i === -1) ? 0 : i
            }

            function hIndexOfValue(value) {
                switch(value) {
                case "bestvideo+bestaudio/best":
                    return 1
                case "bestvideo[height<=2160]+bestaudio/best":
                    return 2
                case "bestvideo[height<=1440]+bestaudio/best":
                    return 3
                case "bestvideo[height<=1080]+bestaudio/best":
                    return 4
                case "bestvideo[height<=720]+bestaudio/best":
                    return 5
                case "bestvideo[height<=480]+bestaudio/best":
                    return 6
                }
                return 0
            }
        }

        Item { width: 1 }

        TextField {
            id: ytdlFormatField
            text: PlaybackSettings.ytdlFormat
            onEditingFinished: {
                PlaybackSettings.ytdlFormat = text
                PlaybackSettings.save()
            }
            placeholderText: i18n("bestvideo+bestaudio/best")

            onTextChanged: {
                if (ytdlFormatComboBox.hCurrentvalue !== ytdlFormatField.text) {
                    ytdlFormatComboBox.currentIndex = 0
                    return;
                }
                if (ytdlFormatComboBox.hIndexOfValue(ytdlFormatField.text) !== -1) {
                    ytdlFormatComboBox.currentIndex = ytdlFormatComboBox.hIndexOfValue(ytdlFormatField.text)
                    return;
                }
            }

            Layout.fillWidth: true
        }

        // ------------------------------------
        // END - Youtube-dl format settings
        // ------------------------------------

        Item {
            width: Kirigami.Units.gridUnit
            height: Kirigami.Units.gridUnit
        }
    }
}
