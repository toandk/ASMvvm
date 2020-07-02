//
//  UIKit+ASM.swift
//  ASMvvm
//
//  Created by toandk on 2/20/20.
//

import Foundation

public extension UITableView {
    func getRefreshControl() -> UIRefreshControl? {
        if #available(iOS 10.0, *) {
            return refreshControl
        }
        else {
            return subviews.first(where: { $0 is UIRefreshControl }) as? UIRefreshControl
        }
    }
    
    func addPullToRefresh() -> UIRefreshControl {
        let refreshControl = UIRefreshControl()
        if #available(iOS 10.0, *) {
            self.refreshControl = refreshControl
        } else {
            self.addSubview(refreshControl)
        }
        return refreshControl
    }
}

public extension UICollectionView {
    func getRefreshControl() -> UIRefreshControl? {
        if #available(iOS 10.0, *) {
            return refreshControl
        }
        else {
            return subviews.first(where: { $0 is UIRefreshControl }) as? UIRefreshControl
        }
    }
    
    func addPullToRefresh() -> UIRefreshControl {
        let refreshControl = UIRefreshControl()
        if #available(iOS 10.0, *) {
            self.refreshControl = refreshControl
        } else {
            self.addSubview(refreshControl)
        }
        return refreshControl
    }
}
