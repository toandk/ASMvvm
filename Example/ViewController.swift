//
//  ViewController.swift
//  ASMvvm
//
//  Created by toandk on 2/14/20.
//  Copyright © 2020 toandk. All rights reserved.
//

import UIKit
import AsyncDisplayKit
import RxCocoa_Texture
import RxCocoa
import ASMvvm
import DTMvvm

class ViewController: ASMTableController<SimpleListViewModel> {
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
        tableNode.onDidLoad { [weak self] _ in
            guard let self = self else { return }
            let refreshControl = self.tableNode.view.addPullToRefresh()
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
        }) => disposeBag
    }
    
    override func configureCellBlock(index: IndexPath, cellVM: SimpleListCellViewModel) -> ASCellNodeBlock {
        let cellNodeBlock = { () -> ASCellNode in
            let cell = SimpleListCell(viewModel: cellVM)
            return cell
        }
        return cellNodeBlock
    }
    
    override func layoutNode(node: ASDisplayNode, constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let header = ASCenterLayoutSpec(centeringOptions: .XY, sizingOptions: .minimumX, child: addBtn)
        header.style.height = ASDimension(unit: .points, value: 200)
        tableNode.style.flexGrow = 1
        let stack = ASStackLayoutSpec(direction: .vertical,
                                      spacing: 10,
                                      justifyContent: .spaceBetween,
                                      alignItems: .stretch,
                                      children: [header, tableNode])
        return layoutCenterView(stack, view: loadingNode)
    }
    
    @objc func handleRefresh() {
        self.tableNode.view.getRefreshControl()?.beginRefreshing()
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.viewModel?.itemsSource.reset([[]])            
        }
    }
}

class SimpleListViewModel: ASMListViewModel<Model, SimpleListCellViewModel> {
    
    override func react() {
        rxIsLoading.accept(true)
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.rxIsLoading.accept(false)
        }
    }
    
    public func add() {
        let number = Int.random(in: 1000...10000)
        let title = "This is your random number: \(number)"
        let cvm = SimpleListCellViewModel(model: SimpleModel(withTitle: title))
        itemsSource.append(cvm, to: 0, animated: true)
        
        if itemsSource.countElements() == 20 {
            canLoadMore = false
        }
    }
    
    override func loadMoreItem() {
        add()
        add()
        
        print("load more")
    }
}
