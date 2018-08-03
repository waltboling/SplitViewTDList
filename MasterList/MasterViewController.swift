//
//  MasterViewController.swift
//  SplitViewTDList
//
//  Created by Jon Boling on 4/18/18.
//  Copyright © 2018 Walt Boling. All rights reserved.
//

import UIKit
//import CoreData
import CloudKit
import ChameleonFramework

class MasterViewController: UITableViewController, UIPopoverPresentationControllerDelegate {

    var masterLists = [CKRecord]()
    var refresh = UIRefreshControl()
    //var fetchedResultsController: NSFetchedResultsController<MasterList>?
    var detailController: DetailViewController?
    //var currentMasterList: NSManagedObject?
    private let mainStoryboard = "Main"
    let backgroundColor: [UIColor] = [
        UIColor.flatTeal,
        UIColor.flatMintDark
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        refresh = UIRefreshControl()
        refresh.attributedTitle = NSAttributedString(string: "Pull to load Lists")
        refresh.addTarget(self, action: #selector(MasterViewController.loadLists), for: .valueChanged)
        tableView.addSubview(refresh)
        
        NotificationCenter.default.addObserver(self, selector: #selector(loadLists), name: NSNotification.Name(rawValue: "load"), object: nil)
        
        self.loadLists()
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.backgroundColor = GradientColor(.topToBottom, frame: view.frame, colors: backgroundColor)
        
        /*DispatchQueue.main.async(execute: {
            self.loadLists()
        })*/
        
    }
    
    /*override func viewDidAppear(_ animated: Bool) {
        self.loadLists()
    }*/

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == DataStructs.toDetailList {
            if let indexPath = self.tableView.indexPathForSelectedRow {
                let currentMasterList = masterLists[indexPath.row]
                let controller = (segue.destination as! UINavigationController).topViewController as! DetailViewController
                controller.masterList = currentMasterList
            }
        }
    }

    // popover controls
    @IBAction func createListWasTapped(_ sender: UIBarButtonItem) {
        let storyboard : UIStoryboard = UIStoryboard(name: mainStoryboard, bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: DataStructs.createMasterPopover )
        viewController.modalPresentationStyle = .popover
        let popover: UIPopoverPresentationController = viewController.popoverPresentationController!
        
        popover.barButtonItem = sender
        popover.delegate = self
        present(viewController, animated: true, completion:nil)
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .fullScreen
    }
    
    func presentationController(_ controller: UIPresentationController, viewControllerForAdaptivePresentationStyle style: UIModalPresentationStyle) -> UIViewController? {
        let navigationController = UINavigationController(rootViewController: controller.presentedViewController)
        let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(MasterViewController.dismissViewController))
        navigationController.topViewController?.navigationItem.rightBarButtonItem = doneButton
        return navigationController
    }

    
    @objc func dismissViewController() {
        self.dismiss(animated: true, completion: nil)
        
        //self.loadLists()
    }
    
    //end of popover controls
    
    @objc func loadLists() {
        print("in loadLists")
        let publicDatabase = CKContainer.default().publicCloudDatabase
        let query = CKQuery(recordType: "MasterLists", predicate: NSPredicate(format: "TRUEPREDICATE", argumentArray: nil))
       // query.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        publicDatabase.perform(query, inZoneWith: nil) { (results: [CKRecord]?, error: Error?) in
            if let lists = results {
                self.masterLists = lists
                print("\(self.masterLists.count) masterLists in loadLists")
                DispatchQueue.main.async(execute: {
                    self.tableView.reloadData()
                    self.refresh.endRefreshing()
                })
            }
        }
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        print("\(masterLists.count) records")
        return masterLists.count
        
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       
        let masterCell = tableView.dequeueReusableCell(withIdentifier: DataStructs.masterCell, for: indexPath)
        let masterList = masterLists[indexPath.row]
        
        if let masterListName = masterList["listName"] as? String {
            masterCell.textLabel?.text = masterListName
        }
        
        masterCell.backgroundColor = .clear
        masterCell.textLabel?.font = UIFont(name:"Dense-Regular", size: 26)
    
            return masterCell
    }
   
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let selectedRecordID = masterLists[indexPath.row].recordID
            
            let publicDatabase = CKContainer.default().publicCloudDatabase
            
            publicDatabase.delete(withRecordID: selectedRecordID) { (recordID, error) -> Void in
                if error != nil {
                    print(error!)
                } else {
                    OperationQueue.main.addOperation({ () -> Void in
                        self.masterLists.remove(at: indexPath.row)
                        self.tableView.reloadData()
                    })
                }
            }
        }
    }
}

