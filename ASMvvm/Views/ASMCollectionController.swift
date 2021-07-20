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
import RxCocoa
import RxSwift

open class ASMCollectionController<VM: IASMListViewModel>: ASMViewController<VM>, ASCollectionDelegate, ASCollectionDelegateFlowLayout {
    
    public typealias CVM = VM.CellViewModelElement
    
    public var collectionNode: ASCollectionNode!
    
    public var dataSource: RxASCollectionAnimatedDataSource<ASMSectionList<CVM>>?
    
    private var lastTimeFetching: TimeInterval = 0
    private var FETCH_THREDHOLD: TimeInterval = 1 // Only allow fetching after 1 second
    
    public init(viewModel: VM? = nil) {
        super.init(viewModel: viewModel, node: ASDisplayNode())
        collectionNode = ASCollectionNode(collectionViewLayout: getCollectionFlowLayout())
        collectionNode.delegate = self
        collectionNode.leadingScreensForBatching = 1
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
        let layout = ASInsetLayoutSpec(insets: UIEdgeInsets.zero, child: collectionNode)
        let canShowLoading = viewModel?.canShowLoading ?? false
        return canShowLoading ? layoutCenterView(layout, view: loadingNode) : layout
    }
    
    open func beginRefreshing() {
        guard let refreshControl = collectionNode.view.getRefreshControl() else { return }
        refreshControl.beginRefreshing()
    }
        
    open func stopRefreshing() {
        let refreshControl = self.collectionNode.view.getRefreshControl()
        if refreshControl?.isRefreshing == true {
            refreshControl?.endRefreshing()
        }
    }
    
    /// Every time the viewModel changed, this method will be called again, so make sure to call super for ListPage to work
    open override func bindViewAndViewModel() {
        collectionNode.rx.itemSelected.asObservable().subscribe(onNext: { [weak self] indexPath in
            self?.onItemSelected(indexPath)
        }).disposedBy(disposeBag)
        
        buildDataSource()
        setupAnimation()
        
        if let dataSource = dataSource {
            viewModel?.itemsSource.rxInnerSources
                .bind(to: collectionNode.rx.items(dataSource: dataSource))
                .disposedBy(disposeBag)
        }
        bindLoadingNode()
    }
    
    private func buildDataSource() {
        let configureCell: RxASCollectionAnimatedDataSource<ASMSectionList<CVM>>.ConfigureCell = { [weak self] (_, _, index, i) in
            guard let self = self else {
                return ASCellNode()
            }
            return self.configureCell(index: index, cellVM: i)
        }
                
        let animationType = getAnimationType()
        let configureSupplementaryView: RxASCollectionAnimatedDataSource<ASMSectionList<CVM>>.ConfigureSupplementaryView = { [weak self] (_, _, title, index) in
            guard let self = self else {
                return ASCellNode()
            }
            return self.configureSupplementaryView(title, indexPath: index)
        }
        dataSource = RxASCollectionAnimatedDataSource<ASMSectionList<CVM>>(
            animationConfiguration: animationType,
            configureCell: configureCell,
            configureSupplementaryView: configureSupplementaryView
        )
    }
    
    private func setupAnimation() {
        let ani1: RxASCollectionAnimatedDataSource<ASMSectionList<CVM>>.AnimationType = { _, _, _ in AnimationTransition.animated }
        let ani2: RxASCollectionAnimatedDataSource<ASMSectionList<CVM>>.AnimationType =  { _, _, _ in AnimationTransition.reload }
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
    
    open func getAnimationType() -> RowAnimation {
        return RowAnimation(insertAnimation: .fade, reloadAnimation: .none, deleteAnimation: .automatic)
    }
    
    open func selectedItemDidChange(_ cellViewModel: CVM) { }
    
    open func configureCell(index: IndexPath, cellVM: CVM) -> ASCellNode {
        fatalError("Subclasses have to implement this method.")
    }
    
    open func getCollectionFlowLayout() -> UICollectionViewFlowLayout {
        return UICollectionViewFlowLayout()
    }
    
    // MARK: Collection Delegate
    open func shouldBatchFetch(for collectionNode: ASCollectionNode) -> Bool {
        let timeDiff = CACurrentMediaTime() - lastTimeFetching
        if let viewModel = viewModel,
            timeDiff > FETCH_THREDHOLD,
            viewModel.itemsSource.allElements().count > 0,
            viewModel.canLoadMore,
            !viewModel.rxIsLoading.value,
            !viewModel.rxIsLoadingMore.value {
                return true
            }
        return false
    }
    
    open func collectionNode(_ collectionNode: ASCollectionNode,
                               willBeginBatchFetchWith context: ASBatchContext) {
        lastTimeFetching = CACurrentMediaTime()
        context.beginBatchFetching()
        viewModel?.fetchingContext = context
        viewModel?.loadMoreItem()
    }
    
    open func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
    }
    
    open func configureSupplementaryView(_ title: String, indexPath: IndexPath) -> ASCellNode {
        return ASCellNode()
    }
    
    open func collectionNode(_ collectionNode: ASCollectionNode, sizeRangeForFooterInSection section: Int) -> ASSizeRange {
        return ASSizeRange(min: .zero, max: .zero)
    }
    
    open func collectionNode(_ collectionNode: ASCollectionNode, sizeRangeForHeaderInSection section: Int) -> ASSizeRange {
        return ASSizeRange(min: .zero, max: .zero)
    }
}
