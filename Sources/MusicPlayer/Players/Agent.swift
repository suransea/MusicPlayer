//
//  Agent.swift
//  LyricsX - https://github.com/ddddxxx/LyricsX
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import Observation

extension MusicPlayers {
    
    /// Delegate events to another player
    @Observable
    open class Agent {
        
        public var designatedPlayer: MusicPlayerProtocol?
        
        public init() {}
    }
}

extension MusicPlayers.Agent: MusicPlayerProtocol {
    
    public var name: MusicPlayerName? {
        return designatedPlayer?.name
    }
    
    public var currentTrack: MusicTrack? {
        return designatedPlayer?.currentTrack
    }
    
    public var playbackState: PlaybackState {
        return designatedPlayer?.playbackState ?? .stopped
    }
    
    public var playbackTime: TimeInterval {
        get { return designatedPlayer?.playbackTime ?? 0 }
        set { designatedPlayer?.playbackTime = newValue }
    }
    
    public func resume() {
        designatedPlayer?.resume()
    }
    
    public func pause() {
        designatedPlayer?.pause()
    }
    
    public func playPause() {
        designatedPlayer?.playPause()
    }
    
    public func skipToNextItem() {
        designatedPlayer?.skipToNextItem()
    }
    
    public func skipToPreviousItem() {
        designatedPlayer?.skipToPreviousItem()
    }
    
    public func updatePlayerState() {
        designatedPlayer?.updatePlayerState()
    }
}
