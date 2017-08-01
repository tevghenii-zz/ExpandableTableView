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

import UIKit

class RootCell: UITableViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var iconView: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func update(city: City, isOpened: Bool) {
        nameLabel.text = city.name
        changeState(isOpened)
    }
    
    func changeState(_ isOpened: Bool, animated: Bool = false) {
        if isOpened {
            expand(animated: animated)
        } else {
            collapse(animated: animated)
        }
    }
    
    func expand(animated: Bool = false) {
        let transform = CGAffineTransform(rotationAngle: CGFloat.pi)
        if animated {
            UIView.animate(withDuration: 0.1) {
                self.iconView.transform = transform
            }
        } else {
            self.iconView.transform = transform
        }
    }
    
    func collapse(animated: Bool = false) {
        let transform = CGAffineTransform.identity
        
        if animated {
            UIView.animate(withDuration: 0.1) {
                self.iconView.transform = transform
            }
        } else {
            self.iconView.transform = transform
        }
    }
    
}
