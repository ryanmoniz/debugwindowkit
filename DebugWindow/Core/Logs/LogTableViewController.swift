//
//  LogTableViewController.swift
//  ConnectPlus
//
//  Created by Ryan Moniz on 3/13/19.
//  Copyright © 2019 IBM. All rights reserved.
//

import UIKit

class LogTableViewController: UITableViewController {

    var logs = [URL]()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        getLogs()
    }
    
    func getLogs() {
        let documentsPath = NSURL(fileURLWithPath: NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0])
        if let logsURL = documentsPath.appendingPathComponent("Logs") {
            do {
                let logsArray = try FileManager.default.contentsOfDirectory(at: logsURL, includingPropertiesForKeys: nil, options: [])
            
                NSLog("logsURL:\(String(describing: logsURL))")
            
                //check for app/Documents/Logs for files
                NSLog("logsArray:\(logsArray)")
                self.logs = logsArray
//                for file in logsArray {
//                    self.logs.append(file)
//                }
            } catch {
                NSLog("LogTableViewController - error geting log path :\(error.localizedDescription)")
            }
            
            //check for .log files in app/Documents
            do {
                let logsArray = try FileManager.default.contentsOfDirectory(at: documentsPath as URL, includingPropertiesForKeys: nil, options: [])
                let logFiles = logsArray.filter{$0.pathExtension == "log"}
                NSLog("logsArray:\(logsArray)")
                
                self.logs = logFiles
//                for file in logFiles {
//                        //found logs
//                    self.logs.append(file)
//                }
            } catch {
                NSLog("LogTableViewController - error geting log path :\(error.localizedDescription)")
            }
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return logs.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DWLiveLogsEmptyIdentifier", for: indexPath)

        let logsPath = logs[indexPath.row].lastPathComponent
        
        cell.textLabel?.text = logsPath
        cell.accessoryType = UITableViewCell.AccessoryType.disclosureIndicator

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        //show the log contents
        let debugWindowBundle = Bundle(for: LogTableViewController.self)
        let sb = UIStoryboard(name: "DWLiveLogPreview", bundle: debugWindowBundle)
        if let vc = sb.instantiateInitialViewController() as? DWLiveLogPreviewViewController {
            vc.filePath = self.logs[indexPath.row]
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}
