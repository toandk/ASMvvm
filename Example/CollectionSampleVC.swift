//
//  CollectionSampleVC.swift
//  ASMvvm-Example
//
//  Created by toandk on 7/6/20.
//  Copyright © 2020 toandk. All rights reserved.
//

import Foundation
import ASMvvm
import AsyncDisplayKit
import RxCocoa_Texture
import RxCocoa

class CollectionSampleVC: ASMCollectionController<SimpleListViewModel> {
    let addBtn: ASButtonNode = {
            let button = ASButtonNode()
            button.setTitle("Add", with: .systemFont(ofSize: 14), with: .blue, for: .normal)
            return button
        }()
        
    deinit {
        print("deinit VC")
    }
    
    let headerNode = ASDisplayNode()

    override func initialize() {
        super.initialize()
        
        addBtn.style.preferredSize = CGSize(width: 60, height: 40)
        addBtn.backgroundColor = .yellow
        collectionNode.registerSupplementaryNode(ofKind: UICollectionView.elementKindSectionFooter)
        collectionNode.onDidLoad { [weak self] _ in
            guard let self = self else { return }
            let refreshControl = self.collectionNode.view.addPullToRefresh()
            refreshControl.addTarget(self, action: #selector(self.handleRefresh), for: .valueChanged)
        }
//        viewModel?.add()
//        viewModel?.add()
    }
    
    override func bindViewAndViewModel() {
        super.bindViewAndViewModel()
        
        guard viewModel != nil else { return }
        addBtn.rx.tap.subscribe(onNext: { [weak self] _ in
            self?.viewModel?.add()
        }).disposedBy(disposeBag)
    }
    
    override func configureCell(index: IndexPath, cellVM: SimpleListCellViewModel) -> ASCellNode {
        let cell = SimpleListCell(viewModel: cellVM)
        cell.style.width = ASDimension(unit: .points, value: view.frame.width)
        return cell
    }
    
    override func layoutNode(node: ASDisplayNode, constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let header = ASCenterLayoutSpec(centeringOptions: .XY, sizingOptions: .minimumX, child: addBtn)
        header.style.height = ASDimension(unit: .points, value: 200)
        collectionNode.style.flexGrow = 1
        let stack = ASStackLayoutSpec(direction: .vertical,
                                      spacing: 10,
                                      justifyContent: .spaceBetween,
                                      alignItems: .stretch,
                                      children: [header, collectionNode])
        return layoutCenterView(stack, view: loadingNode)
    }
    
    @objc func handleRefresh() {
        self.collectionNode.view.getRefreshControl()?.beginRefreshing()
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.viewModel?.itemsSource.reset([[]])
        }
    }
    
    override func collectionNode(_ collectionNode: ASCollectionNode, sizeRangeForFooterInSection section: Int) -> ASSizeRange {
        if let items = viewModel?.itemsSource, section == items.count - 1 {
            return ASSizeRange(min: CGSize(width: view.frame.width, height: 150), max: CGSize(width: view.frame.width, height: 150))
        }
        return ASSizeRangeZero
    }
    
    override func configureSupplementaryView(_ title: String, indexPath: IndexPath) -> ASCellNode {
        return ASCellNode(viewBlock: { () -> UIView in
            let view = UIView()
            view.backgroundColor = .yellow
            let indicator = UIActivityIndicatorView(style: .gray)
            view.addSubview(indicator)
            return view
        })
    }
}
