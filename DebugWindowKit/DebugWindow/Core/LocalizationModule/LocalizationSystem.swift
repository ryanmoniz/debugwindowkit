//
//  LocalizationSystem.swift
//  DebugWindow
//
//  Created by Ryan Moniz on 3/5/19.
//  Copyright © 2019 Ryan Moniz. All rights reserved.
//

import Foundation

public class LocalizationSystem:NSObject {
    
    var bundle: Bundle!
    
    class var sharedInstance: LocalizationSystem {
        struct Singleton {
            static let instance: LocalizationSystem = LocalizationSystem()
        }
        return Singleton.instance
    }
    
    override init() {
        super.init()
        bundle = Bundle.main
    }
    
    //MARK: - get language & localized image
    func localizedStringForKey(key:String, comment:String) -> String {
        return bundle.localizedString(forKey: key, value: comment, table: nil)
    }
    
    func localizedImagePathForImg(imagename:String, type:String) -> String {
        guard let imagePath = bundle.path(forResource: imagename, ofType: type) else {
            return ""
        }
        return imagePath
    }
    
    //MARK: - Set Language
    
    //sets the desired language, if language is not supported  by app it returns the default OS language.
    func setLanguage(languageCode:String) {
        #if DEBUG
        var appleLanguages = UserDefaults.standard.object(forKey: "AppleLanguages") as! [String]
        appleLanguages.remove(at: 0)
        appleLanguages.insert(languageCode, at: 0)
        UserDefaults.standard.set(appleLanguages, forKey: "AppleLanguages")
        UserDefaults.standard.synchronize()
        
        if let languageDirectoryPath = Bundle.main.path(forResource: languageCode, ofType: "lproj") {
            bundle = Bundle.init(path: languageDirectoryPath)
        } else {
            resetLocalization()
        }
        #endif
    }
    
    //resets to the default OS language
    func resetLocalization() {
        bundle = Bundle.main
    }
    
    //returns the current language of device/app
    func getLanguage() -> String {
        let appleLanguages = UserDefaults.standard.object(forKey: "AppleLanguages") as! [String]
        let preferredLanguage = appleLanguages[0]
        if preferredLanguage.contains("-") {
            let array = preferredLanguage.components(separatedBy: "-")
            return array[0]
        }
        return preferredLanguage
    }
}
