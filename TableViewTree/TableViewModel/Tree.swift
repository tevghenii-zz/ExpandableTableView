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

extension Int {
    static func random(min: Int, max:Int) -> Int {
        return min + Int(arc4random_uniform(UInt32(max - min + 1)))
    }
}

struct TreeItem<DataType> {
    let id: Int
    let data: DataType?
    
    init(id: Int, data: DataType? = nil) {
        self.id = id
        self.data = data
    }
    
    init(data: DataType? = nil) {
        self.id = Int.random(min: 1, max: 100000)
        self.data = data
    }
}

extension TreeItem: Equatable {
    public static func ==(lhs: TreeItem, rhs: TreeItem) -> Bool {
        return lhs.id == rhs.id
    }
}

class Tree<DataType> {
    private var roots: [TreeItem<DataType>] = []
    private var childs: [Int: [TreeItem<DataType>]] = [:]
    
    func addRoot(item: TreeItem<DataType>) {
        roots.append(item)
        childs[item.id] = []
    }
    
    func addRoot(item: TreeItem<DataType>, at: Int) {
        guard at < roots.count else { return }
        roots.insert(item, at: at)
        childs[item.id] = []
    }
    
    func addChild(item: TreeItem<DataType>, into: TreeItem<DataType>) {
        guard childs[into.id] != nil else { return }
        childs[into.id]!.append(item)
    }
    
    func addChild(item: TreeItem<DataType>, into: TreeItem<DataType>, at: Int) {
        guard let itemChilds = childs[into.id], at < itemChilds.count else { return }
        
        childs[into.id]!.insert(item, at: at)
    }
    
    func removeRoot(item: TreeItem<DataType>) {
        if let index = roots.index(of: item) {
            roots.remove(at: index)
            childs.removeValue(forKey: item.id)
        }
    }
    
    func removeChild(item: TreeItem<DataType>) {
        let foundChilds = childs.filter { $0.value.contains(item) }
        if let treeItem = foundChilds.first {
            childs[treeItem.key] = treeItem.value.filter { $0.id != item.id }
        }
    }
    
    func removeChildsOfRoot(item: TreeItem<DataType>) {
        childs[item.id] = []
    }
    
    func removeChildAndNeighbors(item: TreeItem<DataType>) {
        let foundChilds = childs.filter { $0.value.contains(item) }
        if let treeItem = foundChilds.first {
            childs[treeItem.key] = []
        }
    }
    
    func removeAll() {
        roots = []
        childs = [:]
    }
    
    func getRootOfChild(item: TreeItem<DataType>) -> TreeItem<DataType>? {
        let foundChilds = childs.filter { $0.value.contains(item) }
        if let treeItem = foundChilds.first {
            return roots.filter { $0.id == treeItem.key }.first
        }
        return nil
    }
    
    func getChildsOfRoot(item: TreeItem<DataType>) -> [TreeItem<DataType>] {
        return childs[item.id] ?? []
    }
    
    func isRoot(item: TreeItem<DataType>) -> Bool {
        return roots.contains(item)
    }
    
    func flatItems() -> [TreeItem<DataType>] {
        var items: [TreeItem<DataType>] = []
        for root in roots {
            items.append(root)
            if childs[root.id] != nil {
                items.append(contentsOf: childs[root.id]!)
            }
        }
        
        return items
    }
    
    func flatCount() -> Int {
        var count = roots.count
        childs.forEach { count += $0.value.count }
        
        return count
    }
    
    func itemByFlatIndex(index: Int) -> (Bool, TreeItem<DataType>) {
        let item = flatItems()[index]
        let isRoot = self.isRoot(item: item)
        
        return (isRoot, item)
    }
    
    func flatIndexOfItem(item: TreeItem<DataType>) -> Int? {
        return flatItems().index(of: item)
    }
    
    func log() {
        print("roots = \(roots)")
        print("childs = \(childs)")
    }
}
