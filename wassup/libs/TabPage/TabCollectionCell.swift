//
//  TabCollectionCell.swift
//  TabPageViewController
//
//  Created by EndouMari on 2016/02/24.
//  Copyright © 2016年 EndouMari. All rights reserved.
//

import UIKit

class TabCollectionCell: UICollectionViewCell {

    var tabItemButtonPressedBlock: (Void -> Void)?
    var option: TabPageOption = TabPageOption()
    var item: String = "" {
        didSet {
            itemLabel.text = item
            itemLabel.invalidateIntrinsicContentSize()
            invalidateIntrinsicContentSize()
        }
    }
    var isCurrent: Bool = false {
        didSet {
            currentBarView.hidden = !isCurrent
            if isCurrent {
                highlightTitle()
            } else {
                unHighlightTitle()
            }
//            currentBarView.backgroundColor = option.currentColor
            layoutIfNeeded()
        }
    }
    
    var isHighlight: Bool = false

    @IBOutlet private weak var itemLabel: UILabel!
    @IBOutlet private weak var currentBarView: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()

        currentBarView.hidden = true
    }

    override func sizeThatFits(size: CGSize) -> CGSize {
        if item.characters.count == 0 {
            return CGSizeZero
        }

        return intrinsicContentSize()
    }

    class func cellIdentifier() -> String {
        return "TabCollectionCell"
    }
}


// MARK: - View

extension TabCollectionCell {
    override func intrinsicContentSize() -> CGSize {
        let width: CGFloat
        if let tabWidth = option.tabWidth where tabWidth > 0.0 {
            width = tabWidth
        } else if option.tabEqualizeWidth && option.numberOfItem > 0 {
            width = UIScreen.mainScreen().bounds.width / option.numberOfItem
        } else {
            width = itemLabel.intrinsicContentSize().width + option.tabMargin * 2
        }

        let size = CGSizeMake(width, option.tabHeight)
        return size
    }

    func hideCurrentBarView() {
        currentBarView.hidden = true
    }

    func showCurrentBarView() {
        currentBarView.hidden = false
    }

    func highlightTitle() {
        isHighlight = true
        switch option.style {
            case 0:
                itemLabel.textColor = option.currentColor
                itemLabel.font = UIFont.boldSystemFontOfSize(option.fontSize)
                break
            case 1:
                itemLabel.textColor = option.currentColor
                self.backgroundColor = option.tabCurrentBackgroundColor
                break
            default:
                itemLabel.textColor = option.currentColor
                itemLabel.font = UIFont.boldSystemFontOfSize(option.fontSize)
        }
        
    }

    func unHighlightTitle() {
        isHighlight = false
        switch option.style {
        case 0:
            itemLabel.textColor = option.defaultColor
            itemLabel.font = UIFont.systemFontOfSize(option.fontSize)
            break
        case 1:
            itemLabel.textColor = option.defaultColor
            self.backgroundColor = option.tabBackgroundColor
            break
        default:
            itemLabel.textColor = option.defaultColor
            itemLabel.font = UIFont.systemFontOfSize(option.fontSize)
        }
    }
}


// MARK: - IBAction
extension TabCollectionCell {
    @IBAction private func tabItemTouchUpInside(button: UIButton) {
        tabItemButtonPressedBlock?()
    }
}