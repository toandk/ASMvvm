//
//  ASMListView.swift
//  ASMvvm
//
//  Created by toandk on 2/14/20.
//  Copyright © 2020 toandk. All rights reserved.
//

import UIKit
import AsyncDisplayKit
import RxASDataSources
import RxSwift
import RxCocoa

open class ASMCollectionView<VM: IASMListViewModel>: ASMView<VM> {

    public typealias CVM = VM.CellViewModelElement
    
    public var collectionNode: ASCollectionNode!
    
    public var dataSource: RxASCollectionAnimatedDataSource<ASMSectionList<CVM>>?
    
    public override init(viewModel: VM? = nil) {
        super.init(viewModel: viewModel)
        collectionNode = ASCollectionNode(collectionViewLayout: getCollectionFlowLayout())
        setup()
        bindViewAndViewModel()
    }
    
    override func setup() {
        guard let collectionNode = collectionNode else { return }
        collectionNode.backgroundColor = .clear
        addSubnode(collectionNode)
        
        super.setup()
    }
    
    open override func initialize() {
        
    }
    
    open override func destroy() {
        super.destroy()
//        collectionNode.removeFromSupernode()
        viewModel?.destroy()
    }
    
    /// Every time the viewModel changed, this method will be called again, so make sure to call super for ListPage to work
    open override func bindViewAndViewModel() {
        guard let collectionNode = collectionNode else { return }
        collectionNode.rx.itemSelected.asObservable().subscribe(onNext: { [weak self] indexPath in
            self?.onItemSelected(indexPath)
        }).disposedBy(disposeBag)
        
        let configureCell: ASCollectionSectionedDataSource<ASMSectionList<CVM>>.ConfigureCell = { (_, collectionNode, index, i) in
            return self.configureCell(index: index, cellVM: i)
        }
        
        dataSource = RxASCollectionAnimatedDataSource<ASMSectionList<CVM>>(
            configureCell: configureCell
        )
        
        if let dataSource = dataSource {
            viewModel?.itemsSource.rxInnerSources
                .bind(to: collectionNode.rx.items(dataSource: dataSource))
                .disposedBy(disposeBag)
        }
    }
    
    private func onItemSelected(_ indexPath: IndexPath) {
        guard let viewModel = self.viewModel else { return }
        let cellViewModel = viewModel.itemsSource[indexPath.row, indexPath.section]
        
        viewModel.rxSelectedItem.accept(cellViewModel)
        viewModel.rxSelectedIndex.accept(indexPath)
        
        viewModel.selectedItemDidChange(cellViewModel)
        
        selectedItemDidChange(cellViewModel)
    }
    
    open func selectedItemDidChange(_ cellViewModel: CVM) { }
    
    open func configureCell(index: IndexPath, cellVM: CVM) -> ASCellNode {
        fatalError("Subclasses have to implement this method.")
    }
    
    open func getCollectionFlowLayout() -> UICollectionViewFlowLayout {
        return UICollectionViewFlowLayout()
    }
}
