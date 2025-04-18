//
//  UIImage-DominantColor.swift
//  JellyPlayerSwift
//
//  Created by Nikola Ristic on 4/18/25.
//

import CoreImage
import CoreImage.CIFilterBuiltins
import Foundation
import SwiftUI

extension UIImage {
    func dominantColor() -> Color {
        guard let ciImage = CIImage(image: self) else { return Color.black }
        
        let filter = CIFilter.areaAverage()
        filter.inputImage = ciImage
        filter.extent = ciImage.extent
        
        let context = CIContext()
        guard let outputImage = filter.outputImage else { return Color.black }
        
        var bitmap = [UInt8](repeating: 0, count: 4)
        context.render(outputImage, toBitmap: &bitmap, rowBytes: 4, bounds: outputImage.extent, format: .RGBA8, colorSpace: nil)
        
        return Color(red: Double(bitmap[0]) / 255.0,
                     green: Double(bitmap[1]) / 255.0,
                     blue: Double(bitmap[2]) / 255.0)
    }
}
