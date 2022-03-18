//
//  SectionList.swift
//  DTMvvm
//
//  Created by toandk on 2/18/20.
//

import UIKit
import RxSwift
import RxCocoa
import Differentiator

/// Section list data sources
public class ASMSectionList<T>: AnimatableSectionModelType where T: IdentifyEquatable {
    
    public typealias Item = T
    
    public typealias Identity = String
    
    public let key: Any
    
    public var identity: String {
        return "\(key)"
    }
    
    public var items = [T]()
    
    public subscript(index: Int) -> T {
        get { return items[index] }
        set(newValue) { insert(newValue, at: index) }
    }
    
    public var count: Int {
        return items.count
    }
    
    public var first: T? {
        return items.first
    }
    
    public var last: T? {
        return items.last
    }
    
    public var allElements: [T] {
        return items
    }
    
    public required init(original: ASMSectionList<T>, items: [T]) {
        self.key = original.key
        self.items = items
    }
    
    public init(_ key: Any, initialElements: [T] = []) {
        self.key = key
        items.append(contentsOf: initialElements)
    }
    
    public func forEach(_ body: ((Int, T) -> ())) {
        for (i, element) in items.enumerated() {
            body(i, element)
        }
    }
    
    public func insert(_ element: T, at index: Int) {
        items.insert(element, at: index)
    }
    
    public func insert(_ elements: [T], at index: Int) {
        items.insert(contentsOf: elements, at: index)
    }
    
    public func append(_ element: T) {
        items.append(element)
    }
    
    public func append(_ elements: [T]) {
        items.append(contentsOf: elements)
    }
    
    @discardableResult
    fileprivate func remove(at index: Int) -> T? {
        guard index < items.count, index >= 0 else {
            return nil
        }
        let item = items.remove(at: index)
        (item as? IASMDestroyable)?.destroy()
        return item
    }
    
    public func remove(at indice: [Int]) {
        let newSources = items.enumerated().compactMap { indice.contains($0.offset) ? nil : $0.element }
        items = newSources
    }
    
    public func removeAll() {
        items.removeAll()
    }
    
    fileprivate func sort(by predicate: (T, T) throws -> Bool) rethrows {
        try items.sort(by: predicate)
    }
    
    @discardableResult
    public func firstIndex(of element: T) -> Int? {
        return items.firstIndex(of: element)
    }
    
    @discardableResult
    public func lastIndex(of element: T) -> Int? {
        return items.lastIndex(of: element)
    }
    
    @discardableResult
    public func firstIndex(where predicate: (T) throws -> Bool) rethrows -> Int? {
        return try items.firstIndex(where: predicate)
    }
    
    @discardableResult
    public func lastIndex(where predicate: (T) throws -> Bool) rethrows -> Int? {
        return try items.lastIndex(where: predicate)
    }
    
    public func map<U>(_ transform: (T) throws -> U) rethrows -> [U] {
        return try items.map(transform)
    }
    
    public func compactMap<U>(_ transform: (T) throws -> U?) rethrows -> [U] {
        return try items.compactMap(transform)
    }
    
    func destroyItems() {
        forEach { (_, item) in
            (item as? IASMDestroyable)?.destroy()
        }
    }
}

public class ASMReactiveCollection<T>: SectionModelType where T: IdentifyEquatable {
    public typealias Item = ASMSectionList<T>
    
    public func element(atIndexPath: IndexPath) -> Any? {
        return self[atIndexPath.row, atIndexPath.section]
    }
    
    public func element(atSection: Int, row: Int) -> Any? {
        return self[row, atSection]
    }
    
    public var rxAnimated = BehaviorRelay<Bool>(value: true)
    
    public var items: [ASMSectionList<T>] = []
    
    public let rxInnerSources = BehaviorRelay<[ASMSectionList<T>]>(value: [])
    
    public init() {
        
    }
    
    public required init(original: ASMReactiveCollection<T>, items: [ASMSectionList<T>]) {
        self.items = items
        self.rxAnimated.accept(original.rxAnimated.value)
    }
    
    public subscript(index: Int, section: Int) -> T {
        get { return items[section][index] }
        set(newValue) { insert(newValue, at: index, of: section) }
    }
    
    public subscript(index: Int) -> ASMSectionList<T> {
        get { return items[index] }
        set(newValue) { insertSection(newValue, at: index) }
    }
    
    public var count: Int {
        return items.count
    }
    
    public var first: ASMSectionList<T>? {
        return items.first
    }
    
    public var last: ASMSectionList<T>? {
        return items.last
    }
    
