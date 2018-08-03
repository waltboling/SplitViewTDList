//
//  DetailViewController.swift
//  SplitViewTask
//
//  Created by Jon Boling on 4/18/18.
//  Copyright © 2018 Walt Boling. All rights reserved.
//

import UIKit
import CloudKit
import ChameleonFramework

class DetailViewController: UIViewController, UITextFieldDelegate {
    
    var detailItems = [CKRecord]()
    var masterList: CKRecord?
    var refresh = UIRefreshControl()
    let backgroundColor: [UIColor] = [
        UIColor.flatPlumDark,
        UIColor.flatPurple
    ]
    
    //var fetchedResultsController: NSFetchedResultsController<DetailList>?
    
    @IBOutlet weak var detailTableView: UITableView!
    @IBOutlet weak var inputToDo: UITextField!
    @IBOutlet weak var bannerView: UIImageView!
    
    @IBAction func addButtonWasTapped(_ sender: Any) {
        detailItemWasEntered()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        inputToDo.resignFirstResponder()
        detailItemWasEntered()
        return true
    }
    
    func detailItemWasEntered() {
        /*let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: DataStructs.detailEntity, in: context)*/
        //let newDetail = NSManagedObject(entity: entity!, insertInto: context)
        
        if inputToDo.text != "" {
            let newDetail = CKRecord(recordType: "detailItems")
            newDetail["content"] = inputToDo.text as CKRecordValue?
            
            if let list = self.masterList {
                let reference = CKReference(recordID: list.recordID, action: .deleteSelf)
                newDetail.setObject(reference, forKey: "masterList")
                
                let publicDatabase = CKContainer.default().publicCloudDatabase
                
                publicDatabase.save(newDetail, completionHandler: { (record: CKRecord?, error: Error?) in
                    if error == nil {
                        print("list saved")
                        DispatchQueue.main.async(execute: {
                            self.detailTableView.beginUpdates()
                            self.detailItems.insert(newDetail, at: 0)
                            let indexPath = IndexPath(row: 0, section: 0)
                            self.detailTableView.insertRows(at: [indexPath], with: .top)
                            self.detailTableView.endUpdates()
                        })
                    } else {
                        print("Error: \(error.debugDescription)")
                    }
                })
            }
        }
          /*  newDetail.setValue(inputToDo.text, forKey: DataStructs.detailTitle)
            newDetail.setValue(masterList.value(forKey: DataStructs.masterTitle), forKey: DataStructs.parentTitle)
             }
        
        appDelegate.saveContext()*/
        
        inputToDo.text = ""
    }
    
    /*override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        //if we have a selected list - pull that data
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<DetailList>(entityName: DataStructs.detailEntity)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: DataStructs.detailTitle, ascending: true )]
        
        if let currentList = self.masterList
        {
            fetchRequest.predicate = NSPredicate(format: DataStructs.parentTitle + " == %@",
                currentList.value(forKey: DataStructs.masterTitle) as! CVarArg)
        }
        else {
            fetchRequest.predicate = NSPredicate(format: "\(DataStructs.parentTitle) == %@", "")
        }
        
        //correlating detail and master lists via "parentTitle" attribute
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: managedContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController?.delegate = self
        
        do {
            try fetchedResultsController?.performFetch()
        } catch {
            fatalError("Unable to fetch: \(error)")
        }
    }*/
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = GradientColor(.topToBottom, frame: view.frame, colors: backgroundColor)
        
        detailTableView.backgroundColor = .clear
        if let list = masterList {
            self.navigationItem.title = list["listName"] as? String
            
            let publicDatabase = CKContainer.default().publicCloudDatabase
            let reference = CKReference(recordID: list.recordID, action: .deleteSelf)
            let query = CKQuery(recordType: "detailItems", predicate: NSPredicate(format:"masterList == %@", reference))
            publicDatabase.perform(query, inZoneWith: nil) { (results: [CKRecord]?, error: Error?) in
                if let items = results {
                    self.detailItems = items
                    DispatchQueue.main.async(execute: {
                        self.detailTableView.reloadData()
                        self.refresh.endRefreshing()
                    })
                }
            }
        }
        /*if let detailList = self.masterList {
            navigationItem.title = detailList.value(forKey: DataStructs.masterTitle) as? String
            //  need to redo image features of app: old version -> bannerView.image = detailList.bannerImage
            //navigationItem.rightBarButtonItem = editButtonItem*/
            
