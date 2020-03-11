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
import DTMvvm

open class ASMListView<VM: IASMListViewModel>: ASMView<VM>, ASTableDelegate {

    public typealias CVM = VM.CellViewModelElement
    
    public var tableNode: ASTableNode!
    
    public var dataSource: RxASTableAnimatedDataSource<ASMSectionList<CVM>>?
    
    public override init(viewModel: VM? = nil) {
        tableNode = ASTableNode(style: .plain)
        super.init(viewModel: viewModel)
    }
    
    open override func destroy() {
        super.destroy()
        viewModel?.destroy()
    }
    
    override func setup() {
        tableNode.backgroundColor = .clear
        tableNode.view.separatorStyle = .none
        addSubnode(tableNode)
        tableNode.delegate = self
        
        super.setup()
    }
    
    /// Every time the viewModel changed, this method will be called again, so make sure to call super for ListPage to work
    open override func bindViewAndViewModel() {
        guard let tableNode = tableNode, dataSource == nil else { return }
        tableNode.rx.itemSelected.asObservable().subscribe(onNext: onItemSelected) => disposeBag
        
        let configureCell: ASTableSectionedDataSource<ASMSectionList<CVM>>.ConfigureCell = { (_, tableNode, index, i) in
            return self.configureCell(index: index, cellVM: i)
        }
        
        dataSource = RxASTableAnimatedDataSource<ASMSectionList<CVM>>(
            configureCell: configureCell
        )
        
        viewModel?.itemsSource.rxInnerSources
            .bind(to: tableNode.rx.items(dataSource: dataSource!)) => disposeBag
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
    
    public func shouldBatchFetch(for tableNode: ASTableNode) -> Bool {
        if let viewModel = viewModel,
        viewModel.itemsSource.countElements() > 0,
        viewModel.canLoadMore,
        !viewModel.rxIsLoading.value,
        !viewModel.rxIsLoadingMore.value {
            return true
        }
        return false
    }
    
    public func tableNode(_ tableNode: ASTableNode, willBeginBatchFetchWith context: ASBatchContext) {
        context.beginBatchFetching()
        viewModel?.fetchingContext = context
        viewModel?.loadMoreItem()
    }
}
