//
//  Scriptable.swift
//  LyricsX - https://github.com/ddddxxx/LyricsX
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

#if os(macOS)

import Foundation
import LXMusicPlayer
import Observation

extension MusicPlayers {
    
    @Observable
    public final class Scriptable {
        
        @ObservationIgnored
        private var player: LXScriptingMusicPlayer
        @ObservationIgnored
        private var observations: [NSKeyValueObservation] = []
        
        public private(set) var currentTrack: MusicTrack?
        public private(set) var playbackState: PlaybackState
        
        public var playerBundleID: String {
            return player.playerBundleID
        }
        
        public init?(name: MusicPlayerName) {
            guard let lxNmae = name.lxName, let player = LXScriptingMusicPlayer(name: lxNmae) else {
                return nil
            }
            self.player = player
            self.currentTrack = player.currentTrack.map(MusicTrack.init)
            self.playbackState = PlaybackState(lxState: player.playerState)
            observations.append(player.observe(\.currentTrack) { [weak self] (player, _) in
                guard let self = self else { return }
                self.currentTrack = player.currentTrack.map(MusicTrack.init)
            })
            observations.append(player.observe(\.playerState) { [weak self] (player, _) in
                guard let self = self else { return }
                self.playbackState = PlaybackState(lxState: player.playerState)
            })
        }
    }
}

extension MusicPlayers.Scriptable: MusicPlayerProtocol {
    
    public var name: MusicPlayerName? {
        return MusicPlayerName(lxName: player.playerName)!
    }
    
    public var playbackTime: TimeInterval {
        get { return player.playbackTime }
        set { player.playbackTime = newValue }
    }
    
    public func resume() {
        player.resume()
    }
    
    public func pause() {
        player.pause()
    }
    
    public func playPause() {
        player.playPause()
    }
    
    public func skipToNextItem() {
        player.skipToNextItem()
    }
    
    public func skipToPreviousItem() {
        player.skipToPreviousItem()
    }
    
    public func updatePlayerState() {
        player.updatePlayerState()
    }
}

extension MusicPlayerName {
    
    public static let scriptableCases: [MusicPlayerName] = [.appleMusic, .spotify, .vox, .audirvana, .swinsian]
}

#endif
