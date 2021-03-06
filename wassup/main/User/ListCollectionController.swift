//
//  ListCollectionController.swift
//  wassup
//
//  Created by MAC on 9/13/16.
//  Copyright © 2016 MAC. All rights reserved.
//

import UIKit

class ListCollectionController: UIViewController {

    @IBOutlet weak var btnSave: UIBarButtonItem!
    @IBOutlet weak var constraintTop: NSLayoutConstraint!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var btnCollection: UIButton!
    
    var userId = ""
    let marginTop = CGFloat(8)
    var typeListCollection = "save"
    var data = [Dictionary<String,AnyObject>]()
    var dataProfile = Dictionary<String,AnyObject>()
    var radioController = SSRadioButtonsController()
    var selectedCollection = -1
    var objectType = CollectionType.Feed
    var objectId = ""
    var selectedItemCollection:Dictionary<String,AnyObject>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if typeListCollection == "list" {
            constraintTop.constant = 45 + marginTop
        }
        radioController.delegate = self
        callAPI()
    }
    
    override func viewDidAppear(animated: Bool) {
//        data.removeAll()
//        tableView.reloadData()
//        callAPI()
    }
    
    func callAPI() {
        let md = Collection()
        if dataProfile.count <= 0 {
            Utils.lock()
            md.getMyCollections(handleData)
        } else {
            handleData(dataProfile)
        }
    }
    
    func handleData(result:AnyObject?) {
        let data = result!["collections"] as! [Dictionary<String,AnyObject>]
        for a:Dictionary<String,AnyObject> in data {
            self.data.append(a)
            let lastIndexPath = NSIndexPath(forRow: self.data.count - 1, inSection: 0)
            self.tableView.insertRowsAtIndexPaths([lastIndexPath], withRowAnimation: .None)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func clickCreateCollection(sender: AnyObject) {
        performSegueWithIdentifier("CreateCollection", sender: nil)
    }
    
    @IBAction func clickSaveCollection(sender: AnyObject) {
        
    }
    
    @IBAction func unwind(sender: UIStoryboardSegue) {
        navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func close(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func createBookmark(sender: UIStoryboardSegue) {
        if let sourceViewController = sender.sourceViewController as? CreateCollectionController, itemCollection = sourceViewController.itemCollection {
            let md = Collection()
            md.createCollection(itemCollection.name, icon: itemCollection.avatar) {
                (result: AnyObject?) in
                    self.data.removeAll()
                    self.tableView.reloadData()
                    self.callAPI()
            }
        }
    }
    
    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
        if sender === btnSave {
            if selectedCollection < 0 {
                let alert = UIAlertView(title: Localization("Thông báo"), message: "", delegate: nil, cancelButtonTitle: "OK")
                alert.message = Localization("Bạn chưa chọn collection")
                alert.show()
                return false
            }
            selectedItemCollection = data[selectedCollection] as! Dictionary<String,String>
            
        }
        return true
    }
}

extension ListCollectionController: UITableViewDelegate, UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.data.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! CellListCollection
        cell.initData(data[indexPath.row])
        radioController.addButton(cell.radioBtn)
        cell.radioBtn.tag = indexPath.row
        if typeListCollection == "list" {
            cell.radioBtn.hidden = true
        }
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        performSegueWithIdentifier("DetailCollection", sender: nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "DetailCollection" {
            let vc = segue.destinationViewController as! DetailCollectionController
            let d = data[(tableView.indexPathForSelectedRow?.row)!]
            vc.collectionId = CONVERT_STRING(d["id"])
        }
    }
}

extension ListCollectionController: SSRadioButtonControllerDelegate {
    func didSelectButton(aButton: UIButton?) {
        selectedCollection = aButton!.tag
    }
}
