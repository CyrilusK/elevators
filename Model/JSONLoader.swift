//
//  JSONLoader.swift
//  Elevators
//
//  Created by Cyril Kardash on 03.06.2024.
//

import Foundation

class JSONLoader {
    static func loadConfig(from url: String, completion: @escaping (BuildingConfig?) -> Void) {
        guard let url = URL(string: url) else {
            completion(nil)
            return
        }

        URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data, error == nil else {
                completion(nil)
                return
            }

            do {
                let config = try JSONDecoder().decode(BuildingConfig.self, from: data)
                completion(config)
            } catch {
                print("JSON decoding error: \(error)")
                completion(nil)
            }
        }.resume()
    }
}
