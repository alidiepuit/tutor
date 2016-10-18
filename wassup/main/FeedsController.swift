//
//  FeedsController.swift
//  wassup
//
//  Created by MAC on 8/18/16.
//  Copyright (c) 2016 MAC. All rights reserved.
//

import UIKit
import SKPhotoBrowser

class FeedsController: UITableViewController {
    
    var page = 1
    var data = [Dictionary<String, AnyObject>]()
    let ref = UIRefreshControl()
    var loading = false
    var isFinished = false
    var indexPath = NSIndexPath(index: 0)
    var sectionHasData:Int {
        return 0
    }
    var showCover:Bool {
        return true
    }
    var detailProfile:Dictionary<String,AnyObject>!
    var canClickCell:Bool {
        return true
    }
    var heightForRows = [Int:CGFloat]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
//        callAPI()
    }
    
    override func viewWillAppear(animated: Bool) {
        initTable()
    }
    
    override func viewWillDisappear(animated: Bool) {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func initTable() {
        
        tableView.registerNib(UINib(nibName: "CellFeed", bundle: nil), forCellReuseIdentifier: "CellFeed")
        
        ref.addTarget(self, action: #selector(refreshData(_:)), forControlEvents: .ValueChanged)
        tableView.addSubview(ref)
        
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "CLICK_TAG_ON_FEED", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(clickTagOnFeed), name: "CLICK_TAG_ON_FEED", object: nil)
        
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "CLICK_STATUS_GO_TO_DETAIL_EVENT_ON_FEED", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(clickStatusGoToDetailEventOnFeed), name: "CLICK_STATUS_GO_TO_DETAIL_EVENT_ON_FEED", object: nil)
        
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "CLICK_STATUS_GO_TO_PROFILE_ON_FEED", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(clickStatusGoToProfileOnFeed), name: "CLICK_STATUS_GO_TO_PROFILE_ON_FEED", object: nil)
        
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "CLICK_BOOKMARK_ON_FEED", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(clickBookmarkOnFeed(_:)), name: "CLICK_BOOKMARK_ON_FEED", object: nil)
        
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "BROWSER_PHOTOS_ON_FEED", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(browserPhotosOnFeed(_:)), name: "BROWSER_PHOTOS_ON_FEED", object: nil)
        
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "CLICK_LIKE_ON_FEED", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(clickLikeOnFeed(_:)), name: "CLICK_LIKE_ON_FEED", object: nil)
        
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "POST_MESSAGE_FROM_FEED", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(postMessageFromFeed(_:)), name: "POST_MESSAGE_FROM_FEED", object: nil)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func browserPhotosOnFeed(noti:NSNotification) {
        let d = noti.userInfo as! Dictionary<String,AnyObject>
        let idx = CONVERT_INT(d["index"])
        let images = d["images"] as! [SKPhoto]
        let browser = SKPhotoBrowser(photos: images)
        browser.initializePageIndex(idx)
        Utils.presentViewController(browser, animated: true, completion: nil)
    }
    
    func clickTagOnFeed(noti: NSNotification) {
        let d = noti.userInfo as! Dictionary<String,String>
        GLOBAL_KEYWORD = d["keyword"]!
        performSegueWithIdentifier("SearchKeyword", sender: nil)
    }
    
    func clickStatusGoToDetailEventOnFeed(noti: NSNotification) {
        let d = noti.userInfo as! Dictionary<String,AnyObject>
        self.tableView(tableView, didSelectRowAtIndexPath: d["indexPath"] as! NSIndexPath)
    }
    
    func clickBookmarkOnFeed(noti: NSNotification) {
        let d = noti.userInfo as! Dictionary<String,AnyObject>
        indexPath = d["indexPath"] as! NSIndexPath
        performSegueWithIdentifier("SaveCollection", sender: nil)
    }
    
    func clickLikeOnFeed(noti: NSNotification) {
        let userInfo = noti.userInfo as! Dictionary<String,AnyObject>
        
        indexPath = userInfo["indexPath"] as! NSIndexPath
        var d = self.data[self.indexPath.row]
        d["like"] = userInfo["like"]
        d["is_like"] = userInfo["is_like"]
        let id = CONVERT_STRING(d["id"])
        self.data[self.indexPath.row] = d
        self.tableView.reloadRowsAtIndexPaths([self.indexPath], withRowAnimation: .Automatic)
        
        let md = User()
        md.likeFeed(id)
    }
    
    func postMessageFromFeed(noti: NSNotification) {
        let userInfo = noti.userInfo as! Dictionary<String,String>
        postMessage(userInfo["msg"]!)
    }
    
    func postMessage(str: String) {
        self.showMessage(str, type: .Info, options: [.Animation(.Slide),
            .AnimationDuration(0.3),
            .AutoHide(true),
            .AutoHideDelay(2.0),
            .Height(44.0),
            .HideOnTap(true),
            .Position(.Bottom),
            .TextAlignment(.Center),
            .TextColor(UIColor.whiteColor()),
            .TextNumberOfLines(1),
            .TextPadding(30.0)], delegate: nil)
    }
    
    @IBAction func saveBookmark(sender: UIStoryboardSegue) {
        if let sourceViewController = sender.sourceViewController as? ListCollectionController, item = sourceViewController.selectedItemCollection {
            let data = self.data[indexPath.row]
            let objectId = CONVERT_STRING(data["id"])
            let objectType = CollectionType.Feed
            let md = Collection()
            md.bookmark(CONVERT_STRING(item["id"]), collectionName: CONVERT_STRING(item["name"]), objectId: objectId, objectType: objectType.rawValue) {
                (result:AnyObject?) in
                if let res = result as? Dictionary<String,AnyObject> {
                    let status = CONVERT_INT(res["status"])
                    if status == 1 {
                        var d = self.data[self.indexPath.row]
                        d["is_bookmark"] = 1
                        self.data[self.indexPath.row] = d
                        self.tableView.reloadRowsAtIndexPaths([self.indexPath], withRowAnimation: .Automatic)
                    }
                }
            }
        }
    }
    
    func clickStatusGoToProfileOnFeed(noti: NSNotification) {
        let d = noti.userInfo as! Dictionary<String,String>
        let md = User()
        md.getUserProfile(d["userId"]!) {
            (result:AnyObject?) in
            self.detailProfile = result!["user"] as! Dictionary<String,AnyObject>
            self.performSegueWithIdentifier("DetailProfile", sender: nil)
        }
    }
    
    func refreshData(ref: UIRefreshControl) {
        reloadDataWhenAppear()
    }
    
    func reloadDataWhenAppear() {
        callAPI()
    }
    
    func callAPI() {
        tableView.reloadData()
        ref.endRefreshing()
    }
    
    func handleData(result:AnyObject?) {
        
    }
    
    override func viewDidAppear(animated: Bool) {
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: Table View Delegate
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
//        print("cellForRowAtIndexPath", self.data.count)
        if sectionHasData == indexPath.section {
            let cell = tableView.dequeueReusableCellWithIdentifier("CellFeed", forIndexPath: indexPath) as! CellFeed
            return cell
        }
        let cell = tableView.dequeueReusableCellWithIdentifier("CellFeed", forIndexPath: indexPath)
        return cell
    }
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "SearchKeyword" {
            let dest = segue.destinationViewController as! SearchKeyword
            dest.searchBar.text = GLOBAL_KEYWORD
        }
        if segue.identifier == "DetailEvent" {
            print(self.data.count)
            let vc = segue.destinationViewController as! DetailEventController
            let d:Dictionary<String,AnyObject> = self.data[self.indexPath.row]
            if let item:Dictionary<String,AnyObject> = d["item"] as? Dictionary<String,AnyObject> {
                var dd = Dictionary<String,String>()
                dd["name"] = CONVERT_STRING(item["title"])
                if CONVERT_STRING(item["event_id"]) != "" {
                    vc.cate = ObjectType.Event
                    dd["id"] = CONVERT_STRING(item["event_id"])
                } else if CONVERT_STRING(item["host_id"]) != "" {
                    vc.cate = ObjectType.Host
                    dd["id"] = CONVERT_STRING(item["host_id"])
                }
                vc.data = dd
            }
        }
        
        if segue.identifier == "DetailProfile" {
            let navi = segue.destinationViewController as! UINavigationController
            let vc = navi.topViewController as! ProfileController
            vc.data = detailProfile
        }
        
        if segue.identifier == "SaveCollection" {
            let nav = segue.destinationViewController as! UINavigationController
            let vc = nav.topViewController as! ListCollectionController
            let d:Dictionary<String,AnyObject> = self.data[indexPath.row]
            vc.objectId = CONVERT_STRING(d["id"])
            vc.objectType = CollectionType.Feed
        }
    }
    
    @IBAction func unwind(sender: UIStoryboardSegue) {
        navigationController?.popViewControllerAnimated(true)
    }
}
