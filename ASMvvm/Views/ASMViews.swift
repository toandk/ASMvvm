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

/// Based ASView that support ViewModel
open class ASMView<VM: IGenericViewModel>: ASDisplayNode, IView {
    
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
        backgroundColor = .clear
        
        initialize()
        viewModelChanged()
    }
    
    private func viewModelChanged() {
        bindViewAndViewModel()
        (_viewModel as? IReactable)?.reactIfNeeded()
    }
    
    open func destroy() {
        disposeBag = DisposeBag()
        viewModel?.destroy()
    }
    
    open func initialize() {}
    open func bindViewAndViewModel() {}
}

/// Master cell for ListPage
open class ASMCellNode<VM: IGenericViewModel>: ASCellNode, IView {
    
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
    
    private func viewModelChanged() {
        bindViewAndViewModel()
        (_viewModel as? IReactable)?.reactIfNeeded()
    }
    
    open func destroy() {
        disposeBag = DisposeBag()
        viewModel?.destroy()
    }
    
    open func initialize() {}
    open func bindViewAndViewModel() {}
}










