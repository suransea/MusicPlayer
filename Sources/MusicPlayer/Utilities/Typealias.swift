//
//  Typealias.swift
//  LyricsX - https://github.com/ddddxxx/LyricsX
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

#if canImport(AppKit)

import AppKit

public typealias Image = NSImage

#elseif canImport(UIKit)

import UIKit

public typealias Image = UIImage

#else

public typealias Image = URL

#endif
