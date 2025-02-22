/*
 * SPDX-FileCopyrightText: 2020 George Florea Bănuș <georgefb899@gmail.com>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

#include "playlistmodel.h"
#include "playlistitem.h"
#include "application.h"
#include "global.h"
#include "worker.h"

#include <KFileItem>
#include <QCollator>
#include <QDirIterator>
#include <QFileInfo>
#include <QUrl>

PlayListModel::PlayListModel(QObject *parent)
    : QAbstractListModel(parent)
{
    m_config = KSharedConfig::openConfig(Global::instance()->appConfigFilePath());
    connect(this, &PlayListModel::videoAdded,
            Worker::instance(), &Worker::getMetaData);

    connect(Worker::instance(), &Worker::metaDataReady, this, [ = ](int i, KFileMetaData::PropertyMap metaData) {
        auto duration = metaData[KFileMetaData::Property::Duration].toInt();
        auto title = metaData[KFileMetaData::Property::Title].toString();

        m_playList[i]->setDuration(Application::formatTime(duration));
        m_playList[i]->setMediaTitle(title);

        Q_EMIT dataChanged(index(i, 0), index(i, 0));

    });
}

int PlayListModel::rowCount(const QModelIndex &parent) const
{
    if (parent.isValid())
        return 0;

    return m_playList.size();
}

QVariant PlayListModel::data(const QModelIndex &index, int role) const
{
    if (!index.isValid() || m_playList.empty())
        return QVariant();

    auto playListItem = m_playList.at(index.row());
    switch (role) {
    case NameRole:
        return QVariant(playListItem->fileName());
    case TitleRole:
        return playListItem->mediaTitle().isEmpty()
                ? QVariant(playListItem->fileName())
                : QVariant(playListItem->mediaTitle());
    case PathRole:
        return QVariant(playListItem->filePath());
    case DurationRole:
        return QVariant(playListItem->duration());
    case PlayingRole:
        return QVariant(playListItem->isPlaying());
    case FolderPathRole:
        return QVariant(playListItem->folderPath());
    }

    return QVariant();
}

QHash<int, QByteArray> PlayListModel::roleNames() const
{
    QHash<int, QByteArray> roles;
    roles[NameRole] = "name";
    roles[TitleRole] = "title";
    roles[PathRole] = "path";
    roles[FolderPathRole] = "folderPath";
    roles[DurationRole] = "duration";
    roles[PlayingRole] = "isPlaying";
    return roles;
}

void PlayListModel::getVideos(QString path)
{
    clear();
    QUrl openedUrl(path);
    QFileInfo openedFileInfo(openedUrl.toLocalFile());
    QStringList siblingFiles;
    if (openedFileInfo.exists() && openedFileInfo.isFile()) {
        QDirIterator it(openedFileInfo.absolutePath(), QDir::Files, QDirIterator::NoIteratorFlags);
        while (it.hasNext()) {
            QString siblingFile = it.next();
            QFileInfo siblingFileInfo(siblingFile);
            QUrl siblingUrl(siblingFile);
            siblingUrl.setScheme(openedUrl.scheme());
            QString mimeType = Application::mimeType(siblingUrl);
            if (siblingFileInfo.exists() && (mimeType.startsWith("video/") || mimeType.startsWith("audio/"))) {
                siblingFiles.append(siblingFileInfo.absoluteFilePath());
            }
        }

        QCollator collator;
        collator.setNumericMode(true);
        std::sort(siblingFiles.begin(), siblingFiles.end(), collator);

        beginInsertRows(QModelIndex(), 0, siblingFiles.count() - 1);
        for (int i = 0; i < siblingFiles.count(); ++i) {
            auto video = new PlayListItem(siblingFiles.at(i), i, this);
            m_playList.append(video);
            if (path == siblingFiles.at(i)) {
                setPlayingVideo(i);
            }
            Q_EMIT videoAdded(i, video->filePath());
        }
        endInsertRows();
    }
}

void PlayListModel::appendVideo(QString videoPath)
{
    videoPath = QUrl(videoPath).toLocalFile().isEmpty() ? videoPath : QUrl(videoPath).toLocalFile();
    QFileInfo videoPathInfo(videoPath);
    QStringList videoFiles;
    if (videoPathInfo.exists() && videoPathInfo.isFile()) {
        QString mimeType = Application::mimeType(videoPathInfo.absoluteFilePath());
        if (mimeType.startsWith("video/") || mimeType.startsWith("audio/")) {
            videoFiles.append(videoPathInfo.absoluteFilePath());
        }
    }

    if (videoFiles.isEmpty()) {
        return;
    }

    int row {m_playList.count()};
    beginInsertRows(QModelIndex(), row, m_playList.count());

    auto video = new PlayListItem(videoFiles.at(row), row, this);
    m_playList.append(video);
    setPlayingVideo(row);
    Q_EMIT videoAdded(row, video->filePath());

    endInsertRows();
}

Playlist PlayListModel::items() const
{
    return m_playList;
}

QString PlayListModel::configFolder()
{

    auto configPath = QStandardPaths::writableLocation(m_config->locationType());
    auto configFilePath = configPath.append(QStringLiteral("/")).append(m_config->name());
    QFileInfo fileInfo(configFilePath);

    return fileInfo.absolutePath();
}

Playlist PlayListModel::getPlayList() const
{
    return m_playList;
}

void PlayListModel::setPlayList(const Playlist &playList)
{
    beginInsertRows(QModelIndex(), 0, playList.size() - 1);
    m_playList = playList;
    endInsertRows();
}

int PlayListModel::getPlayingVideo() const
{
    return m_playingVideo;
}

void PlayListModel::clear()
{
    m_playingVideo = 0;
    qDeleteAll(m_playList);
    beginResetModel();
    m_playList.clear();
    endResetModel();
}

QString PlayListModel::getPath(int i)
{
    // when restoring a youtube playlist
    // ensure the requested path is valid
    if (m_playList.isEmpty()) {
        return QString();
    }
    if (m_playList.size() <= i) {
        return m_playList[0]->filePath();
    }
    return m_playList[i]->filePath();
}

PlayListItem *PlayListModel::getItem(int i)
{
    if (m_playList.size() <= i) {
        return m_playList[0];
    }
    return m_playList[i];
}

void PlayListModel::setPlayingVideo(int playingVideo)
{
    // unset current playing video
    m_playList[m_playingVideo]->setIsPlaying(false);
    Q_EMIT dataChanged(index(m_playingVideo, 0), index(m_playingVideo, 0));

    // set new playing video
    m_playList[playingVideo]->setIsPlaying(true);
    Q_EMIT dataChanged(index(playingVideo, 0), index(playingVideo, 0));

    m_playingVideo = playingVideo;
    Q_EMIT playingVideoChanged();
}
