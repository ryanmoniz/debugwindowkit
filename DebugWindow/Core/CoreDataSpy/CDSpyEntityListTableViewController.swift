//
//  CDSpyEntityListTableViewController.swift
//  DebugWindowKit
//
//  Created by Ryan Moniz on 3/15/19.
//  Copyright © 2019 Ryan Moniz. All rights reserved.
//

import UIKit
import CoreData
import CSV

class CDSpyEntityListTableViewController: UITableViewController {

    var managedObjectModel: NSManagedObjectModel?
    var context: NSManagedObjectContext?
    var entityName:String = "<Entity Name>"
    
    var jsonRecords: [[String: Any]] = []
    var records = [NSManagedObject]()
    var attributes = [String]()
    var attributeTypes = [String:String]()
    var relationships = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.rowHeight = UITableView.automaticDimension
        
        let exportButton = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveCurrentEntity))
        self.navigationItem.rightBarButtonItem = exportButton
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.jsonRecords.removeAll()
        self.records.removeAll()
        self.attributes.removeAll()
        self.attributeTypes.removeAll()
        self.relationships.removeAll()
        
        self.title = entityName
        
        DispatchQueue.global(qos: .background).async {
            self.getAttributes()
            self.getRelationships()
            self.fetchAllForEntity()
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        UIView.performWithoutAnimation {
            tableView.beginUpdates()
            tableView.endUpdates()
        }
        
        self.title = "\(entityName) (\(self.records.count))"
    }
    
    
    
    //MARK: Functions
    
    @objc func saveCurrentEntity() {
        //save current entity data to csv file in documents directory, display alert/banner telling user where to find it
        let saveMsg = "You can find an exported copy of the currently selected entity in the app's Documents directory."
        let saveAlert = UIAlertController(title: "Saving Entity", message: saveMsg, preferredStyle: .alert)
        
        saveAlert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { (action) in
            
        }))
        self.navigationController?.present(saveAlert, animated: true, completion: nil)
        
        //csv
        var filePath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        filePath.append("/\(self.entityName).csv")
        let stream = OutputStream(toFileAtPath: filePath, append: false)!
        do {
            let csv = try CSVWriter(stream: stream)
            //write header row first
            let attributesRelationshipHeaders = self.attributes + self.relationships + ["objectID"]
        
            try csv.write(row: attributesRelationshipHeaders.sorted())
            NSLog("csv headers:\(attributesRelationshipHeaders.sorted())")
            
            //iterate through entity objects
            
            for obj in self.jsonRecords {
                //NSLog("obj:\(obj.description)")
                csv.beginNewRow()
                for key in attributesRelationshipHeaders.sorted() {
                    NSLog("key:\(key)")
                    if let _value = obj[key] {
                        try csv.write(field: "\(_value)")
                    } else {
                        try csv.write(field: "nil")
                    }
                }
            }
            
            csv.stream.close()
        } catch {
            NSLog("error writing csv file.\(error.localizedDescription)")
        }
        
        
    }

    func fetchAllForEntity() {
        guard let moc = self.context else {
            NSLog("error no context, , assign to DebugWindow.sharedInstance.context")
            return
        }
        
        guard let nameSpace = DebugWindow.sharedInstance.moduleName else {
            NSLog("Error: missing module name, assign to DebugWindow.sharedInstance.moduleName")
            return
        }
        
        let aClass = NSClassFromString(nameSpace + "." + entityName) as! NSManagedObject.Type
      
        moc.perform {
//            let request: NSFetchRequest<NSFetchRequestResult> = aClass.fetchRequest()
//            let objects = try! moc.fetch(request)

            let objects = try! moc.fetchObjects(aClass.self)
            
            self.records = objects
            //convert the nsmanagedobjects into normal objects
            
            for obj in objects {
                var dict: [String: Any] = [:]
                for key in self.attributes {
                    if let value: Any = obj.value(forKey: key) {
                        print("\(key) = \(value)")
                        dict[key] = "\(value)"
                    }
                }
                for key in self.relationships {
                    print("key:\(key)")
                    if let value: Any = obj.value(forKey: key) {
                        print("\(key) = \(value)")
                        dict[key] = "\(value)"
                    }
                }
                dict["objectID"] = "\(obj.objectID.uriRepresentation())"
                self.jsonRecords.append(dict)
            }
            
            NSLog("jsonRecords:\(self.jsonRecords)")
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    func getRelationships() {
        guard let managedObjectModel = self.managedObjectModel else {
            NSLog("error: no mom object")
            return
        }
        
        let entity = managedObjectModel.entities.filter {
            $0.name == entityName
        }
        
        NSLog("Entity: \(String(describing: entity.first!.name!))")
        
        let relationships = entity.first?.relationshipsByName.enumerated().map( {
            //return $0.element.value.destinationEntity?.name
            return $0.element.key
        })
        
        if let _relationships = relationships {
            NSLog("_relationships:\(String(describing: _relationships))")
            self.relationships = _relationships
        }
        
        let temp = entity.first?.relationshipsByName
        if let _temp = temp {
            for attr in _temp {
             NSLog("attr:\(attr)")
            }
        }
        //maxCount = 1 then Relationship is one to one
        //maxCount = 0 then Relationship is TooMany
        
        
        NSLog("relationships:\(String(describing: relationships))")
    }
    
    func getAttributes() {
        guard let managedObjectModel = self.managedObjectModel else {
            NSLog("error: no mom object")
            return
        }
        
        let entity = managedObjectModel.entities.filter {
            $0.name == entityName
        }
        
        NSLog("Entity: \(String(describing: entity.first!.name!))")
        
        let attributes = entity.first?.attributesByName.enumerated().map( {
            return $0.element.key
            //$0.element.value
        })
        
        if let _attributes = attributes {
            NSLog("attributes:\(String(describing: _attributes))")
            self.attributes = _attributes
        }
        
        let attributeTypes = entity.first?.attributesByName
        if let _attributeTypes = attributeTypes {
            for attr in _attributeTypes {
                if let attributeType = attr.value.attributeValueClassName {
                    self.attributeTypes[attr.key] = attributeType
                } else {
                    self.attributeTypes[attr.key] = "Unknown?"
                }
                NSLog("attr.key:\(attr.key) - attr.value:\(attr.value) - attr.attributeType:\(String(describing: attr.value.attributeValueClassName))")
            }
        }
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return records.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return UITableView.automaticDimension
        } else {
            return 62
        }
    }

    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 300
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EntityAttributesIdentifier", for: indexPath)
        let obj = jsonRecords[indexPath.row]
        
        if indexPath.row % 2 == 0 {
            cell.backgroundColor = UIColor.lightGray
        } else {
            cell.backgroundColor = UIColor.white
        }
        
        //use attributes to print object as obj.description crashes
        var detailsString = "ATTRIBUTES\n"
        
        if let moc = self.context {
            moc.perform {
                //for key in obj.entity.propertiesByName.keys{
                for key in self.attributes {
                    if let value: Any = obj[key] {
                        print("\(key) = \(value)")
                        detailsString.append("\(key):\(value)\n")
                    } else {
                        detailsString.append("\(key):nil\n")
                    }
                }

                detailsString.append("RELATIONSHIPS\n")
                for key in self.relationships {
                    if let value: Any = obj[key] {
                        print("\(key) = \(value)")
                        detailsString.append("\(key):\(value)\n")
                    } else {
                        detailsString.append("\(key):nil\n")
                    }
                }

                DispatchQueue.main.async {
                    if let _objectID = obj["objectID"] {
                        cell.textLabel?.text = "ObjectID:\(_objectID)"
                    }

                    cell.detailTextLabel?.text = detailsString
                    cell.accessoryType = UITableViewCell.AccessoryType.disclosureIndicator

                    cell.layoutIfNeeded()
                    cell.layoutSubviews()
                }
            }
        }
        return cell
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? CDSpyEntityDetailsTableViewController {
            vc.managedObjectModel = managedObjectModel
            vc.context = context
            vc.attributes = attributes
            vc.relationships = relationships
            vc.attributeTypes = attributeTypes
            
            if let selectedIndex = tableView.indexPathForSelectedRow?.row {
                let obj = records[selectedIndex]
                if let moc = self.context {
                    moc.perform {
                        let id = obj.objectID.uriRepresentation().lastPathComponent
                        vc.entityName = "\(self.entityName)/\(id)"
                        vc.record = obj
                    }
                }
            }
        }
    }

}
