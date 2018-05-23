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
    var fetchedResultsController: NSFetchedResultsController<MasterList>?
    var detailController: DetailViewController?
    var currentMasterList: NSManagedObject?
    private let mainStoryboard = "Main"
    
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

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == DataStructs.toDetailList {
            if let indexPath = self.tableView.indexPathForSelectedRow {
                currentMasterList = (fetchedResultsController?.object(at: indexPath))!
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
