//
//  DetailViewController.swift
//  SplitViewTask
//
//  Created by Jon Boling on 4/18/18.
//  Copyright © 2018 Walt Boling. All rights reserved.
//

import UIKit
import CoreData

class DetailViewController: UIViewController {
    
    var masterList: NSManagedObject!
    var toDoItems = [NSManagedObject]()
    
    var fetchedResultsController: NSFetchedResultsController<DetailList>?
    
    @IBOutlet weak var detailTableView: UITableView!
    @IBOutlet weak var inputToDo: UITextField!
    @IBOutlet weak var bannerView: UIImageView!
    
    @IBAction func addButtonWasTapped(_ sender: Any) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: DataStructs.detailEntity, in: context)
        let newDetail = NSManagedObject(entity: entity!, insertInto: context)
        
        if inputToDo.text != "" {
            newDetail.setValue(inputToDo.text, forKey: DataStructs.detailTitle)
        }
        
        appDelegate.saveContext()
        
        inputToDo.text = ""
    }
    
    //trying to get return key to function same as add button
    /*func textFieldShouldReturn(_ textField: UITextField) -> Bool {
     textField.resignFirstResponder()
     return true
     }*/
    override func viewWillDisappear(_ animated: Bool) {
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<DetailList>(entityName: DataStructs.detailEntity)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: DataStructs.detailTitle, ascending: true )]
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: managedContext, sectionNameKeyPath: nil, cacheName: DataStructs.detailCache)
        fetchedResultsController?.delegate = self
        
        do {
            try fetchedResultsController?.performFetch()
        } catch {
            fatalError("Unable to fetch: \(error)")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let detailList = self.masterList {
            navigationItem.title = detailList.value(forKey: "masterTitle") as? String
         //   bannerView.image = detailList.bannerImage
            
            navigationItem.rightBarButtonItem = editButtonItem

        }
        
        //trying to get return key to function same as add button
        //inputToDo.delegate = self as? UITextFieldDelegate
        
    }
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        
        if editing {
            detailTableView.setEditing(true, animated: true)
        } else {
            detailTableView.setEditing(false, animated: true)
        }
    }
}

extension DetailViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        if indexPath.row >= toDoItems.count {
            return .insert
        } else {
            return .delete
        }
    }
    
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
    }
}

extension DetailViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sectionInfo = fetchedResultsController?.sections?[section] else {
            fatalError("Failed to load fetched results controller")
        }
        
        return sectionInfo.numberOfObjects
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let fetchedResultsController = fetchedResultsController else {
            fatalError("Failed to load fetched results controller")
        }
        let detailCell = tableView.dequeueReusableCell(withIdentifier: DataStructs.detailCell, for: indexPath)
        let detailList = fetchedResultsController.object(at: indexPath)
        detailCell.textLabel?.text = detailList.detailTitle
        return detailCell
    }
    
    //Still need to update editing functions for CoreData
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCellEditingStyle.delete {
            self.toDoItems.remove(at: indexPath.row)
            detailTableView.reloadData()
        }
    }
    
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
    }
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
    }
}




