//
//  Protocols.swift
//  DTMvvm
//
//  Created by Dao Duy Duong on 9/26/18.
//

import UIKit
import RxSwift
import RxCocoa
import Differentiator
import AsyncDisplayKit
import DTMvvm

// MARK: - Viewmodel protocols
public protocol IdentifyEquatable: Equatable, IdentifiableType {
    
}

/// Base generic viewModel type, implement Destroyable and Equatable
public protocol IASMGenericViewModel: IDestroyable, IdentifyEquatable where Identity == String {
    
    associatedtype ModelElement
    
    var model: ModelElement? { get set }
    
    init(model: ModelElement?)
}

public extension IASMGenericViewModel {
    var identity : Identity {
        return model.debugDescription
    }
}

/// Base ViewModel type for Page (UIViewController), View (UIVIew)
public protocol IASMViewModel: IASMGenericViewModel {
//    var rxShowLocalHud: BehaviorRelay<Bool> { get }
    
}

public protocol IASMListViewModel: IASMViewModel {
    
    associatedtype CellViewModelElement: IASMGenericViewModel
    
    var itemsSource: ASMReactiveCollection<CellViewModelElement> { get }
    var rxSelectedItem: BehaviorRelay<CellViewModelElement?> { get }
    var rxSelectedIndex: BehaviorRelay<IndexPath?> { get }
    
    func selectedItemDidChange(_ cellViewModel: CellViewModelElement)
}