    public func allElements() -> [T] {
        var allItems: [T] = []
        for section in items {
            allItems.append(contentsOf: section.allElements)
        }
        return allItems
    }
    
    public func forEach(_ body: ((Int, ASMSectionList<T>) -> ())) {
        for (i, section) in items.enumerated() {
            body(i, section)
        }
    }
    
    public func countElements(at section: Int = 0) -> Int {
        guard section >= 0 && section < items.count else { return 0 }
        return items[section].count
    }
    
    public func isValid(indexPath: IndexPath) -> Bool {
        return items.count > 0 && indexPath.section < items.count && indexPath.row < items[indexPath.section].count
    }
    
    // MARK: - section manipulations
    
    public func reload(at section: Int = -1, animated: Bool = true) {
        if items.count > 0 && section < items.count {
            rxAnimated.accept(animated)
            rxInnerSources.accept(items)
        }
    }
    
    public func reset(_ elements: [T], of section: Int = 0, animated: Bool = true) {
        if section < items.count {
            items[section].removeAll()
            items[section].append(elements)
            rxAnimated.accept(animated)
            rxInnerSources.accept(items)
        }
    }
    
    public func reset(_ sources: [[T]], animated: Bool = true) {
        reset(sources.map { ASMSectionList("", initialElements: $0) }, animated: animated)
    }
    
    public func reset(_ sources: [ASMSectionList<T>], animated: Bool = true) {
        items.removeAll()
        items.append(contentsOf: sources)
        
        reload(animated: animated)
    }
    
    public func insertSection(_ key: Any, elements: [T], at index: Int, animated: Bool = true) {
        insertSection(ASMSectionList<T>(key, initialElements: elements), at: index, animated: animated)
    }
    
    public func insertSection(_ sectionList: ASMSectionList<T>, at index: Int, animated: Bool = true) {
        rxAnimated.accept(animated)
        if items.count == 0 {
            items.append(sectionList)
        } else {
            items.insert(sectionList, at: index)
        }
        
        rxInnerSources.accept(items)
    }
    
    public func appendSections(_ sectionLists: [ASMSectionList<T>], animated: Bool = true) {
        rxAnimated.accept(animated)
        items.append(contentsOf: sectionLists)
        rxInnerSources.accept(items)
    }
    
    public func appendSection(_ key: Any, elements: [T], animated: Bool = true) {
        appendSection(ASMSectionList<T>(key, initialElements: elements), animated: animated)
    }
    
    public func appendSection(_ sectionList: ASMSectionList<T>, animated: Bool = true) {
        rxAnimated.accept(animated)
        items.append(sectionList)
        rxInnerSources.accept(items)
    }
    
    @discardableResult
    public func removeSection(at index: Int, animated: Bool = true) -> ASMSectionList<T>? {
        guard index < items.count, index >= 0 else { return nil }
        items[index].destroyItems()
        rxAnimated.accept(animated)
        let element = items.remove(at: index)
        rxInnerSources.accept(items)
        
        return element
    }
    
    public func removeAll(animated: Bool = true) {
        forEach { (_, section) in
            section.destroyItems()
        }
        rxAnimated.accept(animated)
        items.removeAll()
        rxInnerSources.accept(items)
    }
    
    // MARK: - section elements manipulations
    
    public func insert(_ element: T, at indexPath: IndexPath, animated: Bool = true) {
        insert(element, at: indexPath.row, of: indexPath.section, animated: animated)
    }
    
    public func insert(_ element: T, at index: Int, of section: Int = 0, animated: Bool = true) {
        insert([element], at: index, of: section, animated: animated)
    }
    
    public func insert(_ elements: [T], at indexPath: IndexPath, animated: Bool = true) {
        insert(elements, at: indexPath.row, of: indexPath.section, animated: animated)
    }
    
    public func insert(_ elements: [T], at index: Int, of section: Int = 0, animated: Bool = true) {
        rxAnimated.accept(animated)
        if section >= items.count {
            appendSection("", elements: elements, animated: animated)
            return
        }
        
        if items[section].count == 0 {
            items[section].append(elements)
        } else if index < items[section].count {
            items[section].insert(elements, at: index)
        }
        
        rxInnerSources.accept(items)
    }
    
    public func append(_ element: T, to section: Int = 0, animated: Bool = true) {
        append([element], to: section, animated: animated)
    }
    
    public func append(_ elements: [T], to section: Int = 0, animated: Bool = true) {
        rxAnimated.accept(animated)
        if section >= items.count {
            appendSection("", elements: elements, animated: animated)
            return
        }
        
        items[section].append(elements)
        rxInnerSources.accept(items)
    }
    
