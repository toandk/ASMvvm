//
//  UIImage+ASM.swift
//  Action
//
//  Created by toandk on 2/18/20.
//

import Foundation
import UIKit

extension UIImage {

    func makeCircularImage(size: CGSize, borderWidth width: CGFloat, borderColor: UIColor = .white) -> UIImage {
        // make a CGRect with the image's size
        let circleRect = CGRect(origin: .zero, size: size)

        // begin the image context since we're not in a drawRect:
        UIGraphicsBeginImageContextWithOptions(circleRect.size, false, 0)

        // create a UIBezierPath circle
        let circle = UIBezierPath(roundedRect: circleRect, cornerRadius: circleRect.size.width * 0.5)

        // clip to the circle
        circle.addClip()

        borderColor.set()
        circle.fill()

        // draw the image in the circleRect *AFTER* the context is clipped
        self.draw(in: circleRect)

        // create a border (for white background pictures)
        if width > 0 {
          circle.lineWidth = width;
          borderColor.set()
          circle.stroke()
        }

        // get an image from the image context
        let roundedImage = UIGraphicsGetImageFromCurrentImageContext();

        // end the image context since we're not in a drawRect:
        UIGraphicsEndImageContext();

        return roundedImage ?? self
  }
  
  class func draw(size: CGSize, fillColor: UIColor, shapeClosure: () -> UIBezierPath) -> UIImage {
    UIGraphicsBeginImageContext(size)
    
    let path = shapeClosure()
    path.addClip()
    
    fillColor.setFill()
    path.fill()
    
    let image = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
    return image!
  }
}
