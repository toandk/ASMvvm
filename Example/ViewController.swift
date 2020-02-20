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
    
    let headerNode = ASDisplayNode()

    override func initialize() {
        super.initialize()
        
        addBtn.style.preferredSize = CGSize(width: 60, height: 40)
        addBtn.backgroundColor = .yellow
        
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
    
    override func configureCell(index: IndexPath, cellVM: SimpleListCellViewModel) -> ASCellNode {
        let cell = SimpleListCell(viewModel: cellVM)
        return cell
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
        itemsSource.append(cvm)
        
        if itemsSource.countElements() == 20 {
            canLoadMore = false
        }
    }
    
    override func loadMoreItem(context: ASBatchContext) {
        add()
        add()
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            context.completeBatchFetching(true)
        }
        
        print("load more")
    }
}
