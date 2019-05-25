//
//  DebugTableViewController.swift
//  DebugWindowKit
//
//  Created by Ryan Moniz on 1/2/19.
//  Copyright © 2019 Ryan Moniz. All rights reserved.
//

import UIKit
import FileBrowser
import netfox_ios

fileprivate struct DWTableIndex {
    static let LiveLogsIndex = 0
    static let CoreDataIndex = 1
    static let LocalizationIndex = 2
    static let FileBrowser = 3
    static let NetFoxIndex = 4
}

fileprivate let DWDefaultsCount = 6

class DebugTableViewController: UITableViewController {
    var _menuItems = [DWGenericMenu]()
    
    @IBAction func doneAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //register cells first
        registerCellClasses(options: _menuItems)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return DWDefaultsCount + _menuItems.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == DWTableIndex.LiveLogsIndex {
            let cell = tableView.dequeueReusableCell(withIdentifier: "LiveLogsIdentifier", for: indexPath)
            return cell
        } else if indexPath.row == DWTableIndex.CoreDataIndex {
            let cell = tableView.dequeueReusableCell(withIdentifier: "CoreDataIdentifier", for: indexPath)
            return cell
        } else if indexPath.row == DWTableIndex.LocalizationIndex {
            let cell = tableView.dequeueReusableCell(withIdentifier: "LocalizationIdentifier", for: indexPath)
            return cell
        } else if indexPath.row == DWTableIndex.FileBrowser {
            let cell = tableView.dequeueReusableCell(withIdentifier: "FileBrowserIdentifier", for: indexPath)
            return cell
        } else if indexPath.row == DWTableIndex.NetFoxIndex {
            let cell = tableView.dequeueReusableCell(withIdentifier: "NetfoxCellIdentifier", for: indexPath)
            return cell
        }
            
//        else if indexPath.row == DWTableIndex.NetworkEye {
//            let cell = tableView.dequeueReusableCell(withIdentifier: "NetworkEyeIdentifier", for: indexPath)
//            return cell
//        }
        else {
            //handle custom menus
            if (indexPath.row - DWDefaultsCount >= 0) {
                let menu = self._menuItems[indexPath.row - DWDefaultsCount] //DWDefaultsCount is the default number of options that ship with DebugWindowKit
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
        if (indexPath.row >= DWDefaultsCount) {
            //custom menu
            let menu = self._menuItems[indexPath.row - DWDefaultsCount] //DWDefaultsCount is the default number of options that ship with DebugWindowKit
            guard let navController = self.navigationController else {
                NSLog("no navigation controller???")
                return
            }
            menu.didSelectRowAt(navigationController: navController)
        } else {
            if indexPath.row == DWTableIndex.NetFoxIndex {
                NFX.sharedInstance().show()
            }
            if indexPath.row == DWTableIndex.FileBrowser {
                if let str = NSSearchPathForDirectoriesInDomains(.applicationDirectory,
                                                              .userDomainMask,
                                                              true).first {
                    
                    let url = URL(string: (str as NSString).deletingLastPathComponent)
                    let browser = FileBrowser(initialPath: url)
                    self.present(browser, animated: true, completion: nil)
                }
                
            }
//            else if indexPath.row == DWTableIndex.NetworkEye {
//
//            }
        }
    }
}
