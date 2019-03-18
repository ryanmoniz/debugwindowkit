//
//  DWLocalizationTableViewController.swift
//  DebugWindow
//
//  Created by Ryan Moniz on 1/15/19.
//  Copyright © 2019 Ryan Moniz. All rights reserved.
//

import UIKit

private enum LocalizationSectionType {
    case DebugLanguages
    case HumanLanguages
}

private struct LocalizationSection {
    var type: LocalizationSectionType
    var items: [String]
}

fileprivate let DebugLangugagesTitle = "Debug Languages"
fileprivate let HumanLanguagesTitle = "Human Languages"

fileprivate let PseudolocalizedIdentifier: String = "PseudolocalizedIdentifier"
fileprivate let PseudolocalizedRTLIdentifier: String = "PseudolocalizedRTLIdentifier"
fileprivate let DWHumanLanguageIdentifier: String = "DWHumanLanguageIdentifier"

fileprivate let PseudolocalizedIdentifierState = "PseudolocalizedIdentifierState"
fileprivate let PseudolocalizedRTLIdentifierState = "PseudolocalizedRTLIdentifierState"

fileprivate let CurrentHumanLangageState = "CurrentHumanLangageState"

class DWLocalizationTableViewController: UITableViewController {
    private var sections = [LocalizationSection(type: LocalizationSectionType.DebugLanguages, items: [PseudolocalizedIdentifier, PseudolocalizedRTLIdentifier]), LocalizationSection(type: LocalizationSectionType.HumanLanguages, items: NSLocale.isoLanguageCodes)]
    
    // init an english NSLocale to get the english name of all NSLocale-Objects
    private let englishLocale : NSLocale = NSLocale.init(localeIdentifier :  "en_US")


    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionItems = sections[section].items
        return sectionItems.count
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let section = sections[section]
        
        if section.type == LocalizationSectionType.DebugLanguages {
            return DebugLangugagesTitle
        } else if section.type == LocalizationSectionType.HumanLanguages {
            return HumanLanguagesTitle
        }
        
        return ""
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = sections[indexPath.section]
        let sectionItems = section.items
        
        if section.type == LocalizationSectionType.DebugLanguages {
            if sectionItems[indexPath.row] == PseudolocalizedIdentifier {
                let cell = tableView.dequeueReusableCell(withIdentifier: PseudolocalizedIdentifier, for: indexPath)
                //check user defaults to see what was saved
                if let value = UserDefaults.standard.value(forKey: PseudolocalizedIdentifierState) as? Bool {
                    if value {
                        cell.accessoryType = UITableViewCell.AccessoryType.checkmark
                    } else {
                        cell.accessoryType = UITableViewCell.AccessoryType.none
                    }
                } else {
                    cell.accessoryType = UITableViewCell.AccessoryType.none
                }
                return cell
            } else if sectionItems[indexPath.row] == PseudolocalizedRTLIdentifier {
                let cell = tableView.dequeueReusableCell(withIdentifier: PseudolocalizedRTLIdentifier, for: indexPath)
                
                if let value = UserDefaults.standard.value(forKey: PseudolocalizedRTLIdentifierState) as? Bool {
                    if value {
                        cell.accessoryType = UITableViewCell.AccessoryType.checkmark
                    } else {
                        cell.accessoryType = UITableViewCell.AccessoryType.none
                    }
                } else {
                    cell.accessoryType = UITableViewCell.AccessoryType.none
                }
                return cell
            }
        } else if section.type == LocalizationSectionType.HumanLanguages {
            let item = sectionItems[indexPath.row]
            let cell = tableView.dequeueReusableCell(withIdentifier: DWHumanLanguageIdentifier, for: indexPath)
            cell.textLabel?.text = item

            if let value = UserDefaults.standard.value(forKey: CurrentHumanLangageState) as? String {
                if value == item {
                    cell.accessoryType = UITableViewCell.AccessoryType.checkmark
                } else {
                    cell.accessoryType = UITableViewCell.AccessoryType.none
                }
            } else {
                cell.accessoryType = UITableViewCell.AccessoryType.none
            }
            
            if let langInEnglish = englishLocale.displayName(forKey: NSLocale.Key.identifier, value: item) {
                cell.detailTextLabel?.text = langInEnglish
            } else {
                cell.detailTextLabel?.text = ""
            }
            cell.selectionStyle = .default
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: PseudolocalizedIdentifier, for: indexPath)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let section = sections[indexPath.section]
        let sectionItems = section.items
        
        if section.type == LocalizationSectionType.DebugLanguages {
            if sectionItems[indexPath.row] == PseudolocalizedIdentifier {
                
                if let value = UserDefaults.standard.value(forKey: PseudolocalizedIdentifierState) as? Bool {
                    if value {
                        //toggle off
                        UserDefaults.standard.setValue(false, forKey: PseudolocalizedIdentifierState)
                        UserDefaults.standard.setValue(false, forKey: PseudolocalizedRTLIdentifierState)
                        UserDefaults.standard.synchronize()
                    } else {
                        //toggle on
                        UserDefaults.standard.setValue(true, forKey: PseudolocalizedIdentifierState)
                        UserDefaults.standard.setValue(false, forKey: PseudolocalizedRTLIdentifierState)
                        UserDefaults.standard.synchronize()
                    }
                } else {
                    UserDefaults.standard.setValue(true, forKey: PseudolocalizedIdentifierState)
                    UserDefaults.standard.setValue(false, forKey: PseudolocalizedRTLIdentifierState)
                    UserDefaults.standard.synchronize()
                }
            } else if sectionItems[indexPath.row] == PseudolocalizedRTLIdentifier {
                if let value = UserDefaults.standard.value(forKey: PseudolocalizedRTLIdentifierState) as? Bool {
                    if value {
                        //toggle off
                        UserDefaults.standard.setValue(false, forKey: PseudolocalizedIdentifierState)
                        UserDefaults.standard.setValue(false, forKey: PseudolocalizedRTLIdentifierState)
                        UserDefaults.standard.synchronize()
                    } else {
                        //toggle on
                        UserDefaults.standard.setValue(false, forKey: PseudolocalizedIdentifierState)
                        UserDefaults.standard.setValue(true, forKey: PseudolocalizedRTLIdentifierState)
                        UserDefaults.standard.synchronize()
                    }
                } else {
                    UserDefaults.standard.setValue(false, forKey: PseudolocalizedIdentifierState)
                    UserDefaults.standard.setValue(true, forKey: PseudolocalizedRTLIdentifierState)
                    UserDefaults.standard.synchronize()
                }                
            }
            self.tableView.reloadData()
        } else if section.type == LocalizationSectionType.HumanLanguages {
            UserDefaults.standard.setValue(sectionItems[indexPath.row], forKey: CurrentHumanLangageState)
            UserDefaults.standard.synchronize()
            self.tableView.reloadData()
        }
    }
}
