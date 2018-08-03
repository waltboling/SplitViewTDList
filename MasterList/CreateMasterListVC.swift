//
//  CreateMasterListVC.swift
//  SplitViewTDList
//
//  Created by Jon Boling on 5/18/18.
//  Copyright © 2018 Walt Boling. All rights reserved.
//

import UIKit
//import CoreData
import CloudKit
import ChameleonFramework

class CreateMasterListVC: UIViewController, UITextFieldDelegate {
    var masterLists = [CKRecord]()
    let backgroundColor: [UIColor] = [
        UIColor.flatTeal,
        UIColor.flatMintDark
    ]
    
    @IBOutlet weak var inputNewMaster: UITextField!
    
    @IBOutlet weak var backgroundImage: UIImageView!
    
    @IBAction func addButtonWasTapped(_ sender: Any) {
        masterListWasCreated()
    }
    
    override func viewDidLoad() {
        self.inputNewMaster.delegate = self
        view.backgroundColor = GradientColor(.topToBottom, frame: view.frame, colors: backgroundColor)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        masterListWasCreated()
        return true
    }
    
    func masterListWasCreated() {
        /*let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: DataStructs.masterEntity, in: context)
        let newMaster = NSManagedObject(entity: entity!, insertInto: context)
        */
        if inputNewMaster.text != "" {
            let newList = CKRecord(recordType: "MasterLists")
            newList["listName"] = inputNewMaster.text as CKRecordValue?
            let publicDatabase = CKContainer.default().publicCloudDatabase
    
            DispatchQueue.main.async(execute: {
                publicDatabase.save(newList, completionHandler: { (record: CKRecord?, error: Error?) in
                    if error == nil {
                        print("list saved")
                    } else {
                        print("Error: \(error.debugDescription)")
                    }
                })
                
            })
        }
        
        //appDelegate.saveContext()
        
        
        dismissViewController()
    }
    
    @objc func dismissViewController() {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "load"), object: nil)
        self.dismiss(animated: true, completion: nil)
        

    }
}
