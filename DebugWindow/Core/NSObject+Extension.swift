//
//  NSObject+Extension.swift
//  com_ibm_medtronic_sugariq_debugwindowkit
//
//  Created by Ryan Moniz on 4/17/19.
//  Copyright © 2019 Ryan Moniz. All rights reserved.
//

import Foundation

extension NSObject {
    
    //
    // Retrieves an array of property names found on the current object
    // using Objective-C runtime functions for introspection:
    // https://developer.apple.com/library/mac/documentation/Cocoa/Conceptual/ObjCRuntimeGuide/Articles/ocrtPropertyIntrospection.html
    //
    func propertyNames() -> Array<String> {
        var results: Array<String> = [];
        
        // retrieve the properties via the class_copyPropertyList function
        var count: UInt32 = 0;
        let myClass: AnyClass = self.classForCoder;
        let properties = class_copyPropertyList(myClass, &count);
        
        // iterate each objc_property_t struct
        var i: UInt32 = 0
        while i < count {
            if let property = properties?[Int(i)] {
                // retrieve the property name by calling property_getName function
                let cname = property_getName(property);
                
                // covert the c string into a Swift string
                let name = String(cString:cname);
                results.append(name);
            }
            
            i += 1
        }
        
        // release objc_property_t structs
        free(properties);
        
        return results;
    }
    
}
