//
//  CreateMasterListVC.swift
//  SplitViewTDList
//
//  Created by Jon Boling on 5/18/18.
//  Copyright © 2018 Walt Boling. All rights reserved.
//

import UIKit
import CoreData

class CreateMasterListVC: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var inputNewMaster: UITextField!
    
    @IBAction func addButtonWasTapped(_ sender: Any) {
        masterListWasCreated()
    }
    
    override func viewDidLoad() {
        self.inputNewMaster.delegate = self
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        masterListWasCreated()
        return true
    }
    
    func masterListWasCreated() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: DataStructs.masterEntity, in: context)
        let newMaster = NSManagedObject(entity: entity!, insertInto: context)
        
        if inputNewMaster.text != "" {
            newMaster.setValue(inputNewMaster.text, forKey: DataStructs.masterTitle)
        }
        
        appDelegate.saveContext()
        
        dismissViewController()
    }
    
    @objc func dismissViewController() {
        self.dismiss(animated: true, completion: nil)
    }
}
