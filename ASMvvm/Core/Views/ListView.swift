//
//  ListView.swift
//  DTMvvm
//
//  Created by Dao Duy Duong on 10/28/18.
//

import UIKit
import AsyncDisplayKit
import RxASDataSources

open class ASMListView<VM: IListViewModel>: ASMView<VM> {

    public typealias CVM = VM.CellViewModelElement
    
    public let tableView: ASTableNode
    
    public var dataSource: RxASTableAnimatedDataSource<ASMSectionList<CVM>>?
    
    public override init(viewModel: VM? = nil) {
        tableView = ASTableNode(style: .plain)
        super.init(viewModel: viewModel)
    }
    
    override func setup() {
        tableView.backgroundColor = .clear
        addSubnode(tableView)
        
        super.setup()
    }
    
    open override func initialize() {
        
    }
    
    open override func destroy() {
        super.destroy()
        tableView.removeFromSupernode()
    }
    
    /// Every time the viewModel changed, this method will be called again, so make sure to call super for ListPage to work
    open override func bindViewAndViewModel() {
        tableView.rx.itemSelected.asObservable().subscribe(onNext: onItemSelected) => disposeBag
        
        let configureCell: ASTableSectionedDataSource<ASMSectionList<CVM>>.ConfigureCell = { (_, tableNode, index, i) in
            return self.configureCell(index: index, cellVM: i)
        }
        
        dataSource = RxASTableAnimatedDataSource<ASMSectionList<CVM>>(
            configureCell: configureCell
        )
        
        viewModel?.itemsSource.rxInnerSources
            .bind(to: tableView.rx.items(dataSource: dataSource!)) => disposeBag
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
}
