//
//  ViewModels.swift
//  ASMvvm
//
//  Created by Dao Duy Duong on 9/26/18.
//

import Foundation
import RxSwift
import RxCocoa
import AsyncDisplayKit

protocol IReactable {
    var isReacted: Bool { get set }
    
    func reactIfNeeded()
    func react()
}

/// A master based ViewModel for all
open class ASMViewModel<M>: NSObject, IASMViewModel, IReactable {
    
    public typealias ModelElement = M
    
    open var identity : Identity {
        return model.debugDescription
    }
    
    private var _model: M?
    public var model: M? {
        get { return _model }
        set {
            _model = newValue
            modelChanged()
        }
    }
    
    public let rxViewState = BehaviorRelay<ASMViewState>(value: .none)
    
    public var disposeBag: DisposeBag? = DisposeBag()
    
    var isReacted = false
    
    required public init(model: M? = nil) {
        _model = model
    }
    
    open func destroy() {
        disposeBag = DisposeBag()
    }
    
    deinit {
        destroy()
    }
    
    /**
     Everytime model changed, this method will get called. Good place to update our viewModel
     */
    open func modelChanged() {}
    
    /**
     This method will be called once. Good place to initialize our viewModel (listen, subscribe...) to any signals
     */
    open func react() {}
    
    func reactIfNeeded() {
        guard !isReacted else { return }
        isReacted = true
        
        react()
    }
}

/**
 A based ViewModel for ListPage.
 
 The idea for ListViewModel is that it will contain a list of CellViewModels
 By using this list, ListPage will render the cell and assign ViewModel to it respectively
 */
open class ASMListViewModel<M, CVM: IASMGenericViewModel>: ASMViewModel<M>, IASMListViewModel {
    
    open var canLoadMore: Bool = true
    open var canShowLoading = false
    
    open var rxIsLoadingMore = BehaviorRelay<Bool>(value: false)
    
    open var rxIsLoading = BehaviorRelay<Bool>(value: false)
    
    open func loadMoreItem() {
        
    }
    
    public typealias CellViewModelElement = CVM
    
    public typealias ItemsSourceType = [ASMSectionList<CVM>]
    
    public let itemsSource = ASMReactiveCollection<CVM>()
    public let rxSelectedItem = BehaviorRelay<CVM?>(value: nil)
    public let rxSelectedIndex = BehaviorRelay<IndexPath?>(value: nil)
    
    public weak var fetchingContext: ASBatchContext?
    
    required public init(model: M? = nil) {
        super.init(model: model)
    }
    
    open override func destroy() {
        super.destroy()
        
        itemsSource.forEach { (_, sectionList) in
            sectionList.forEach({ (_, cvm) in
                cvm.destroy()
            })
        }
    }
    
    open func selectedItemDidChange(_ cellViewModel: CVM) { }
    
    open func finishFetching() {
        self.rxIsLoading.accept(false)
        self.rxIsLoadingMore.accept(false)
        fetchingContext?.completeBatchFetching(true)
        fetchingContext = nil
    }
}

/**
 A based ViewModel for TableCell and CollectionCell
 
 The difference between ViewModel and CellViewModel is that CellViewModel does not contain NavigationService. Also CellViewModel
 contains its own index
 */

protocol IIndexable: class {
    var indexPath: IndexPath? { get set }
}

open class ASMCellViewModel<M>: NSObject, IASMGenericViewModel, IIndexable, IReactable {
    
    public typealias ModelElement = M
    
    open var identity : Identity {
        return model.debugDescription
    }
    
    private var _model: M?
    public var model: M? {
        get { return _model }
        set {
            _model = newValue
            modelChanged()
        }
    }
    
    /// Each cell will keep its own index path
    /// In some cases, each cell needs to use this index to create some customizations
    public internal(set) var indexPath: IndexPath?
    
    /// Bag for databindings
    public var disposeBag: DisposeBag? = DisposeBag()
    
    var isReacted = false
    
    public required init(model: M? = nil) {
        _model = model
    }
    
    open func destroy() {
        disposeBag = DisposeBag()
    }
    
    deinit { destroy() }
    
    open func modelChanged() {}
    open func react() {}
    
    func reactIfNeeded() {
        guard !isReacted else { return }
        isReacted = true
        
        react()
    }
}

/// A usefull CellViewModel based class to support ListPage and CollectionPage that have more than one cell identifier
open class ASMSuperCellViewModel: ASMCellViewModel<Any> {
    
    required public init(model: Any? = nil) {
        super.init(model: model)
    }
}














