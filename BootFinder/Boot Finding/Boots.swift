//
//  BootsDatabase.swift
//  BootFinder
//
//  Created by Skafos.ai on 7/5/19.
//  Copyright © 2019 Skafos, LLC. All rights reserved.
//

import Foundation

/// A boot!
struct Boot: Codable, Equatable {
  let id: String
  let name: String
  let brand: String
  let price: String
  let style: String?
  let rating: String?
  let imageURLString: String
  let buyURLString: String

  enum CodingKeys: String, CodingKey {
    case id = "boot_id"
    case name = "boot_name"
    case brand
    case price
    case style
    case rating
    case imageURLString = "image_source"
    case buyURLString = "buy_link"
  }
}

class BootsDB {
  let boots: [Boot]

  convenience init() {
    let bundledMetadataPath = Bundle.main.path(forResource: "boots_meta_data", ofType: "json")!
    self.init(metadataPath: bundledMetadataPath)!
  }

  init?(metadataPath: String) {
    guard
      let data = try? Data(contentsOf: URL(fileURLWithPath: metadataPath)),
      let boots = try? JSONDecoder().decode([Boot].self, from: data)
    else {
      return nil
    }

    self.boots = boots
  }

  subscript(index: Int) -> Boot? {
    return boots[index]
  }
}
