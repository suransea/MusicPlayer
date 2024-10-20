//
//  AppleMusiciOS.swift
//  LyricsX - https://github.com/ddddxxx/LyricsX
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

#if os(iOS)

import UIKit
import MediaPlayer
import Observation

extension MusicPlayers {

    @Observable
    public final class AppleMusic {
        
        private let musicPlayer = MPMusicPlayerController.systemMusicPlayer
        
        public var isAuthorized: Bool = MPMediaLibrary.authorizationStatus() == .authorized
        
        public private(set) var currentTrack: MusicTrack?
        public private(set) var playbackState: PlaybackState = .stopped
        
        public init() {
            musicPlayer.beginGeneratingPlaybackNotifications()
            
            let nc = NotificationCenter.default
            nc.addObserver(self, selector: #selector(updatePlayerState), name: .MPMusicPlayerControllerPlaybackStateDidChange, object: musicPlayer)
            nc.addObserver(self, selector: #selector(updatePlayerState), name: .MPMusicPlayerControllerNowPlayingItemDidChange, object: musicPlayer)
            nc.addObserver(self, selector: #selector(updatePlayerState), name: UIApplication.didBecomeActiveNotification, object: nil)
            nc.addObserver(self, selector: #selector(updatePlayerState), name: UIApplication.willEnterForegroundNotification, object: nil)
            
            updatePlayerState()
        }
        
        deinit {
            NotificationCenter.default.removeObserver(self)
            musicPlayer.endGeneratingPlaybackNotifications()
        }
    }
}

extension MusicPlayers.AppleMusic: MusicPlayerAuthorization {
    
    public func requestAuthorizationIfNeeded() {
        switch MPMediaLibrary.authorizationStatus() {
        case .notDetermined:
            MPMediaLibrary.requestAuthorization() { [weak self] _ in
                self?.objectWillChange.send()
                self?.updatePlayerState()
            }
        case .denied, .restricted:
            if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(settingsURL)
            }
        case .authorized:
            break
        @unknown default:
            break
        }
    }
}

extension MusicPlayers.AppleMusic: MusicPlayerProtocol {
    
    public var name: MusicPlayerName? {
        return .appleMusic
    }
    
    public var playbackTime: TimeInterval {
        get {
            return playbackState.time
        }
        set {
            guard isAuthorized else { return }
            musicPlayer.currentPlaybackTime = newValue
            playbackState = playbackState.withTime(newValue)
        }
    }
    
    public func resume() {
        guard isAuthorized else { return }
        musicPlayer.play()
    }
    
    public func pause() {
        guard isAuthorized else { return }
        musicPlayer.pause()
    }
    
    public func skipToNextItem() {
        guard isAuthorized else { return }
        musicPlayer.skipToNextItem()
    }
    
    public func skipToPreviousItem() {
        guard isAuthorized else { return }
        musicPlayer.skipToPreviousItem()
    }
    
    @objc public func updatePlayerState() {
        isAuthorized = MPMediaLibrary.authorizationStatus() == .authorized
        guard isAuthorized else {
            playbackState = .stopped
            currentTrack = nil
            return
        }
        let state = musicPlayer._playbackState
        let track = musicPlayer.nowPlayingItem
        if currentTrack?.id != track?.idString {
            currentTrack = track?.musicTrack
            playbackState = state
        } else if !playbackState.approximateEqual(to: state) {
            playbackState = state
        }
    }
}

/*
extension MusicPlayers.AppleMusic: PlaybackModeSettable {
    
    public var repeatMode: MusicRepeatMode {
        get {
            return musicPlayer.repeatMode.mode
        }
        set {
            musicPlayer.repeatMode = MPMusicRepeatMode(newValue)
        }
    }
    
    public var shuffleMode: MusicShuffleMode {
        get {
            return musicPlayer.shuffleMode.mode
        }
        set {
            musicPlayer.shuffleMode = MPMusicShuffleMode(newValue)
        }
    }
}
 */

// MARK: - Extension

private extension MPMediaItem {
    
    var idString: String {
        return String(format: "%X", persistentID)
    }
    
    var musicTrack: MusicTrack? {
        guard MPMediaLibrary.authorizationStatus() == .authorized else {
            return nil
        }
        let imageSize = CGSize(width: 600, height: 600)
        let artworkImage = artwork?.image(at: imageSize)
        return MusicTrack(id: idString,
                          title: title,
                          album: albumTitle,
                          artist: artist,
                          duration: playbackDuration,
                          fileURL: nil,
                          artwork: artworkImage)
    }
}

private extension MPMusicPlayerController {
    
    var _playbackState: PlaybackState {
        switch playbackState {
        case .stopped: return .stopped
        case .playing: return .playing(time: currentPlaybackTime)
        case .paused: return .paused(time: currentPlaybackTime)
        case .interrupted: return .paused(time: currentPlaybackTime)
        case .seekingForward: return .fastForwarding(time: currentPlaybackTime)
        case .seekingBackward: return .rewinding(time: currentPlaybackTime)
        @unknown default: return .stopped
        }
    }
}

/*
private extension MPMusicRepeatMode {
    
    var mode: RepeatMode {
        switch self {
        case .none: return .off
        case .one:  return .one
        case .all:  return .all
        // FIXME: What Mode?
        case .default: return .off
        @unknown default: return .off
        }
    }
    
    init(_ mode: RepeatMode) {
        switch mode {
        case .off: self = .none
        case .one: self = .one
        case .all: self = .all
        }
    }
}

private extension MPMusicShuffleMode {
    
    var mode: ShuffleMode {
        switch self {
        case .off: return .off
        case .songs: return .songs
        case .albums: return .albums
        // FIXME: What Mode?
        case .default: return .off
        @unknown default: return .off
        }
    }
    
    init(_ mode: ShuffleMode) {
        switch mode {
        case .off: self = .off
        case .songs: self = .songs
        case .albums: self = .albums
        case .groupings: self = .albums
        }
    }
}
*/
 
#endif
