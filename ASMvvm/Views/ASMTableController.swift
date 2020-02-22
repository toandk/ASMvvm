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

open class ASMTableController<VM: IASMListViewModel>: ASMViewController<VM>, ASTableDelegate {
    
    public typealias CVM = VM.CellViewModelElement
    
    public var tableNode: ASTableNode!
    
    public var dataSource: RxASTableAnimatedDataSource<ASMSectionList<CVM>>?
    
    public init(viewModel: VM? = nil) {
        tableNode = ASTableNode(style: .plain)
        super.init(viewModel: viewModel, node: ASDisplayNode())
        self.node.automaticallyManagesSubnodes = true
        tableNode.view.separatorStyle = .none
        tableNode.leadingScreensForBatching = 1
        tableNode.delegate = self
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    open override func layoutNode(node: ASDisplayNode, constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let layout = ASInsetLayoutSpec(insets: UIEdgeInsets.zero, child: tableNode)
        let canShowLoading = viewModel?.canShowLoading ?? false
        return canShowLoading ? layoutCenterView(layout, view: loadingNode) : layout
    }
    
    /// Every time the viewModel changed, this method will be called again, so make sure to call super for ListPage to work
    open override func bindViewAndViewModel() {
        guard let tableNode = tableNode, dataSource == nil else { return }
        tableNode.rx.itemSelected.asObservable().subscribe(onNext: onItemSelected) => disposeBag
        
//        let configureCell: ASTableSectionedDataSource<ASMSectionList<CVM>>.ConfigureCell = { (_, tableNode, index, i) in
//            return self.configureCell(index: index, cellVM: i)
//        }
        let configureCellBlock: ASTableSectionedDataSource<ASMSectionList<CVM>>.ConfigureCellBlock = { (_, tableNode, index, i) in
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
        }) => disposeBag
        
        viewModel?.itemsSource.rxInnerSources
            .bind(to: tableNode.rx.items(dataSource: dataSource!)) => disposeBag
        bindLoadingNode()
    }
    
    open func bindLoadingNode() {
        let canShowLoading = viewModel?.canShowLoading ?? false
        if canShowLoading {
            viewModel?.rxIsLoading.distinctUntilChanged().asDriver(onErrorJustReturn: false).drive(onNext: { [weak self] (isLoading) in
                if isLoading {
                    self?.loadingNode.isHidden = false
                    self?.loadingNode.startAnimating()
                }
                else {
                    self?.loadingNode.stopAnimating()
                    self?.loadingNode.isHidden = true
                    self?.tableNode.view.getRefreshControl()?.endRefreshing()
                }
            }) => disposeBag
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
    
    open func configureCellBlock(index: IndexPath, cellVM: CVM) -> ASCellNodeBlock {
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
    
    public func getAnimationType() -> RowAnimation {
        return RowAnimation(insertAnimation: .fade, reloadAnimation: .none, deleteAnimation: .automatic)
    }
}
