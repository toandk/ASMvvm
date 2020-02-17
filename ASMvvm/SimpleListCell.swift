//
//  SimpleListCell.swift
//  ASMvvm
//
//  Created by toandk on 2/14/20.
//  Copyright © 2020 toandk. All rights reserved.
//

import Foundation
import RxCocoa
import ObjectMapper
import AsyncDisplayKit

class SimpleModel: Model {
    
    var title = ""
    
    convenience init(withTitle title: String) {
        self.init(JSON: ["title": title])!
    }
    
    override func mapping(map: Map) {
        title <- map["title"]
    }
}

class SimpleListCell: ASMCellNode<SimpleListCellViewModel> {
    
    let titleLabel = ASTextNode()
    
    override func initialize() {
        super.initialize()
        self.addSubnode(titleLabel)
        self.style.height = ASDimension(unit: .points, value: 50)
    }
    
    override func bindViewAndViewModel() {
        guard let viewModel = viewModel else { return }
        
        viewModel.rxTitle.subscribe(onNext: { [weak self] (text) in
            self?.titleLabel.attributedText = NSAttributedString(string: text ?? "", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 15), NSAttributedString.Key.foregroundColor: UIColor.black])
        }) => disposeBag
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        return ASCenterLayoutSpec(centeringOptions: .Y, sizingOptions: .minimumX, child: titleLabel)
    }
}

class SimpleListCellViewModel: ASMCellViewModel<SimpleModel> {
    
    let rxTitle = BehaviorRelay<String?>(value: nil)
    
    override func react() {
        rxTitle.accept(model?.title)
    }
}
