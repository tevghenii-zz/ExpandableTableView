//
//    Copyright (c) 2017 Evghenii Todorov
//
//    Permission is hereby granted, free of charge, to any person obtaining a copy
//    of this software and associated documentation files (the "Software"), to deal
//    in the Software without restriction, including without limitation the rights
//    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//    copies of the Software, and to permit persons to whom the Software is
//    furnished to do so, subject to the following conditions:
//
//    The above copyright notice and this permission notice shall be included in all
//    copies or substantial portions of the Software.
//
//    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//    SOFTWARE.

import Foundation
import UIKit

class TreeTableViewModel<RootCellType: UITableViewCell, ChildCellType: UITableViewCell, DataType>: NSObject, UITableViewDataSource, UITableViewDelegate {
    typealias ConfigureRootCellBlock = (RootCellType, DataType?, Bool) -> ()
    typealias ConfigureChildCellBlock = (ChildCellType, DataType?) -> ()
    typealias ChangeRootCellStateBlock = (RootCellType, Bool) -> ()
    
    var configureRootCell: ConfigureRootCellBlock?
    var configureChildCell: ConfigureChildCellBlock?
    var changeRootCellState: ChangeRootCellStateBlock?
    
    private let tree = Tree<DataType>()
    
    func addRoot(item: DataType) {
        tree.addRoot(item: TreeItem(data: item))
    }
    
    func addRootItems(items: [DataType]) {
        items.forEach { addRoot(item: $0) }
    }
    
    func clear() {
        tree.removeAll()
    }
    
    func item(at index: Int) -> DataType? {
        let (_, item) = tree.itemByFlatIndex(index: index)
        return item.data
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tree.flatCount()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let (isRoot, item) = tree.itemByFlatIndex(index: indexPath.row)
        
        if isRoot {
            let identifier = String(describing: RootCellType.self)
            let cell = tableView.dequeueReusableCell(withIdentifier: identifier) as! RootCellType
            let isOpened = tree.getChildsOfRoot(item: item).count > 0
            configureRootCell?(cell, item.data, isOpened)
            return cell
        } else {
            let identifier = String(describing: ChildCellType.self)
            let cell = tableView.dequeueReusableCell(withIdentifier: identifier) as! ChildCellType
            configureChildCell?(cell, item.data)
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let (isRoot, item) = tree.itemByFlatIndex(index: indexPath.row)
        
        if indexPath.row == tree.flatCount()-1 {
            if isRoot {
                let childItem = TreeItem<DataType>(data: item.data)
                tree.addChild(item: childItem, into: item)
                
                let itemIndex = tree.flatIndexOfItem(item: childItem)!
                let index = IndexPath(row: itemIndex, section: 0)
                tableView.insertRows(at: [index], with: .fade)
                
                let cell = tableView.cellForRow(at: indexPath) as! RootCellType
                changeRootCellState?(cell, true)
            } else {
                let parentItem = tree.getRootOfChild(item: item)!
                let parentItemIndex = tree.flatIndexOfItem(item: parentItem)!
                
                let indexPathsToDelete = tree.getChildsOfRoot(item: parentItem)
                    .map { tree.flatIndexOfItem(item: $0)! }
                    .map { IndexPath(row: $0, section: 0) }
                
                tree.removeChildsOfRoot(item: parentItem)
                tableView.deleteRows(at: indexPathsToDelete, with: .fade)
                
                let parentIndexPath = IndexPath(row: parentItemIndex, section: 0)
                let cell = tableView.cellForRow(at: parentIndexPath) as! RootCellType
                changeRootCellState?(cell, false)
            }
            
            return
        }
        
        let (isNextItemRoot, nextItem) = tree.itemByFlatIndex(index: indexPath.row + 1)
        
        if isRoot && isNextItemRoot {
            let childItem = TreeItem<DataType>(data: item.data)
            tree.addChild(item: childItem, into: item)
            
            let itemIndex = tree.flatIndexOfItem(item: childItem)!
            let index = IndexPath(row: itemIndex, section: 0)
            tableView.insertRows(at: [index], with: .fade)
            
            let cell = tableView.cellForRow(at: indexPath) as! RootCellType
            changeRootCellState?(cell, true)
            
            return
        }
        
        if isRoot && isNextItemRoot == false {
            let index = tree.flatIndexOfItem(item: nextItem)!
            let indexPath = IndexPath(row: index, section: 0)
            tree.removeChild(item: nextItem)
            
            tableView.deleteRows(at: [indexPath], with: .fade)
            
            let parentItemIndex = tree.flatIndexOfItem(item: item)!
            let parentIndexPath = IndexPath(row: parentItemIndex, section: 0)
            let cell = tableView.cellForRow(at: parentIndexPath) as! RootCellType
            changeRootCellState?(cell, false)
            
            return
        }
        
        if isRoot == false {
            let parentItem = tree.getRootOfChild(item: item)!
            let indexPathsToDelete = tree.getChildsOfRoot(item: parentItem)
                .map { tree.flatIndexOfItem(item: $0)! }
                .map { IndexPath(row: $0, section: 0) }
            
            tree.removeChildsOfRoot(item: parentItem)
            tableView.deleteRows(at: indexPathsToDelete, with: .fade)
            
            let parentItemIndex = tree.flatIndexOfItem(item: parentItem)!
            let parentIndexPath = IndexPath(row: parentItemIndex, section: 0)
            let cell = tableView.cellForRow(at: parentIndexPath) as! RootCellType
            changeRootCellState?(cell, false)
            
            return
        }
    }
}

extension UITableView {
    func registerTreeCells<A, B>(root: A.Type, child: B.Type) {
        let rootTypeString = String(describing: root)
        let childTypeString = String(describing: child)
        
        let rootNib = UINib(nibName: rootTypeString, bundle: nil)
        register(rootNib, forCellReuseIdentifier: rootTypeString)
        
        let childNib = UINib(nibName: childTypeString, bundle: nil)
        register(childNib, forCellReuseIdentifier: childTypeString)
    }
    
    func registerTreeViewModel<A, B, C>(_ viewModel: TreeTableViewModel<A, B, C>) {
        self.dataSource = viewModel
        self.delegate = viewModel
    }
}
