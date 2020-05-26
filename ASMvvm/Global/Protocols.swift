//
//  Protocols.swift
//  ASMvvm
//
//  Created by toandk on 2/18/20.
//

import UIKit
import RxSwift
import RxCocoa
import Differentiator
import AsyncDisplayKit

/// ViewState for binding from ViewModel and View (Life cycle binding)
public enum ASMViewState {
    case none, willAppear, didAppear, willDisappear, didDisappear
}

/// Destroyable type for handling dispose bag and destroy it
public protocol IASMDestroyable: class {
    
    var disposeBag: DisposeBag? { get set }
    func destroy()
}

/// AnyView type for helping assign any viewModel to any view
public protocol IASMAnyView: class {
    
    /**
     Any value assign to this property will be delegate to its correct viewModel type
     */
    var anyViewModel: Any? { get set }
}

/// Base View type for the whole library
public protocol IASMView: IASMAnyView, IASMDestroyable {
    
    associatedtype ViewModelElement
    
    var viewModel: ViewModelElement? { get set }
    
    func initialize()
    func bindViewAndViewModel()
}

// MARK: - Viewmodel protocols
public protocol IdentifyEquatable: Equatable, IdentifiableType {
    
}

/// Base generic viewModel type, implement Destroyable and Equatable
public protocol IASMGenericViewModel: IASMDestroyable, IdentifyEquatable where Identity == String {
    
    associatedtype ModelElement
    
    var model: ModelElement? { get set }
    
    init(model: ModelElement?)
}

//public extension IASMGenericViewModel {
//    var identity : Identity {
//        return model.debugDescription
//    }
//}

/// Base ViewModel type for Page (UIViewController), View (UIVIew)
public protocol IASMViewModel: IASMGenericViewModel {
//    var rxShowLocalHud: BehaviorRelay<Bool> { get }
    var rxViewState: BehaviorRelay<ASMViewState> { get }
}

public protocol IASMListViewModel: IASMViewModel {
    
    associatedtype CellViewModelElement: IASMGenericViewModel
    
    var itemsSource: ASMReactiveCollection<CellViewModelElement> { get }
    var rxSelectedItem: BehaviorRelay<CellViewModelElement?> { get }
    var rxSelectedIndex: BehaviorRelay<IndexPath?> { get }
    
    var canShowLoading: Bool { get set }
    var canLoadMore: Bool { get set }
    var rxIsLoadingMore: BehaviorRelay<Bool> { get set }
    var rxIsLoading: BehaviorRelay<Bool> { get set }
    var fetchingContext: ASBatchContext? { get set }
    
    func selectedItemDidChange(_ cellViewModel: CellViewModelElement)
    func loadMoreItem()
}




