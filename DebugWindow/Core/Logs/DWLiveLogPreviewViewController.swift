//
//  DWLiveLogPreviewViewController.swift
//  com_ibm_medtronic_sugariq_debugwindowkit
//
//  Created by Ryan Moniz on 4/24/19.
//  Copyright © 2019 Ryan Moniz. All rights reserved.
//

import UIKit

class DWLiveLogPreviewViewController: UIViewController {
    
    @IBOutlet weak var textView: UITextView!
    
    var filePath:URL?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let _filePath = filePath {
            do {
                let fileContents = try String(contentsOf: _filePath)
                textView.text = fileContents
            } catch {
                textView.text = "Error opening file."
                NSLog("error:\(error.localizedDescription)")
            }
            
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
