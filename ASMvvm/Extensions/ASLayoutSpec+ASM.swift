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
}

public extension ASLayoutSpec {
    
}
