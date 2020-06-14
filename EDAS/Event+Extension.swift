//
//  Event+Extension.swift
//  EDAS
//
//  Created by Bla bla on 11.06.2020.
//  Copyright © 2020 Bla bla. All rights reserved.
//

import Foundation
import SwiftUI

extension Event: Identifiable {
    func getDate() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        if date == nil {
            return "Error"
        }
        let now = Date()
        if date! < now {
            return NSLocalizedString("past", comment: "")
        } else {
            if date!.fullDistance(from: now, resultIn: .year)! > 0 {
                dateFormatter.dateFormat = "d MMM yyyy"
                return dateFormatter.string(from: date!)
            }
            else {
                if date!.fullDistance(from: now, resultIn: .month)! > 0 {
                    dateFormatter.dateFormat = "d MMM"
                    return dateFormatter.string(from: date!)
                }
                else {
                    switch date!.fullDistance(from: now, resultIn: .day)! {
                    case 0:
                        let calendar = Calendar.current
                        let a1 = calendar.component(.day, from: date!)
                        let a2 = calendar.component(.day, from: now)
                        if a1 != a2 {
                            return NSLocalizedString("tomorrow", comment: "")
                        }
                        return NSLocalizedString("today", comment: "")
                    case 1:
                        return NSLocalizedString("tomorrow", comment: "")
                    default:
                        dateFormatter.dateFormat = "d MMM"
                        return dateFormatter.string(from: date!)
                    }
                }
            }
        }
    }
    
    func getTime() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        if self.date == nil {
            return "Error"
        }
        dateFormatter.dateFormat = "H:mm"
        return dateFormatter.string(from: date!)
    }
    
    var myHash: Int {
        id.hashValue ^ (title != nil ? title!.hashValue : -1) ^ (date != nil ? date!.hashValue : -1) ^ (desc != nil ? desc!.hashValue : -1) ^ (notifyDate != nil ? notifyDate!.hashValue : -1)
    }
    
    func getData() -> EventData {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        return EventData(id: self.id, title: self.title, date: dateFormatter.string(from: self.date!), desc: self.desc)
    }
}

struct EventData: Codable {
    var id: Int64
    var title: String?
    var date: String?
    var desc: String?
}

struct ResponseData: Codable {
    var code: Int
    var data: [EventData]
}

