//
//  IMGLYResponseFilter.swift
//  imglyKit
//
//  Created by Carsten Przyluczky on 28/01/15.
//  Copyright (c) 2015 9elements GmbH. All rights reserved.
//

import Foundation
import CoreImage
#if SWIFT_PACKAGE
import imglyKit_ObjC
#endif

@objc public protocol IMGLYFilterTypeProtocol {
    var filterType: IMGLYFilterType { get }
}

/**
  A base clase for all response filters. Response filters use a look-up-table to
  map colors around, and create cool effects. These tables are handed over as image
  that contains serveral combination of r, g, and b values. Tools like photoshop can be used
  to create filters, using the identity-image and apply the desired operations onto it.
  Afterwards the so filtered image may be used as response map, as it represents the response the
  filter should have.
  In order to use the filter, the response-image is tranfered into a color-cube-map, that then
  can be used as input for a 'CIColorCube' filter, provided by core-image.
*/
open class IMGLYResponseFilter: CIFilter, IMGLYFilterTypeProtocol {
    /// A CIImage object that serves as input for the filter.
    @objc open var inputImage: CIImage?
    @objc open var inputIntensity = NSNumber(value: 1 as Float) {
        didSet {
            colorCubeData = nil
        }
    }
    public let responseName: String

    /// Returns the according filter type of the response filter.
    open var filterType: IMGLYFilterType {
        return .none
    }
    
    fileprivate var _colorCubeData: Data?
    fileprivate var colorCubeData: Data? {
        get {
            if _colorCubeData == nil {
                _colorCubeData = LUTToNSDataConverter.colorCubeData(fromLUTNamed: self.responseName, interpolatedWithIdentityLUTNamed: "Identity", withIntensity: self.inputIntensity.floatValue, cacheIdentityLUT: true)
            }
            
            return _colorCubeData
        }
        
        set {
            _colorCubeData = newValue
        }
    }
    
    init(responseName: String) {
        self.responseName = responseName
        super.init()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        self.responseName = ""
        super.init(coder: aDecoder)
    }
    
    open override var outputImage: CIImage? {
        guard let inputImage = inputImage else {
            return nil
        }
        
        var outputImage: CIImage?
        
        autoreleasepool {
            if let colorCubeData = colorCubeData, let filter = CIFilter(name: "CIColorCube") {
                filter.setValue(colorCubeData, forKey: "inputCubeData")
                filter.setValue(64, forKey: "inputCubeDimension")
                filter.setValue(inputImage, forKey: kCIInputImageKey)
                outputImage = filter.outputImage
            } else {
                outputImage = inputImage
            }
        }
        
        return outputImage
    }
}

extension IMGLYResponseFilter {
    open override func copy(with zone: NSZone?) -> Any {
        let copy = super.copy(with: zone) as! IMGLYResponseFilter
        copy.inputImage = inputImage?.copy(with: zone) as? CIImage
        copy.inputIntensity = inputIntensity
        return copy
    }
}
