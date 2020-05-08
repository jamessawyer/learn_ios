//
//  Candy.swift
//  UISearchBarDemo
//
//  Created by vivo on 4/3/20.
//  Copyright © 2020 vivo. All rights reserved.
//

import Foundation

struct Candy: Decodable {
    let name: String
    let category: Category
    
    enum Category: Decodable {
        case all
        case chocolate
        case hard
        case other
    }
}

extension Candy.Category: CaseIterable {}


extension Candy.Category: RawRepresentable {
    typealias RawValue = String
    
    init?(rawValue: Self.RawValue) {
        switch rawValue {
        case "All":
            self = .all
        case "Chocolate":
            self = .chocolate
        case "Hard":
            self = .hard
        case "Other":
            self = .other
        default:
            return nil
        }
    }
    
    var rawValue: RawValue {
        switch self {
        case .all: return "All"
        case .chocolate: return "Chocolate"
        case .hard: return "Hard"
        case .other: return "Other"
        }
    }
}

extension Candy {
    static func getCandies() -> [Candy] {
        guard
            let url = Bundle.main.url(forResource: "candies", withExtension: "json"),
            let data = try? Data(contentsOf: url)
            else {
                return []
        }
        do {
            let decoder = JSONDecoder()
            return try decoder.decode([Candy].self, from: data)
        } catch {
            return []
        }
    }
    
}
