//
//  ProfileMainController.swift
//  wassup
//
//  Created by MAC on 9/12/16.
//  Copyright © 2016 MAC. All rights reserved.
//

import UIKit
import SKPhotoBrowser

class ProfileMainController: FeedsController {

    var detailUser:Dictionary<String,AnyObject>!
    override var sectionHasData: Int {
        return 3
    }
    var typeFeed = 0
    
    var images = [SKPhoto]()
    var browser = SKPhotoBrowser()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let inset = UIEdgeInsetsMake(45, 0, 0, 0)
        tableView.contentInset = inset;
        
        tableView.registerNib(UINib(nibName: "CellProfileHeaderInfo", bundle: nil), forCellReuseIdentifier: "CellProfileHeaderInfo")
        tableView.registerNib(UINib(nibName: "CellProfileHeaderFavorite", bundle: nil), forCellReuseIdentifier: "CellProfileHeaderFavorite")
        tableView.registerNib(UINib(nibName: "CellProfileHeaderPhoto", bundle: nil), forCellReuseIdentifier: "CellProfileHeaderPhoto")
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(changeTypeFeed(_:)), name: "CHANGE_TYPE_FEED_PROFILE", object: nil)
        
        if let d = detailUser["photos"] as? [String] {
            for a in d {
                let photo = SKPhoto.photoWithImageURL(a)
                images.append(photo)
            }
        }
        if images.count > 0 {
            browser = SKPhotoBrowser(photos: images)
        }
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(showBrowserImage(_:)), name: "SHOW_BROWSER_IMAGE", object: nil)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func showBrowserImage(noti:NSNotification) {
        let d = noti.userInfo as! Dictionary<String,AnyObject>
        browser.initializePageIndex(CONVERT_INT(d["index"]))
        presentViewController(browser, animated: true, completion: nil)
    }
    
    override func callAPI() {
        let md = Feeds()
        if typeFeed == 0 {
            md.getOwnerActivities(CONVERT_STRING(detailUser["id"]), index: page, callback: handleData)
        } else {
            md.getMyPost(CONVERT_STRING(detailUser["id"]), index: page) {
                (result:AnyObject?) in
                if result != nil {
                    if let d = result!["objects"] as? [Dictionary<String,AnyObject>] {
                        if d.count <= 0 {
                            self.isFinished = true
                        }
                        for a in d {
                            let objectId = a["id"]
                            if CONVERT_STRING(objectId) != "" {
                                self.data.append(a)
                                let lastIndexPath = NSIndexPath(forRow: self.data.count - 1, inSection: self.sectionHasData)
                                self.tableView.insertRowsAtIndexPaths([lastIndexPath], withRowAnimation: .None)
                            }
                        }
                    }
                    self.loading = false
                    self.ref.endRefreshing()
                }
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 4
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if section <= 2 {
            return 0
        }
        return data.count
    }
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        switch section {
        case 0:
            let cell = tableView.dequeueReusableCellWithIdentifier("CellProfileHeaderInfo") as! CellProfileHeaderInfo
            cell.initData(detailUser)
            return cell
        case 1:
            let cell = tableView.dequeueReusableCellWithIdentifier("CellProfileHeaderFavorite") as! CellProfileHeaderFavorite
            
            return cell
        case 2:
            let cell = tableView.dequeueReusableCellWithIdentifier("CellProfileHeaderPhoto") as! CellProfileHeaderPhoto
            cell.initData(detailUser)
            cell.selectTypeFeed.selectedSegmentIndex = typeFeed
            return cell
        default:
            return nil
        }
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch section {
        case 0:
            return 340
        case 1:
            if let tag = detailUser["tag"] as? [String] {
                if tag.count == 0 {
                    return 0
                }
                var heiListTag = CGFloat(0)
                let viewlistTags = TagListView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width - 30, height: 53))
                viewlistTags.paddingY = 10
                viewlistTags.paddingX = 15
                viewlistTags.marginY = 10
                viewlistTags.marginX = 10
                viewlistTags.removeAllTags()
                viewlistTags.cornerRadius = 15
                viewlistTags.borderWidth = 2
                for item in tag {
                    viewlistTags.addTag(item)
                }
                heiListTag = viewlistTags.intrinsicContentSize().height
                return 44 + heiListTag
            }
            return 0
        case 2:
            if let photos = detailUser["photos"] as? [String] {
                if photos.count <= 0 {
                    return 53
                }
                return 200
            }
            return 0
        default:
            return 0
        }
    }
    
    func changeTypeFeed(noti: NSNotification) {
        let d = noti.userInfo as! Dictionary<String,Int>
        typeFeed = d["typeFeed"]!
        page = 1
        data.removeAll()
        tableView.reloadSections(NSIndexSet(index:sectionHasData), withRowAnimation: .None)
        callAPI()
    }
    
    @IBAction func saveProfile(sender: UIStoryboardSegue) {
        if let sourceViewController = sender.sourceViewController as? EditProfileController, profile = sourceViewController.profile {
            Utils.lock()
            let md = User()
            let avatarData = profile["avatar"] as! UIImage
            let coverData = profile["cover"] as! UIImage
            self.title = CONVERT_STRING(profile["name"])
            
            md.updateProfile(CONVERT_STRING(profile["name"]), email: CONVERT_STRING(profile["email"]), address: CONVERT_STRING(profile["city"]), avatar: avatarData, cover: coverData) {
                (result:AnyObject?) in
                self.getProfile()
            }
        }
    }
    
    func getProfile() {
        Utils.lock()
        let md = User()
        md.getMyProfile() {
            (result:AnyObject?) in
            self.detailUser = result!["user"] as! Dictionary<String,AnyObject>
            self.tableView.reloadData()
            NSNotificationCenter.defaultCenter().postNotificationName("CHANGE_TITLE_PROFILE", object: nil, userInfo: self.detailUser)
        }
    }
}
