//
//  DWGenericMenu.swift
//  DebugWindow
//
//  Created by Ryan Moniz on 1/30/19.
//  Copyright © 2019 Ryan Moniz. All rights reserved.
//

import UIKit

public protocol DWGenericMenu {
    
    /// Reuse identifier for the cell.
    var reuseIdentifier: String { get }
    
    /// Nib file for the uitableviewcell, nullable
    var nib: UINib? { get }
    
    /// Function to dequeue the cell for the given table view
    /// - Note: Cell class is registrated automatically when tableview initialized
    ///
    /// - Parameters:
    ///   - tableView: debug table view, note that this property is used mainly for calling `dequeueReusableCell`.
    ///   Modification on the tableview is disencouraged
    /// - Returns: An UITableViewCell instance
    func cellFor(tableView: UITableView) -> UITableViewCell
    
    /// function to handle when row is selected
    /// implementation is responsible for providing view controller or action
    func didSelectRowAt(navigationController:UINavigationController)
}

public extension DWGenericMenu {
    
    /// Default reuseIdentifier implementation, it will use the protocol adopator's name
    static var reuseIdentifier: String {
        return String(describing: Self.self)
    }
    
    /// Default nib implementation, nil
    static var nib: UINib? {
        return nil
    }
}
