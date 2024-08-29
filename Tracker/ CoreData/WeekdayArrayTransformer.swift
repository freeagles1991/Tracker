//
//  WeekdayArrayTransformer.swift
//  Tracker
//
//  Created by Дима on 23.08.2024.
//

import Foundation
import CoreData

@objc(WeekdayArrayTransformer)
class WeekdayArrayTransformer: ValueTransformer {
    
    override func transformedValue(_ value: Any?) -> Any? {
        guard let weekdays = value as? [Weekday] else { return nil }
        let encoder = JSONEncoder()
        return try? encoder.encode(weekdays)
    }
    
    override func reverseTransformedValue(_ value: Any?) -> Any? {
        guard let data = value as? Data else { return nil }
        let decoder = JSONDecoder()
        return try? decoder.decode([Weekday].self, from: data)
    }
    
    override class func transformedValueClass() -> AnyClass {
        return NSData.self
    }
    
    override class func allowsReverseTransformation() -> Bool {
        return true
    }
    
    static func register() {
        ValueTransformer.setValueTransformer(
            WeekdayArrayTransformer(),
            forName: NSValueTransformerName(rawValue: String(describing: WeekdayArrayTransformer.self))
        )
    }
}

