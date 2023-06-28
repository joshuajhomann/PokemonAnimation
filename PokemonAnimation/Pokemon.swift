//
//  Pokemon.swift
//  Pokemon SwiftUI
//
//  Created by Joshua Homann on 6/20/19.
//  Copyright © 2019 com.josh. All rights reserved.
//

import Foundation
import SwiftUI

// MARK: - Pokemon
struct Pokemon: Codable, Hashable, Identifiable {
    let id: String
    let pkdxID, nationalID: Int
    let name: String
    let v: Int
    let imageURL: URL
    let pokemonDescription: String
    let artURL: URL
    let types: [String]

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case pkdxID = "pkdx_id"
        case nationalID = "national_id"
        case name
        case v = "__v"
        case imageURL = "image_url"
        case pokemonDescription = "description"
        case artURL = "art_url"
        case types
    }

    static var all: [Pokemon] {
        get async {
            async let all = {
                (Bundle.main.url(forResource: "pokemon", withExtension: "json")
                    .flatMap {try! Data(contentsOf: $0)}
                    .flatMap {try! JSONDecoder().decode([Pokemon].self, from: $0)} ?? [])
                .sorted { $0.name < $1.name }
            }()
            return await all
        }
    }

}
