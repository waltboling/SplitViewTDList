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
    var toDoItems = [String]()
    
    
    @IBOutlet weak var inputToDo: UITextField!
    @IBOutlet weak var toDoTableView: UITableView!
    @IBOutlet weak var bannerView: UIImageView!
    
    @IBAction func addButtonWasTapped(_ sender: Any) {
        if (inputToDo.text != "") {
            toDoItems.append(inputToDo.text!)
        }
        toDoTableView.reloadData()
        
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
        toDoTableView.reloadData()
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
            toDoTableView.setEditing(true, animated: true)
        } else {
            toDoTableView.setEditing(false, animated: true)
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
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return toDoItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "toDoItem", for: indexPath)
        cell.textLabel?.text = toDoItems[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCellEditingStyle.delete {
            self.toDoItems.remove(at: indexPath.row)
            toDoTableView.reloadData()
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




