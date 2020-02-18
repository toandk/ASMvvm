//
//  NSAttributedString+ASM.swift
//  ASMvvm
//
//  Created by toandk on 2/17/20.
//  Copyright © 2020 toandk. All rights reserved.
//

import Foundation
import UIKit

extension NSAttributedString {

  static func attributedString(string: String?, fontSize size: CGFloat, color: UIColor?) -> NSAttributedString? {
    guard let string = string else { return nil }

    let attributes: [NSAttributedString.Key: Any] = [.foregroundColor: color ?? UIColor.black,
                      .font: UIFont.boldSystemFont(ofSize: size)]

    let attributedString = NSMutableAttributedString(string: string, attributes: attributes)

    return attributedString
  }
}
