//
//  MasterViewController.swift
//  SplitViewTDList
//
//  Created by Jon Boling on 4/18/18.
//  Copyright © 2018 Walt Boling. All rights reserved.
//

import UIKit
import CoreData

class MasterViewController: UITableViewController, UIPopoverPresentationControllerDelegate {
    
    var masterLists = [NSManagedObject]()
        /*ListType(title: "Home", banner: .home),         //array spot 0
        ListType(title: "Office", banner: .office),     //array spot 1
        ListType(title: "Family", banner: .family),     //array spot 2
        ListType(title: "Personal", banner: .personal), //array spot 3
        ListType(title: "Shopping", banner: .shopping)  //array spot 4
    ]
 
    var fullToDoLists = [Array<String>()]
    */

    var fetchedResultsController: NSFetchedResultsController<MasterList>?
        
    @IBAction func createListWasTapped(_ sender: UIBarButtonItem) {
        let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: DataStructs.createMasterPopover )
        viewController.modalPresentationStyle = .popover
        let popover: UIPopoverPresentationController = viewController.popoverPresentationController!
        popover.barButtonItem = sender
        popover.delegate = self
        present(viewController, animated: true, completion:nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<MasterList>(entityName: DataStructs.masterEntity)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: DataStructs.masterTitle, ascending: true )]
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: managedContext, sectionNameKeyPath: nil, cacheName: DataStructs.masterCache)
        fetchedResultsController?.delegate = self 
        
        do {
            try fetchedResultsController?.performFetch()
        } catch {
            fatalError("Unable to fetch: \(error)")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //leah creating five empty spots for string arrays  to append
       /* fullToDoLists.append(["test", "test2"])
        fullToDoLists.append(Array<String>())
        fullToDoLists.append(Array<String>())
        fullToDoLists.append(Array<String>())
        fullToDoLists.append(Array<String>())*/
        
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == DataStructs.toDetailList {
            if let indexPath = self.tableView.indexPathForSelectedRow {
                let masterList = fetchedResultsController?.object(at: indexPath)
                let controller = (segue.destination as! UINavigationController).topViewController as! DetailViewController
                controller.masterList = masterList
      /*
                //leah added the switch below to pass the array list
                switch list.listTitle
                {
                case "Home":
                    controller.toDoItems = fullToDoLists[1]
                    break
                case "Office":
                    controller.toDoItems = fullToDoLists[2]
                    break
                case "Family":
                    controller.toDoItems = fullToDoLists[3]
                    break
                case "Personal":
                    controller.toDoItems = fullToDoLists[4]
                    break
                case "Shopping":
                    controller.toDoItems = fullToDoLists[5]
                    break
                default:
                    break
                }*/
                //end leah
            }
        }
    }

    
    // popover controls
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
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        guard let sectionInfo = fetchedResultsController?.sections?[section] else {
            fatalError("Failed to load fetched results controller")
        }
        
        return sectionInfo.numberOfObjects
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let fetchedResultsController = fetchedResultsController else {
            fatalError("Failed to load fetched results controller")
        }
        let masterCell = tableView.dequeueReusableCell(withIdentifier: DataStructs.masterCell, for: indexPath)
        let masterList = fetchedResultsController.object(at: indexPath)
        masterCell.textLabel?.text = masterList.masterTitle
            return masterCell
    }

    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */


}

//NSFetchedResultsControllerDelegate Methods
extension MasterViewController: NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controller(_ control: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            guard let newIndexPath = newIndexPath else {
                fatalError("New index path is nil")
            }
            
            tableView.insertRows(at: [newIndexPath], with: .automatic)
        case .delete:
            guard let indexPath = indexPath else {
                fatalError("Index path is nil")
            }
            
            tableView.deleteRows(at: [indexPath], with: .automatic)
        case .move:
            guard let newIndexPath = newIndexPath,
                let indexPath = indexPath else {
                    fatalError("Index path or new index path is nil?")
            }
            
            tableView.deleteRows(at: [indexPath], with: .automatic)
            tableView.insertRows(at: [newIndexPath], with: .automatic)
        case .update:
            guard let indexPath = indexPath else {
                fatalError("Index path is nil")
            }
            
            tableView.reloadRows(at: [indexPath], with: .automatic)
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
    
}
