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
        addSubnode(tableNode)
        tableNode.delegate = self
        tableNode.onDidLoad { [weak self] _ in
            self?.tableNode.view.separatorStyle = .none
        }
        
        super.setup()
    }
    
    /// Every time the viewModel changed, this method will be called again, so make sure to call super for ListPage to work
    open override func bindViewAndViewModel() {
        guard let tableNode = tableNode, dataSource == nil else { return }
        tableNode.rx.itemSelected.asObservable().subscribe(onNext: { [weak self] indexPath in
            self?.onItemSelected(indexPath)
        }).disposedBy(disposeBag)
        
        let configureCellBlock: ASTableSectionedDataSource<ASMSectionList<CVM>>.ConfigureCellBlock = { [weak self] (_, tableNode, index, i) in
            guard let self = self else {
                let cellBlock = { ASCellNode() }
                return cellBlock
            }
            return self.configureCellBlock(index: index, cellVM: i)
        }
        
        let animatedType = getAnimationType()
        dataSource = RxASTableAnimatedDataSource<ASMSectionList<CVM>>(
            animationConfiguration: animatedType,
            configureCellBlock: configureCellBlock
        )
        
        let ani1: RxASTableAnimatedDataSource<ASMSectionList<CVM>>.AnimationType = { _, _, _ in AnimationTransition.animated }
        let ani2: RxASTableAnimatedDataSource<ASMSectionList<CVM>>.AnimationType =  { _, _, _ in AnimationTransition.reload }
        viewModel?.itemsSource.rxAnimated.distinctUntilChanged().subscribe(onNext: { [weak self] animated in
            self?.dataSource?.animationType = animated ? ani1 : ani2
        }).disposedBy(disposeBag)
        
        if let dataSource = dataSource {
            viewModel?.itemsSource.rxInnerSources
                .bind(to: tableNode.rx.items(dataSource: dataSource))
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
    
    open func getAnimationType() -> RowAnimation {
        return RowAnimation(insertAnimation: .fade, reloadAnimation: .none, deleteAnimation: .automatic)
    }
    
    open func configureCellBlock(index: IndexPath, cellVM: CVM) -> ASCellNodeBlock {
        fatalError("Subclasses have to implement this method.")
    }
    
    open func shouldBatchFetch(for tableNode: ASTableNode) -> Bool {
        if let viewModel = viewModel,
        viewModel.itemsSource.countElements() > 0,
        viewModel.itemsSource.allElements().count > 0,
        !viewModel.rxIsLoading.value,
        !viewModel.rxIsLoadingMore.value {
            return true
        }
        return false
    }
    
    open func tableNode(_ tableNode: ASTableNode, willBeginBatchFetchWith context: ASBatchContext) {
        context.beginBatchFetching()
        viewModel?.fetchingContext = context
        viewModel?.loadMoreItem()
    }
    
    open func tableNode(_ tableNode: ASTableNode, willDisplayRowWith node: ASCellNode) {
        
    }
    
    open func tableNode(_ tableNode: ASTableNode, didEndDisplayingRowWith node: ASCellNode) {
        
    }
}
