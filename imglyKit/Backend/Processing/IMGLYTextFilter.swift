//
//  IMGLYTextFilter.swift
//  imglyKit
//
//  Created by Carsten Przyluczky on 05/03/15.
//  Copyright (c) 2015 9elements GmbH. All rights reserved.
//

import CoreImage
import UIKit

open class IMGLYTextFilter : CIFilter {
    /// A CIImage object that serves as input for the filter.
    @objc open var inputImage:CIImage?
    /// The text that should be rendered.
    open var text = ""
    /// The name of the used font.
    open var fontName = "Helvetica Neue"
    ///  This factor determins the font-size. Its a relative value that is multiplied with the image height
    ///  during the process.
    open var fontScaleFactor = CGFloat(1)
    /// The relative frame of the text within the image.
    open var frame = CGRect()
    /// The color of the text.
    open var color = UIColor.white
    
    override init() {
        super.init()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    /// Returns a CIImage object that encapsulates the operations configured in the filter. (read-only)
    open override var outputImage: CIImage? {
        guard let inputImage = inputImage else {
            return nil
        }
        
        if text.isEmpty {
            return inputImage
        }
        
        let textImage = createTextImage()
        
        if let cgImage = textImage.cgImage, let filter = CIFilter(name: "CISourceOverCompositing") {
            let textCIImage = CIImage(cgImage: cgImage)
            filter.setValue(inputImage, forKey: kCIInputBackgroundImageKey)
            filter.setValue(textCIImage, forKey: kCIInputImageKey)
            return filter.outputImage
        } else {
            return inputImage
        }
    }
    
    fileprivate func createTextImage() -> UIImage {
        let rect = inputImage!.extent
        let imageSize = rect.size
        UIGraphicsBeginImageContext(imageSize)
        UIColor(white: 1.0, alpha: 0.0).setFill()
        UIRectFill(CGRect(origin: CGPoint(), size: imageSize))
        
        let font = UIFont(name: fontName, size: fontScaleFactor * imageSize.height)
        text.draw(in: CGRect(x: frame.origin.x * imageSize.width, y: frame.origin.y * imageSize.height, width: frame.size.width * imageSize.width, height: frame.size.height * imageSize.width), withAttributes: [NSAttributedString.Key.font: font!, NSAttributedString.Key.foregroundColor: color])
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image!
    }
}

extension IMGLYTextFilter {
    open override func copy(with zone: NSZone?) -> Any {
        let copy = super.copy(with: zone) as! IMGLYTextFilter
        copy.inputImage = inputImage?.copy(with: zone) as? CIImage
        copy.text = (text as NSString).copy(with: zone) as! String
        copy.fontName = (fontName as NSString).copy(with: zone) as! String
        copy.fontScaleFactor = fontScaleFactor
        copy.frame = frame
        copy.color = color.copy(with: zone) as! UIColor
        
        return copy
    }
}
