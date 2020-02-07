//
//  Bill.swift
//  BillCollector
//
//  Created by Christopher Garcia on 5/5/16.
//  Copyright © 2016 Christopher Garcia. All rights reserved.
//

import Foundation

class Bill: NSObject, NSCoding {
    // MARK: Properties
    var billName: String
    var amountDue: NSDecimalNumber
    var dueDate: Date
    var isEstimate: Bool
    
    // MARK: Archiving Paths
    static let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.appendingPathComponent("bills")
    
    // MARK: Types
    struct PropertyKey {
        static let billNameKey = "billName"
        static let amountDueKey = "amountDue"
        static let dueDateKey = "dueDate"
        static let isEstimateKey = "isEstimate"
    }
    
    init?(billName: String, amountDue: NSDecimalNumber, dueDate: Date, isEstimate: Bool) {
        self.billName = billName
        self.amountDue = amountDue
        self.dueDate = dueDate
        self.isEstimate = isEstimate
        
        super.init()
        
        if billName.isEmpty {
            return nil
        }
    }
    
    // MARK: NSCoding
    func encode(with aCoder: NSCoder) {
        aCoder.encode(billName, forKey: PropertyKey.billNameKey)
        aCoder.encode(amountDue, forKey: PropertyKey.amountDueKey)
        aCoder.encode(dueDate, forKey: PropertyKey.dueDateKey)
        aCoder.encode(isEstimate, forKey: PropertyKey.isEstimateKey)
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        let billName = aDecoder.decodeObject(forKey: PropertyKey.billNameKey) as! String
        let amountDue = aDecoder.decodeObject(forKey: PropertyKey.amountDueKey) as! NSDecimalNumber
        let dueDate = aDecoder.decodeObject(forKey: PropertyKey.dueDateKey) as! Date
        let isEstimate = aDecoder.decodeObject(forKey: PropertyKey.isEstimateKey) as? Bool ?? aDecoder.decodeBool(forKey: PropertyKey.isEstimateKey)
        
        
        self.init(billName: billName, amountDue: amountDue, dueDate: dueDate, isEstimate: isEstimate)
    }
}
