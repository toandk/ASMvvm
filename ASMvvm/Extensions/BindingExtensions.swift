//
//  BindingExtensions.swift
//  Action
//
//  Created by toandk on 3/31/20.
//

import Foundation
import RxSwift

public extension Disposable {
    func disposedBy(_ bag: DisposeBag?) {
        if let bag = bag {
            self.disposed(by: bag)
        }
    }
}
