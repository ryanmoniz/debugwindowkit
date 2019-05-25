//
//  CDSpyTableViewController.swift
//  DebugWindowKit
//
//  Created by Ryan Moniz on 3/15/19.
//  Copyright © 2019 Ryan Moniz. All rights reserved.
//

import UIKit
import CoreData

struct EntityModel {
    let name: String
    let count: Int
}

class CDSpyTableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView:UITableView!
    @IBOutlet var searchFooter: SearchFooter!
    
    var filteredEntities = [EntityModel]()
    let searchController = UISearchController(searchResultsController: nil)
    
    var managedObjectModel: NSManagedObjectModel?
    var context: NSManagedObjectContext?
    
    var entities = [String]()
    var _entities = [EntityModel]()
    
    let mediaBundle = Bundle(for: CDSpyTableViewController.self)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //load from DebugWindow
        
        managedObjectModel = DebugWindow.sharedInstance.managedObjectModel
        context = DebugWindow.sharedInstance.context

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        //setup search bar
        // Setup the Search Controller
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Entities"
        navigationItem.searchController = searchController
        definesPresentationContext = true
        
        // Setup the Scope Bar
        //searchController.searchBar.scopeButtonTitles = ["All", "Chocolate", "Hard", "Other"]
        searchController.searchBar.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.title = "Entities"
        entities.removeAll()
        _entities.removeAll()
        entities = self.getAllEntities()
        
        getCountFor(entities: entities) { (success) in
            if success {
               NSLog("self._entities:\(self._entities.description)")
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    func getAllEntities() -> [String] {
        var allEntities = [String]()
        if let moc = self.managedObjectModel {
            let entities = moc.entities.map({
                (entity) -> String in
                return entity.name!
            })
            allEntities = entities
            NSLog("entities:\(entities)")
        } else {
            NSLog("CoreDataSpy - need to init with managed object model and managed object context")
        }
        return allEntities
    }
    
    func getCountFor(entities:[String], callback: @escaping (Bool) -> ()) {
        guard let moc = self.context else {
            NSLog("error no context")
            callback(false)
            return
        }
        
        moc.perform {
            for entity in entities {
                let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
                fetchRequest.includesPropertyValues = false
                fetchRequest.includesSubentities = false
                do {
                    let count = try moc.count(for: fetchRequest)
                    let entityModel = EntityModel(name: entity, count: count)
                    self._entities += [entityModel]
                } catch {
                    NSLog("\(error.localizedDescription)")
                }
            }
            
            callback(true)
        }
    }
    
    // MARK: - Private instance methods
    
    func filterContentForSearchText(_ searchText: String, scope: String = "All") {
        filteredEntities = _entities.filter({
            $0.name.lowercased() == searchText.lowercased()
        })
        
        tableView.reloadData()
    }
    
    func searchBarIsEmpty() -> Bool {
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    func isFiltering() -> Bool {
        let searchBarScopeIsFiltering = searchController.searchBar.selectedScopeButtonIndex != 0
        return searchController.isActive && (!searchBarIsEmpty() || searchBarScopeIsFiltering)
    }

    // MARK: - Table view data source

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering() {
            searchFooter.setIsFilteringToShow(filteredItemCount: filteredEntities.count, of: _entities.count)
            return filteredEntities.count
        }
        
        searchFooter.setNotFiltering()
        return _entities.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EntitiesIdentifier", for: indexPath)

        let entity: EntityModel
        if isFiltering() {
            entity = filteredEntities[indexPath.row]
        } else {
            entity = _entities[indexPath.row]
        }
        
        cell.textLabel?.text = entity.name
        cell.detailTextLabel?.text = "\(entity.count)"
        
        cell.imageView?.image = UIImage(named: "entity", in: mediaBundle, compatibleWith: nil)

        return cell
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
     //name of entity + (count)
    }
    */
    
    //did select indexPath
    //show list of objects created by that entity. e.g. Samples

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


    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? CDSpyEntityListTableViewController {
            vc.context = self.context
            vc.managedObjectModel = self.managedObjectModel
            if let selectedIndex = tableView.indexPathForSelectedRow?.row {
                let entityName = _entities[selectedIndex].name
                vc.entityName = entityName
            }
        }
    }
}

extension CDSpyTableViewController: UISearchBarDelegate {
    // MARK: - UISearchBar Delegate
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        filterContentForSearchText(searchBar.text!, scope: "All")
    }
}

extension CDSpyTableViewController: UISearchResultsUpdating {
    // MARK: - UISearchResultsUpdating Delegate
    func updateSearchResults(for searchController: UISearchController) {
        //let searchBar = searchController.searchBar
        //let scope = searchBar.scopeButtonTitles![searchBar.selectedScopeButtonIndex]
        filterContentForSearchText(searchController.searchBar.text!, scope: "All")
    }
}
