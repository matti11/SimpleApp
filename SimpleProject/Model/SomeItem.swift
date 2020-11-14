//
//  SomeItem.swift
//  SimpleProject
//
//  Created by Mateusz Wojnar on 14/11/2020.
//  Copyright © 2020 Mateusz Wojnar. All rights reserved.
//

import Foundation

struct SomeItem: Codable {
    let data: DataClass
}

// MARK: - DataClass
struct DataClass: Codable {
    let baseURL: String
    let items: [Item]

    enum CodingKeys: String, CodingKey {
        case baseURL = "baseUrl"
        case items
    }
}

// MARK: - Item
struct Item: Codable {
    let url, title: String
    let id: Int?
}
