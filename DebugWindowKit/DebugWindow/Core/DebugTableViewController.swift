//
//  DebugTableViewController.swift
//  DebugWindow
//
//  Created by Ryan Moniz on 1/2/19.
//  Copyright © 2019 Ryan Moniz. All rights reserved.
//

import UIKit

class DebugTableViewController: UITableViewController {
    var _menuItems = [DWGenericMenu]()
    
    @IBAction func doneAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        //register cells first
        registerCellClasses(options: _menuItems)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3 + _menuItems.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "LiveLogsIdentifier", for: indexPath)
            return cell
        } else if indexPath.row == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "CoreDataIdentifier", for: indexPath)
            return cell
        } else if indexPath.row == 2 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "LocalizationIdentifier", for: indexPath)
            return cell
        } else {
            //handle custom menus
            if (indexPath.row - 3 >= 0) {
                let menu = self._menuItems[indexPath.row - 3] //3 is the default number of options that ship with DebugWindow
                return menu.cellFor(tableView: tableView)
            } else {
                NSLog("something funny going on....")
            }
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "EmptyIdentifier", for: indexPath)
        return cell
    }
    
    private func registerCellClasses(options: [DWGenericMenu]) {
        var registeredCells = Set<String>()
        
        // Register for each reuse Identifer for once
        options.forEach { option in

            let reuseIdentifier = option.reuseIdentifier
            if let registeredNib = option.nib {
                registeredCells.insert(reuseIdentifier)
                tableView.register(registeredNib, forCellReuseIdentifier: reuseIdentifier)
            } else {
                NSLog("check your implementation of the protocol DWGenericMenu, the nib didn't load")
            }
        }
    }
    
    //MARK: UITableView Delegate methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if (indexPath.row >= 3) {
            //custom menu
            let menu = self._menuItems[indexPath.row - 3] //3 is the default number of options that ship with DebugWindow
            guard let navController = self.navigationController else {
                NSLog("no navigation controller???")
                return
            }
            menu.didSelectRowAt(navigationController: navController)
        }
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
