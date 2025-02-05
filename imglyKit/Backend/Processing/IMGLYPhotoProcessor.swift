//
//  IMGLYPhotoProcessor.swift
//  imglyKit
//
//  Created by Carsten Przyluczky on 03/02/15.
//  Copyright (c) 2015 9elements GmbH. All rights reserved.
//

import Foundation
import CoreImage
import UIKit

/**
All types of response-filters.
*/
@objc public enum IMGLYFilterType: Int {
    case none,
    k1,
    k2,
    k6,
    kDynamic,
    fridge,
    breeze,
    orchid,
    chest,
    front,
    fixie,
    x400,
    bw,
    ad1920,
    lenin,
    quozi,
    pola669,
    polaSX,
    food,
    glam,
    celsius,
    texas,
    lomo,
    goblin,
    sin,
    mellow,
    soft,
    blues,
    elder,
    sunset,
    evening,
    steel,
    seventies,
    highContrast,
    blueShadows,
    highcarb,
    eighties,
    colorful,
    lomo100,
    pro400,
    twilight,
    cottonCandy,
    pale,
    settled,
    cool,
    litho,
    ancient,
    pitched,
    lucid,
    creamy,
    keen,
    tender,
    bleached,
    bleachedBlue,
    fall,
    winter,
    sepiaHigh,
    summer,
    classic,
    noGreen,
    neat,
    plate
}

open class IMGLYPhotoProcessor {
    open class func processWithCIImage(_ image: CIImage, filters: [CIFilter]) -> CIImage? {
        if filters.count == 0 {
            return image
        }
        
        var currentImage: CIImage? = image
        
        for filter in filters {
            filter.setValue(currentImage, forKey:kCIInputImageKey)
            
            currentImage = filter.outputImage
        }
        
        if let currentImage = currentImage, currentImage.extent.isEmpty {
            return nil
        }
        
        return currentImage
    }
    
    open class func processWithUIImage(_ image: UIImage, filters: [CIFilter]) -> UIImage? {
        let imageOrientation = image.imageOrientation
        guard let coreImage = CIImage(image: image) else {
            return nil
        }
        
        let filteredCIImage = processWithCIImage(coreImage, filters: filters)
        let filteredCGImage = CIContext(options: nil).createCGImage(filteredCIImage!, from: filteredCIImage!.extent)
        return UIImage(cgImage: filteredCGImage!, scale: 1.0, orientation: imageOrientation)
    }
}
