//
//  ASMTableController.swift
//  ASMvvm
//
//  Created by toandk on 2/14/20.
//  Copyright © 2020 toandk. All rights reserved.
//

import Foundation
import AsyncDisplayKit
import RxASDataSources
import DTMvvm

open class ASMCollectionController<VM: IASMListViewModel>: ASMViewController<VM> {
    
    public typealias CVM = VM.CellViewModelElement
    
    public var collectionNode: ASCollectionNode!
    
    public var dataSource: RxASCollectionAnimatedDataSource<ASMSectionList<CVM>>?
    
    public init(viewModel: VM? = nil) {
        super.init(viewModel: viewModel, node: ASDisplayNode())
        collectionNode = ASCollectionNode(collectionViewLayout: getCollectionFlowLayout())
        self.node.addSubnode(collectionNode)        
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    open override func destroy() {
        super.destroy()
        collectionNode.removeFromSupernode()
    }
    
    open override func layoutNode(node: ASDisplayNode, constrainedSize: ASSizeRange) -> ASLayoutSpec {
        return ASInsetLayoutSpec(insets: UIEdgeInsets.zero, child: collectionNode)
    }
    
    /// Every time the viewModel changed, this method will be called again, so make sure to call super for ListPage to work
    open override func bindViewAndViewModel() {
        collectionNode.rx.itemSelected.asObservable().subscribe(onNext: onItemSelected) => disposeBag
        
        let configureCell: RxASCollectionAnimatedDataSource<ASMSectionList<CVM>>.ConfigureCell = { (_, tableNode, index, i) in
            return self.configureCell(index: index, cellVM: i)
        }
        
        dataSource = RxASCollectionAnimatedDataSource<ASMSectionList<CVM>>(
            configureCell: configureCell
        )
        
        viewModel?.itemsSource.rxInnerSources
            .bind(to: collectionNode.rx.items(dataSource: dataSource!)) => disposeBag
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
