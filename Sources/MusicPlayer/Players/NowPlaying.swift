//
//  NowPlaying.swift
//  LyricsX - https://github.com/ddddxxx/LyricsX
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import Observation

extension MusicPlayers {
    
    public class NowPlaying: Agent {
        
        override public var designatedPlayer: MusicPlayerProtocol? {
            get { return super.designatedPlayer }
            set { preconditionFailure("setting currentPlayer for MusicPlayers.NowPlaying is forbidden") }
        }
        
        public var players: [MusicPlayerProtocol] {
            didSet {
                selectNewPlayer()
            }
        }
        
        public init(players: [MusicPlayerProtocol]) {
            self.players = players
            super.init()
            selectingNewPlayer()
        }

        private func selectingNewPlayer() {
            selectNewPlayer()
            withObservationTracking {
                _ = self.designatedPlayer
                _ = self.playbackState
            } onChange: { [weak self] in
                guard let self = self else { return }
                Task { self.selectingNewPlayer() }
            }
        }
        
        private func selectNewPlayer() {
            var newPlayer: MusicPlayerProtocol?
            if designatedPlayer?.playbackState.isPlaying == true {
                newPlayer = designatedPlayer
            } else if let playing = players.first(where: { $0.playbackState.isPlaying }) {
                newPlayer = playing
            } else if let running = players.first(where: { $0.playbackState != .stopped }) {
                newPlayer = running
            }
            if newPlayer !== designatedPlayer {
                super.designatedPlayer = newPlayer
            }
        }
    }
}
