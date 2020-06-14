//
//  Notification.swift
//  EDAS
//
//  Created by Bla bla on 13.06.2020.
//  Copyright © 2020 Bla bla. All rights reserved.
//

import UserNotifications

class LocalNotificationManager {
    
    static func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .alert]) { granted, error in
        }
    }
    
    static func addNotification(id: Int64, title: String, date: Date) {
        LocalNotificationManager.requestPermission()
        let content = UNMutableNotificationContent()
        content.title = title
        let uuidString = UUID().uuidString
        let trigger = UNCalendarNotificationTrigger(dateMatching: Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: date), repeats: false)
        let request = UNNotificationRequest(identifier: uuidString, content: content, trigger: trigger)
        LocalNotificationManager.setNotification(id: id, title: title, date: date, uuid: uuidString)
        UNUserNotificationCenter.current().add(request) { error in
            guard error == nil else { return }
        }
    }
    
    private static func setNotification(id: Int64, title: String, date: Date, uuid: String) {
        var dict: [String:String]
        if let test = UserDefaults.standard.value(forKey: "dict") as? [String:String] {
            dict = test
        }
        else {
            dict = [String:String]()
        }
        if dict[String(id)] != nil {
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [dict[String(id)]!])
        }
        dict[String(id)] = uuid
        UserDefaults.standard.set(dict, forKey: "dict")
    }
    
    static func removeNotification(id: Int64) {
        var dict: [String:String]
        if let test = UserDefaults.standard.value(forKey: "dict") as? [String:String] {
            dict = test
        }
        else {
            dict = [String:String]()
        }
        if dict[String(id)] != nil {
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [dict[String(id)]!])
            dict.removeValue(forKey: String(id))
            UserDefaults.standard.set(dict, forKey: "dict")
        }
    }
}
