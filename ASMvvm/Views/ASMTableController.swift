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
import RxSwift
import RxCocoa

open class ASMTableController<VM: IASMListViewModel>: ASMViewController<VM>, ASTableDelegate {
    
    public typealias CVM = VM.CellViewModelElement
    
    public var tableNode: ASTableNode!
    
    public var dataSource: RxASTableAnimatedDataSource<ASMSectionList<CVM>>?
    private var lastTimeFetching: TimeInterval = 0
    private var FETCH_THREDHOLD: TimeInterval = 1 // Only allow fetching after 1 second
    
    
    public init(viewModel: VM? = nil) {
        tableNode = ASTableNode(style: .plain)
        super.init(viewModel: viewModel, node: ASDisplayNode())
        tableNode.leadingScreensForBatching = 1
        tableNode.delegate = self
        tableNode.onDidLoad { [weak self] _ in
            self?.tableNode.view.separatorStyle = .none
        }
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    open func beginRefreshing() {
        guard let refreshControl = tableNode.view.getRefreshControl() else { return }
        refreshControl.beginRefreshing()
        
//        tableNode.contentInset = UIEdgeInsets(top: 50, left: 0, bottom: 0, right: 0)
    }
    
    open func stopRefreshing() {
        let refreshControl = self.tableNode.view.getRefreshControl()
        if refreshControl?.isRefreshing == true {
            refreshControl?.endRefreshing()
            self.tableNode.contentInset = .zero
        }
    }
    
    open override func layoutNode(node: ASDisplayNode, constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let layout = ASInsetLayoutSpec(insets: UIEdgeInsets.zero, child: tableNode)
        let canShowLoading = viewModel?.canShowLoading ?? false
        return canShowLoading ? layoutCenterView(layout, view: loadingNode) : layout
    }
    
    /// Every time the viewModel changed, this method will be called again, so make sure to call super for ListPage to work
    open override func bindViewAndViewModel() {
        guard let tableNode = tableNode, dataSource == nil else { return }
        tableNode.rx.itemSelected.asObservable().subscribe(onNext: { [weak self] indexPath in
            self?.onItemSelected(indexPath)
        }).disposedBy(disposeBag)
        
        buildDataSource()
        setupAnimation()
        
        if let dataSource = dataSource {
            viewModel?.itemsSource.rxInnerSources
                .bind(to: tableNode.rx.items(dataSource: dataSource))
                .disposedBy(disposeBag)
        }
        bindLoadingNode()
    }
    
    private func buildDataSource() {
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
    }
    
    private func setupAnimation() {
        let ani1: RxASTableAnimatedDataSource<ASMSectionList<CVM>>.AnimationType = { _, _, _ in AnimationTransition.animated }
        let ani2: RxASTableAnimatedDataSource<ASMSectionList<CVM>>.AnimationType =  { _, _, _ in AnimationTransition.reload }
        viewModel?.itemsSource.rxAnimated.distinctUntilChanged().subscribe(onNext: { [weak self] animated in
            self?.dataSource?.animationType = animated ? ani1 : ani2
        }).disposedBy(disposeBag)
    }
    
    open func bindLoadingNode() {
        let canShowLoading = viewModel?.canShowLoading ?? false
        if canShowLoading {
            viewModel?.rxIsLoading.asDriver(onErrorJustReturn: false).drive(onNext: { [weak self] (isLoading) in
                guard let self = self else { return }
                if isLoading && self.loadingNode.isHidden && self.viewModel?.itemsSource.count == 0 {
                    self.loadingNode.isHidden = false
                    self.loadingNode.startAnimating()
                }
                if !isLoading && !self.loadingNode.isHidden {
                    self.loadingNode.stopAnimating()
                    self.loadingNode.isHidden = true
                }
                if !isLoading {
                    self.stopRefreshing()
                }
            }).disposedBy(disposeBag)
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
    
    open func shouldBatchFetch(for tableNode: ASTableNode) -> Bool {
        return false
//        let timeDiff = CACurrentMediaTime() - lastTimeFetching
//        if let viewModel = viewModel,
//            timeDiff > FETCH_THREDHOLD,
//            viewModel.itemsSource.allElements().count > 0,
//            viewModel.canLoadMore,
//            !viewModel.rxIsLoading.value,
//            !viewModel.rxIsLoadingMore.value {
//                return true
//            }
//        return false
    }
    
    open func tableNode(_ tableNode: ASTableNode, willBeginBatchFetchWith context: ASBatchContext) {
        lastTimeFetching = CACurrentMediaTime()
        context.beginBatchFetching()
        viewModel?.fetchingContext = context
        viewModel?.loadMoreItem()
    }
    
    open func getAnimationType() -> RowAnimation {
        return RowAnimation(insertAnimation: .fade, reloadAnimation: .none, deleteAnimation: .automatic)
    }
    
    open func tableNode(_ tableNode: ASTableNode, willDisplayRowWith node: ASCellNode) {
        
    }
    
    open func tableNode(_ tableNode: ASTableNode, didEndDisplayingRowWith node: ASCellNode) {
        
    }
    
    open func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offset = scrollView.contentOffset.y
        if offset > scrollView.contentSize.height - scrollView.frame.height - 160 {
            let timeDiff = CACurrentMediaTime() - lastTimeFetching
            if let viewModel = viewModel,
                timeDiff > FETCH_THREDHOLD,
                viewModel.itemsSource.allElements().count > 0,
                viewModel.canLoadMore,
                !viewModel.rxIsLoading.value,
                !viewModel.rxIsLoadingMore.value {
                    lastTimeFetching = CACurrentMediaTime()
                    viewModel.loadMoreItem()
                }
        }
    }
}
