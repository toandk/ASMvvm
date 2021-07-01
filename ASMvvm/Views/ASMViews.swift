//
//  Views.swift
//  DTMvvm
//
//  Created by toandk on 2/14/20.
//  Copyright © 2020 toandk. All rights reserved.
//

import UIKit
import RxSwift
import AsyncDisplayKit

open class ASMEmptyNode: ASDisplayNode {
    let imgNode = ASImageNode()
    let textNode = ASTextNode()
    
    public override init() {
        super.init()
        automaticallyManagesSubnodes = true
    }
    
    open func setImage(_ image: UIImage?) {
        imgNode.image = image
        if let image = image {
            imgNode.style.preferredSize = image.size
        }
    }
    
    open func setText(_ text: NSAttributedString) {
        textNode.attributedText = text
    }
    
    override open func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let stack = ASStackLayoutSpec(direction: .vertical, spacing: 20, justifyContent: .center, alignItems: .center, children: [imgNode, textNode])
        return stack
    }
}

open class ASMLoadingNode: ASDisplayNode {
    
    public var indicatorView: UIActivityIndicatorView? {
        return self.view as? UIActivityIndicatorView
    }
    
    public var loadingStyle: UIActivityIndicatorView.Style = .gray {
        didSet {
            (self.view as? UIActivityIndicatorView)?.style = loadingStyle
        }
    }
    
    public convenience init(style: UIActivityIndicatorView.Style) {
        self.init(viewBlock: { () -> UIView in
            return UIActivityIndicatorView(style: style)
        }, didLoad: nil)
        self.style.preferredSize = CGSize(width: 40, height: 40)
    }
    
    public func startAnimating() {
        indicatorView?.startAnimating()
    }
    
    public func stopAnimating() {
        indicatorView?.stopAnimating()
    }
}

/// Based ASView that support ViewModel
open class ASMView<VM: IASMGenericViewModel>: ASDisplayNode, IASMView {
    
    public typealias ViewModelElement = VM
    
    public var disposeBag: DisposeBag? = DisposeBag()
    
    private var _viewModel: VM?
    public var viewModel: VM? {
        get { return _viewModel }
        set {
            if newValue != _viewModel {
                disposeBag = DisposeBag()
                
                _viewModel = newValue
                viewModelChanged()
            }
        }
    }
    
    public var anyViewModel: Any? {
        get { return _viewModel }
        set { viewModel = newValue as? VM }
    }
    
    public init(viewModel: VM? = nil) {
        self._viewModel = viewModel
        super.init()
        setup()
    }
    
    deinit { destroy() }
    
    func setup() {
        automaticallyManagesSubnodes = true
        backgroundColor = .clear
        
        initialize()
        viewModelChanged()
    }
    
    open func viewModelChanged() {
        bindViewAndViewModel()
        (_viewModel as? IReactable)?.reactIfNeeded()
    }
    
    open func destroy() {
        disposeBag = DisposeBag()
    }
    
    open func initialize() {}
    open func bindViewAndViewModel() {}
}

/// Master cell for ListPage
open class ASMCellNode<VM: IASMGenericViewModel>: ASCellNode, IASMView {
    
    open class var identifier: String {
        return String(describing: self)
    }
    
    public typealias ViewModelElement = VM
    
    public var disposeBag: DisposeBag? = DisposeBag()
    
    private var _viewModel: VM?
    public var viewModel: VM? {
        get { return _viewModel }
        set {
            if newValue != _viewModel {
                disposeBag = DisposeBag()
                
                _viewModel = newValue
                viewModelChanged()
            }
        }
    }
    
    public init(viewModel: VM) {
        super.init()
        self.viewModel = viewModel
        automaticallyManagesSubnodes = true
        selectionStyle = .none
        setup()
    }
    
    public var anyViewModel: Any? {
        get { return _viewModel }
        set { viewModel = newValue as? VM }
    }
    
    public override init() {
        super.init()
        setup()
    }
    
    deinit { destroy() }
    
    private func setup() {
        backgroundColor = .clear
        separatorInset = .zero
        layoutMargins = .zero
        preservesSuperviewLayoutMargins = false
        
        initialize()
    }
    
    open func viewModelChanged() {
        bindViewAndViewModel()
        (_viewModel as? IReactable)?.reactIfNeeded()
    }
    
    open func destroy() {
        disposeBag = DisposeBag()
    }
    
    open func initialize() {}
    open func bindViewAndViewModel() {}
}










