//
//  CDSpyEntityDetailsTableViewController.swift
//  DebugWindowKit
//
//  Created by Ryan Moniz on 3/15/19.
//  Copyright © 2019 Ryan Moniz. All rights reserved.
//

import UIKit
import CoreData

fileprivate struct CDSpyEntityDetailsSection {
    static let attributesIndex = 0
    static let relationshipIndex = 1
}

class CDSpyEntityDetailsTableViewController: UITableViewController {

    //view model with name of entity
    //attributes/property and type
    //section for attributes and section for relationship
    
    var managedObjectModel: NSManagedObjectModel?
    var context: NSManagedObjectContext?
    var entityName:String = "<Entity Name>"
    var attributes = [String]()
    var relationships = [String]()
    var record: NSManagedObject?
    var attributeTypes = [String:String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.title = entityName

    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (section == CDSpyEntityDetailsSection.attributesIndex) {
            return attributes.count
        } else if (section == CDSpyEntityDetailsSection.relationshipIndex) {
            return relationships.count
        }
        return 0
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if (section == CDSpyEntityDetailsSection.attributesIndex) {
            return "Attributes"
        } else if (section == CDSpyEntityDetailsSection.relationshipIndex) {
            return "Relationships"
        }
        return nil
    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EntityDetailsCellIdentifier", for: indexPath)

        if (indexPath.section == CDSpyEntityDetailsSection.attributesIndex) {
            if let moc = self.context {
                moc.perform {
                    let index = indexPath.row
                    let attributeKey = self.attributes[index]
                    var attributeValueAndType = "nil"
                    if let value: Any = self.record?.value(forKey: attributeKey) {
                        attributeValueAndType = "\(value)"
                    }
                    DispatchQueue.main.async {
                        cell.textLabel?.text = attributeValueAndType
                        if let typeForValue = self.attributeTypes[attributeKey] {
                            cell.detailTextLabel?.text = attributeKey + " : " + typeForValue
                        } else {
                            cell.detailTextLabel?.text = attributeKey + " : Unknown?"
                        }
                        
                        cell.accessoryType = UITableViewCell.AccessoryType.none
                    }
                }
            }
        } else if (indexPath.section == CDSpyEntityDetailsSection.relationshipIndex) {
            if let moc = self.context {
                moc.perform {
                    let index = indexPath.row
                    let relationshipKey = self.relationships[index]
                    var relationshipObj = "nil"
                    if let value: Any = self.record?.value(forKey: relationshipKey) {
                        relationshipObj = "\(value)"
                    }
                    DispatchQueue.main.async {
                        cell.textLabel?.text = relationshipObj
                        cell.detailTextLabel?.text = relationshipKey
                        cell.accessoryType = UITableViewCell.AccessoryType.disclosureIndicator
                    }
                }
            }
        }

        return cell
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