    @discardableResult
    public func remove(at indexPath: IndexPath, animated: Bool = true) -> T? {
        return remove(at: indexPath.row, of: indexPath.section, animated: animated)
    }
    
    @discardableResult
    public func remove(at index: Int, of section: Int = 0, animated: Bool = true) -> T? {
        if let element = items[section].remove(at: index) {
            rxAnimated.accept(animated)
            rxInnerSources.accept(items)
            
            return element
        }
        
        return nil
    }
    
    @discardableResult
    public func remove(at indice: [Int], of section: Int = 0, animated: Bool = true) -> [T] {
        return remove(at: indice.map { IndexPath(row: $0, section: section) })
    }
    
    @discardableResult
    public func remove(at indexPaths: [IndexPath], animated: Bool = true) -> [T] {
        let removedElements = indexPaths.compactMap { items[$0.section].remove(at: $0.row) }
        rxAnimated.accept(animated)
        rxInnerSources.accept(items)
        
        return removedElements
    }
    
    public func sort(by predicate: (T, T) throws -> Bool, at section: Int = 0, animated: Bool = true) rethrows {
        let oldElements = items[section].allElements
        
        try items[section].sort(by: predicate)
        
        let newElements = items[section].allElements
        
        var fromIndexPaths: [IndexPath] = []
        var toIndexPaths: [IndexPath] = []
        oldElements.enumerated().forEach { (i, element) in
            if let newIndex = newElements.firstIndex(of: element) {
                toIndexPaths.append(IndexPath(row: newIndex, section: section))
                fromIndexPaths.append(IndexPath(row: i, section: section))
            }
        }
        
        if fromIndexPaths.count == toIndexPaths.count {
            rxAnimated.accept(animated)
            rxInnerSources.accept(items)
        }
    }
    
    public func move(from fromIndexPaths: [IndexPath], to toIndexPaths: [IndexPath], animated: Bool = true) {
        guard fromIndexPaths.count == toIndexPaths.count else { return }
        
        var validIndice: [Int] = []
        for (i, fromIndexPath) in fromIndexPaths.enumerated() {
            let toIndexPath = toIndexPaths[i]
            if fromIndexPath.section != toIndexPath.section {
                if let element = items[fromIndexPath.section].remove(at: fromIndexPath.row) {
                    items[toIndexPath.section].insert(element, at: toIndexPath.row)
                    validIndice.append(i)
                }
            } else {
                let element = items[fromIndexPath.section][fromIndexPath.row]
                items[toIndexPath.section].insert(element, at: toIndexPath.row)
                
                if fromIndexPath.row < toIndexPath.row {
                    items[fromIndexPath.section].remove(at: fromIndexPath.row)
                    validIndice.append(i)
                } else if fromIndexPath.row > toIndexPath.row {
                    items[fromIndexPath.section].remove(at: fromIndexPath.row + 1)
                    validIndice.append(i)
                }
            }
        }
        
        if validIndice.count > 0 {
            rxAnimated.accept(animated)
            rxInnerSources.accept(items)
        }
    }
    
    public func asObservable() -> Observable<[ASMSectionList<T>]> {
        return rxInnerSources.asObservable()
    }
    
    public func indexForSection(withKey key: AnyObject) -> Int? {
        
        return items.firstIndex(where: {
            if key is String && !($0.key is String) {
                return false
            }
            return key.isEqual($0.key)
        })
    }
    
    @discardableResult
    public func firstIndex(of element: T, at section: Int = 0) -> Int? {
        guard items.count > section else { return nil }
        return items[section].firstIndex(of: element)
    }
    
    @discardableResult
    public func lastIndex(of element: T, at section: Int) -> Int? {
        guard items.count > section else { return nil }
        return items[section].lastIndex(of: element)
    }
    
    @discardableResult
    public func firstIndex(where predicate: (T) throws -> Bool, at section: Int) rethrows -> Int? {
        guard items.count > section else { return nil }
        return try items[section].firstIndex(where: predicate)
    }
    
    @discardableResult
    public func lastIndex(where predicate: (T) throws -> Bool, at section: Int) rethrows -> Int? {
        guard items.count > section else { return nil }
        return try items[section].lastIndex(where: predicate)
    }
    
    public func indexPath(of item: T) -> IndexPath? {
        for i in 0..<count {
            for j in 0..<items[i].count {
                if items[i][j] == item {
                    return IndexPath(row: j, section: i)
                }
            }
        }
        return nil
    }
}
