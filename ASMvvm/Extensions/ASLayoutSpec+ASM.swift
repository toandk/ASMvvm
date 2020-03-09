//
//  ASLayoutSpec+ASM.swift
//  Action
//
//  Created by toandk on 2/22/20.
//

import Foundation
import AsyncDisplayKit

// Support chaining
public extension ASStackLayoutSpec {
    func direction(_ value: ASStackLayoutDirection) -> ASStackLayoutSpec {
        direction = value
        return self
    }
    
    func spacing(_ value: CGFloat) -> ASStackLayoutSpec {
        self.spacing = value
        return self
    }
    
    func children(_ value: [ASLayoutElement]?) -> ASStackLayoutSpec {
        self.children = value
        return self
    }
    
    func alignItems(_ value: ASStackLayoutAlignItems) -> ASStackLayoutSpec {
        self.alignItems = value
        return self
    }
    
    func justifyContent(_ value: ASStackLayoutJustifyContent) -> ASStackLayoutSpec {
        self.justifyContent = value
        return self
    }
    
    func distributeChildrenEqually() -> ASStackLayoutSpec {
        let children = self.children ?? []
        for child in children {
            child.style.flexBasis = ASDimensionMakeWithFraction(CGFloat(1)/CGFloat(children.count))
        }
        return self
    }
}

public extension ASLayoutSpec {
    
}
