//
//  ArtworkService.swift
//  JellyPlayerSwift
//
//  Created by Nikola Ristic on 4/17/25.
//

import Foundation
import Kingfisher
import UIKit

class ArtworkService {
    func fetchArtwork(url: URL, completion: @escaping (UIImage?) -> Void) {
        KingfisherManager.shared.retrieveImage(with: url) { result in
            switch result {
            case .success(let value):
                DispatchQueue.main.async {
                    completion(value.image)
                }
            case .failure:
                DispatchQueue.main.async {
                    completion(nil)
                }
            }
        }
    }
}
