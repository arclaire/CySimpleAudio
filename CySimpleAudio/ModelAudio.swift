//
//  ModelAudio.swift
//  CySimpleAudio
//
//  Created by Lucy on 09/10/21.
//

import Foundation
struct ModelTracks: Codable, Error {
    var tracks: ModelItems?

    enum CodingKeys: String, CodingKey {
        case tracks = "tracks"
    }
}

struct ModelItems: Codable, Error {
    var items: [ModelAudio]?
    enum CodingKeys: String, CodingKey {
        case items = "items"

    }
}

struct ModelAlbums: Codable, Error {
    var images: [ModelImages]?
    enum CodingKeys: String, CodingKey {
        case images = "images"

    }
}
struct ModelAudio: Codable, Error {
    var name: String?
    var artists: [ModelArtist]?
    var album: ModelAlbums?

    var preview_url: String?
    enum CodingKeys: String, CodingKey {
        case name = "name"
        case album = "album"
        case artists = "artists"
        case preview_url = "preview_url"
    }
}

struct ModelImages: Codable, Error {
    var url: String?
    var height: Double?
    var width: Double
    enum CodingKeys: String, CodingKey {
        case url = "url"
        case width
        case height
    }
}

struct ModelArtist: Codable, Error {
    var name: String?
    var type: String?

    enum CodingKeys: String, CodingKey {
        case name = "name"
        case type = "type"
    }
}
