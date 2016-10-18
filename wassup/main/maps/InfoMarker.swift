//
//  InfoMarker.swift
//  wassup
//
//  Created by MAC on 8/19/16.
//  Copyright © 2016 MAC. All rights reserved.
//

import UIKit

class InfoMarker: UIView {
    var contentView:UIView?
    // other outlets
    
    @IBOutlet weak var btnCheckIn: UIView!
    @IBOutlet weak var btnFollow: UIView!
    @IBOutlet weak var lblCheckIn: UILabel!
    @IBOutlet weak var icCheckIn: UIImageView!
    @IBOutlet weak var lblFollow: UILabel!
    @IBOutlet weak var icFollow: UIImageView!
    @IBOutlet weak var lblTime: UILabel!
    @IBOutlet weak var lblLocation: UILabel!
    @IBOutlet weak var info: UILabel!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var cover: UIImageView!
    
    @IBOutlet weak var titleCate: UILabel!
    var id = ""
    var activeLeft = false
    var activeRight = false
    var cate = ObjectType.Event
    
    override init(frame: CGRect) { // for using CustomView in code
        super.init(frame: frame)
        self.commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) { // for using CustomView in IB
        super.init(coder: aDecoder)
        self.commonInit()
    }
    
    private func commonInit() {
        contentView = self.loadViewFromNib("InfoMarker")
        contentView!.frame = self.bounds
        contentView!.autoresizingMask = [.FlexibleHeight, .FlexibleWidth]
        self.addSubview(contentView!)
        
        btnFollow.corner(0, border: 1, colorBorder: 0xE0E3E7)
        btnCheckIn.corner(0, border: 1, colorBorder: 0xE0E3E7)
        
        let gestureJoin = UITapGestureRecognizer(target: self, action: #selector(clickLeft))
        btnFollow.addGestureRecognizer(gestureJoin)
        
        let gestureRight = UITapGestureRecognizer(target: self, action: #selector(clickRight))
        btnCheckIn.addGestureRecognizer(gestureRight)
    }
    
    func initData(data:Dictionary<String,String>) {
        id = data["id"]!
        
        titleCate.corner(10, border: 0, colorBorder: 0)
        titleCate.text = (cate == ObjectType.Event) ? Localization("Sự kiện") : Localization("Địa điểm")
        if cate == ObjectType.Host {
            titleCate.backgroundColor = UIColor.fromRgbHex(0xDC5244)
        } else {
            titleCate.backgroundColor = UIColor.fromRgbHex(0x1665D8)
        }
        
        if cate == ObjectType.Event {
            info.text = "\(CONVERT_STRING(data["attend_number"])) quan tâm | \(CONVERT_STRING(data["checkin_number"])) đặt giá"
        } else {
            info.text = "\(CONVERT_STRING(data["follow_number"])) quan tâm | \(CONVERT_STRING(data["checkin_number"])) đặt giá"
        }
        
        
        icFollow.image = UIImage(named: "ic_join_normal")
        lblFollow.text = Localization("Quan Tâm")
        
    }
    
    @IBAction func clickLeft(sender: AnyObject) {
        activeLeft = !activeLeft
        if activeLeft {
            icFollow.image = UIImage(named: "ic_join_selected")
            lblFollow.text = Localization("Đã quan tâm")
        } else {
            icFollow.image = UIImage(named: "ic_join_normal")
            lblFollow.text = Localization("Quan Tâm")
        }
    }
    
    @IBAction func clickRight(sender: AnyObject) {
        activeRight = !activeRight
        if activeRight {
            icCheckIn.image = UIImage(named: "ic_checkin_selected")
        } else {
            icCheckIn.image = UIImage(named: "ic_checkin_normal")
        }
    }
    
    
    
}
