<!--
SPDX-FileCopyrightText: 2020 George Florea Bănuș <georgefb899@gmail.com>

SPDX-License-Identifier: CC-BY-4.0
-->

### ⚠ Bugs and feature requests go to https://bugs.kde.org

----

#### Donate: [GitHub Sponsors](https://github.com/sponsors/g-fb) | [Liberapay](https://liberapay.com/gfb/) | [PayPal](https://paypal.me/georgefloreabanus)

# Haruna Video Player

Haruna is an open source video player built with Qt/QML and libmpv.

![Haruna main window](./data/screenshots/haruna-dark.png)
[More Screenshots](./Screenshots.md)

# Install

https://flathub.org/apps/details/org.kde.haruna
### Stable
```
flatpak install flathub org.kde.haruna
flatpak run org.kde.haruna
```

### Beta
```
flatpak remote-add flathub-beta https://flathub.org/beta-repo/flathub-beta.flatpakrepo
flatpak install flathub-beta org.kde.haruna
flatpak run --branch=beta org.kde.haruna
```

[Flatpak setup guide](https://flatpak.org/setup/)

# AppImage

* Download appimage from [Releases](https://github.com/g-fb/haruna/releases)
* Make executable `chmod +x Haruna*.AppImage`
* Run
* Optional, use [AppImageLauncher](https://github.com/TheAssassin/AppImageLauncher)
* Note: On Fedora/Redhat users may need to install `libnsl` (`sudo dnf install libnsl`)

# Features

these are just some features that set Haruna apart from others players

- play online videos, through youtube-dl

- toggle playlist with mouse-over, playlist overlays the video

- auto skip chapter containing certain words

- configurable shortcuts and mouse buttons

- quick jump to next chapter by middle click on progress bar

# Dependencies

### Build time
- Libmpv
- FFmpeg
- Qt5Core
- Qt5DBus
- Qt5Qml
- Qt5Quick
- Qt5QuickControls2
- ExtraCmakeModules
- KF5Config
- KF5CoreAddons
- KF5FileMetaData
- KF5I18n
- KF5IconThemes
- KF5KIO
- KF5Kirigami2
- KF5XmlGui
- KF5DocTools

### Runtime
- Breeze icons
- Breeze widgets style
- QQC2-Desktop-Style
- Youtube-dl

# Build

```bash
git clone https://invent.kde.org/multimedia/haruna.git
cd haruna
# append `-D CMAKE_INSTALL_PREFIX:PATH=/your/custom/path` to install to a custom location
cmake -B build -G Ninja
cmake --build build
cmake --install build
```
