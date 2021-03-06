//
//  CellProfileHeaderInfo.swift
//  wassup
//
//  Created by MAC on 9/12/16.
//  Copyright © 2016 MAC. All rights reserved.
//

import UIKit

class CellProfileHeaderInfo: UITableViewCell {

    @IBOutlet weak var avatar: UIImageView!
    @IBOutlet weak var cover: UIImageView!
    @IBOutlet weak var namefuck: UILabel!
    @IBOutlet weak var lblView: UILabel!
    @IBOutlet weak var lblFollow: UILabel!
    @IBOutlet weak var lblCheckIn: UILabel!
    @IBOutlet weak var btnFollow: UIButton!
    @IBOutlet weak var btnEdit: UIButton!
    @IBOutlet weak var btnFollowed: UIButton!
    
    var userId = ""
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func initData(data:Dictionary<String,AnyObject>) {
        Utils.loadImage(avatar, link: CONVERT_STRING(data["image"]))
        Utils.loadImage(cover, link: CONVERT_STRING(data["banner"]))
        namefuck.text = CONVERT_STRING(data["fullname"])
        lblView.text = CONVERT_STRING(data["hit"])
        lblFollow.text = CONVERT_STRING(data["attend_number"])
        lblCheckIn.text = CONVERT_STRING(data["checkin_number"])
        
        avatar.corner(47, border: 0, colorBorder: 0x000000)
        
        userId = CONVERT_STRING(data["id"])
        if userId == User.sharedInstance.userId {
            btnFollow.hidden = true
            btnFollowed.hidden = true
        } else {
            btnEdit.hidden = true
            let isFollow = CONVERT_BOOL(data["is_follow"])
            btnFollow.hidden = isFollow
            btnFollowed.hidden = !isFollow
        }
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction func clickEditProfile(sender: AnyObject) {
        NSNotificationCenter.defaultCenter().postNotificationName("EDIT_PROFILE", object: nil)
    }
    
    @IBAction func clickUnFollow(sender: AnyObject) {
        let md = User()
        md.followUser(userId)
        btnFollow.hidden = false
        btnFollowed.hidden = true
    }
    
    @IBAction func clickFollow(sender: AnyObject) {
        let md = User()
        md.followUser(userId)
        btnFollow.hidden = true
        btnFollowed.hidden = false
    }
}
