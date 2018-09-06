//
//  NSPredicateExtensions.swift
//  FlooidCoreData
//
//  Created by Martin Lalev on 7.09.18.
//  Copyright © 2018 Martin Lalev. All rights reserved.
//

import Foundation

extension NSPredicate {
    public static prefix func ! (pred: NSPredicate) -> NSPredicate {
        return NSCompoundPredicate.init(notPredicateWithSubpredicate: pred)
    }
    public static func && (lpred: NSPredicate, rpred: NSPredicate) -> NSPredicate {
        return NSCompoundPredicate.init(andPredicateWithSubpredicates: [lpred,rpred])
    }
    public static func || (lpred: NSPredicate, rpred: NSPredicate) -> NSPredicate {
        return NSCompoundPredicate.init(orPredicateWithSubpredicates: [lpred,rpred])
    }
}