            self.inputToDo.delegate = self
    }
    
    //if edit button re-added
    /*override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        
        if editing {
            detailTableView.setEditing(true, animated: true)
        } else {
            detailTableView.setEditing(false, animated: true)
        }
    }*/
}

extension DetailViewController: UITableViewDelegate {
    
   /* func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        if indexPath.row >= (fetchedResultsController?.sections?[indexPath.section].numberOfObjects)! {
            return .insert
        } else {
            return .delete
        }
    }*/
    
    /* if move function re-added, need to adapt for core data
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if isEditing && indexPath.row < toDoItems.count {
            return nil
        }
        return indexPath
    }
    
    func tableView(_ tableView: UITableView, targetIndexPathForMoveFromRowAt sourceIndexPath: IndexPath, toProposedIndexPath proposedDestinationIndexPath: IndexPath) -> IndexPath {
        
        if proposedDestinationIndexPath.row >= toDoItems.count {
            return IndexPath(row: toDoItems.count - 1, section: proposedDestinationIndexPath.section)
        }
        return proposedDestinationIndexPath
    }*/
}

extension DetailViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return detailItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let detailCell = tableView.dequeueReusableCell(withIdentifier: DataStructs.detailCell, for: indexPath)
        let item = detailItems[indexPath.row]
        
        if let detailItemName = item["content"] as? String {
            
        detailCell.textLabel?.text = detailItemName
        detailCell.backgroundColor = .clear
        detailCell.textLabel?.textColor = .white
        detailCell.textLabel?.font = UIFont(name:"Dense-Regular", size: 22)
        }
        return detailCell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool{
        return true
    }
    
    //deleting a cell
    /*func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
       let appDelegate = UIApplication.shared.delegate as! AppDelegate
        if editingStyle == UITableViewCellEditingStyle.delete {
            let detailListItem = fetchedResultsController?.object(at: indexPath)
            fetchedResultsController?.managedObjectContext.delete(detailListItem!)
           
            appDelegate.saveContext()
        }
    }
    /* if move re-added, need to update for core data
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        if indexPath.row >= toDoItems.count && isEditing {
            return false
        }
        return true
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let itemToMove = toDoItems[sourceIndexPath.row]
        toDoItems.remove(at: sourceIndexPath.row)
        
        if sourceIndexPath.section == destinationIndexPath.section {
            toDoItems.insert(itemToMove, at: destinationIndexPath.row)
        }
    }*/
    
}

extension DetailViewController: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
       detailTableView.beginUpdates()
    }
    
    func controller(_ control: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            guard let newIndexPath = newIndexPath else {
                fatalError("New index path is nil")
            }
            
            detailTableView.insertRows(at: [newIndexPath], with: .automatic)
        case .delete:
            guard let indexPath = indexPath else {
                fatalError("Index path is nil")
            }
            
            detailTableView.deleteRows(at: [indexPath], with: .automatic)
        case .move:
            guard let newIndexPath = newIndexPath,
                let indexPath = indexPath else {
                    fatalError("Index path or new index path is nil?")
            }
            
            detailTableView.deleteRows(at: [indexPath], with: .automatic)
            detailTableView.insertRows(at: [newIndexPath], with: .automatic)
        case .update:
            guard let indexPath = indexPath else {
                fatalError("Index path is nil")
            }
            
            detailTableView.reloadRows(at: [indexPath], with: .automatic)
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        detailTableView.endUpdates()
    }*/
}




