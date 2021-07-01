//
//  ASMViewController.swift
//  ASMvvm
//
//  Created by toandk on 2/14/20.
//  Copyright © 2020 toandk. All rights reserved.
//

import Foundation
import RxSwift
import AsyncDisplayKit

open class ASMViewController<VM: IASMViewModel>: ASDKViewController<ASDisplayNode>, IASMView {
    public var disposeBag: DisposeBag? = DisposeBag()
    
    public lazy var loadingNode = ASMLoadingNode(style: .gray)
    
    private var _viewModel: VM?
    public var viewModel: VM? {
        get { return _viewModel }
        set {
            if _viewModel != newValue {
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
    
    public init(viewModel: VM? = nil, node: ASDisplayNode) {
        _viewModel = viewModel
        super.init(node: node)
        self.node.automaticallyManagesSubnodes = true
        self.node.layoutSpecBlock = { [weak self] (node, size) -> ASLayoutSpec in
            guard let self = self else { return ASLayoutSpec() }
            return self.layoutNode(node: node, constrainedSize: size)
        }
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        initialize()
        viewModelChanged()
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        guard viewModel?.rxViewState.value != .willAppear else { return }
        super.viewWillAppear(animated)
        viewModel?.rxViewState.accept(.willAppear)
    }
    
    open override func viewDidAppear(_ animated: Bool) {
        guard viewModel?.rxViewState.value != .didAppear else { return }
        super.viewDidAppear(animated)
        viewModel?.rxViewState.accept(.didAppear)
    }
    
    open override func viewWillDisappear(_ animated: Bool) {
        guard viewModel?.rxViewState.value != .willDisappear else { return }
        super.viewWillDisappear(animated)
        viewModel?.rxViewState.accept(.willDisappear)
    }
    
    open override func viewDidDisappear(_ animated: Bool) {
        guard viewModel?.rxViewState.value != .didDisappear else { return }
        super.viewDidDisappear(animated)
        viewModel?.rxViewState.accept(.didDisappear)
    }
    
    /**
     Subclasses override this method to initialize UIs.
     
     This method is called in `viewDidLoad`. So try not to use `viewModel` property if you are
     not sure about it
     */
    open func initialize() {}
    
    /**
     Subclasses override this method to create data binding between view and viewModel.
     
     This method always happens, so subclasses should check if viewModel is nil or not. For example:
     ```
     guard let viewModel = viewModel else { return }
     ```
     */
    open func bindViewAndViewModel() {}
    
    deinit { destroy() }
    
    /**
     Subclasses override this method to remove all things related to `DisposeBag`.
     */
    open func destroy() {
        disposeBag = DisposeBag()
    }
    
    open func viewModelChanged() {
        bindViewAndViewModel()
        (_viewModel as? IReactable)?.reactIfNeeded()
    }
    
    open func layoutNode(node: ASDisplayNode, constrainedSize: ASSizeRange) -> ASLayoutSpec {
        return ASInsetLayoutSpec(insets: UIEdgeInsets.zero, child: node)
    }
    
    open func layoutCenterView(_ layout: ASLayoutSpec, view: ASDisplayNode? = nil) -> ASLayoutSpec {
        if view == nil {
            return layout
        }
        let centerBox = ASCenterLayoutSpec(centeringOptions: .XY, sizingOptions: .minimumXY, child: loadingNode)
        let background = ASBackgroundLayoutSpec(child: centerBox, background: layout)
        return background
    }
}
