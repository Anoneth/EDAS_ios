//
//  EventListView+Extension.swift
//  EDAS
//
//  Created by Bla bla on 12.06.2020.
//  Copyright © 2020 Bla bla. All rights reserved.
//

import Foundation
import SwiftUI

extension EventListView {
    func toGropedList() -> [GroupedEvent] {
        var groups = [GroupedEvent]()
        for event in events {
            var index = 0
            var isAdded = false
            while index < groups.count && !isAdded {
                if groups[index].title == event.getDate() {
                    groups[index].events.append(event)
                    isAdded = true
                }
                index += 1
            }
            if !isAdded {
                groups.append(GroupedEvent(title: event.getDate()))
                groups[groups.count - 1].events.append(event)
            }
        }
        return groups
    }
    
    func getButtons() -> [Alert.Button] {
        var buttons = [Alert.Button]()
        if self.tokenHolder.checkToken() {
            buttons.append(Alert.Button.default(Text(NSLocalizedString("doLoad", comment: "")), action: {
                self.loadEvents()
            }))
            buttons.append(Alert.Button.default(Text(NSLocalizedString("doSave", comment: "")), action: {
                self.saveEvents()
            }))
            buttons.append(Alert.Button.destructive(Text(NSLocalizedString("logout", comment: "")), action: {
                self.tokenHolder.clearToken()
            }))
        } else {
            buttons.append(Alert.Button.default(Text(NSLocalizedString("doAuth", comment: "")), action: {
                self.isLoginView.value = true
            }))
        }
        buttons.append(Alert.Button.default(Text(NSLocalizedString("map", comment: "")), action: {
            self.isMapView.value = true
        }))
        buttons.append(Alert.Button.cancel())
        return buttons
    }
    
    func loadEvents() {
        let params = ["token": self.tokenHolder.token]
        let url = URL(string: "server/load")!
        let session = URLSession.shared
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: params, options: .prettyPrinted)
        } catch {
            self.alertTitle = NSLocalizedString("error", comment: "")
            self.alertMsg = NSLocalizedString("internalError", comment: "")
            self.showAlert = true
            return
        }
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        let task = session.dataTask(with: request, completionHandler: { (data, response, error) in
            guard error == nil else {
                self.alertTitle = NSLocalizedString("error", comment: "")
                self.alertMsg = NSLocalizedString("internalError", comment: "")
                self.showAlert = true
                return
            }
            guard let data = data else {
                self.alertTitle = NSLocalizedString("error", comment: "")
                self.alertMsg = NSLocalizedString("internalError", comment: "")
                self.showAlert = true
                return
            }
            do {
                let json = try JSONDecoder().decode(ResponseData.self, from: data)
                if json.code == 1 {
                    for event in self.events {
                        self.context.delete(event)
                    }
                    for i in 0...json.data.count - 1 {
                        self.addEvent(eventData: json.data[i], index: i)
                    }
                    do {
                        try self.context.save()
                    } catch {
                        self.alertTitle = NSLocalizedString("error", comment: "")
                        self.alertMsg = NSLocalizedString("internalError", comment: "")
                        self.showAlert = true
                    }
                }
            } catch {
                self.alertTitle = NSLocalizedString("error", comment: "")
                self.alertMsg = NSLocalizedString("serverError", comment: "")
                self.showAlert = true
                return
            }
        })
        task.resume()
    }
    
    func saveEvents() {
        var events = [EventData]()
        let encoder = JSONEncoder()
        for event in self.events {
            events.append(event.getData())
        }
        var jsonEvents = ""
        do {
            let dat = try encoder.encode(events)
            jsonEvents = String(data: dat, encoding: String.Encoding.utf8)!
        } catch {
            self.alertTitle = NSLocalizedString("error", comment: "")
            self.alertMsg = NSLocalizedString("internalError", comment: "")
            self.showAlert = true
            return
        }
        let params = ["token": self.tokenHolder.token, "events": jsonEvents]
        let url = URL(string: "server/save")!
        let session = URLSession.shared
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: params, options: .prettyPrinted)
        } catch {
            self.alertTitle = NSLocalizedString("error", comment: "")
            self.alertMsg = NSLocalizedString("internalError", comment: "")
            self.showAlert = true
            return
        }
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        let task = session.dataTask(with: request, completionHandler: { (data, response, error) in
            guard error == nil else {
                self.alertTitle = NSLocalizedString("error", comment: "")
                self.alertMsg = NSLocalizedString("internalError", comment: "")
                self.showAlert = true
                return
            }
            guard let data = data else {
                self.alertTitle = NSLocalizedString("error", comment: "")
                self.alertMsg = NSLocalizedString("internalError", comment: "")
                self.showAlert = true
                return
            }
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Int] {
                    print(json)
                    if json["code"] == 1 {
                        self.alertTitle = NSLocalizedString("result", comment: "")
                        self.alertMsg = NSLocalizedString("success", comment: "")
                        self.showAlert = true
                    }
                } else {
                    self.alertTitle = NSLocalizedString("error", comment: "")
                    self.alertMsg = NSLocalizedString("serverError", comment: "")
                    self.showAlert = true
                }
            } catch {
                self.alertTitle = NSLocalizedString("error", comment: "")
                self.alertMsg = NSLocalizedString("serverError", comment: "")
                self.showAlert = true
                return
            }
        })
        task.resume()
    }
    
    func addEvent(eventData: EventData, index: Int) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        let newEvent = Event(context: context)
        newEvent.id = Int64(index)
        newEvent.title = eventData.title
        newEvent.date = dateFormatter.date(from: eventData.date!)
        newEvent.desc = eventData.desc
    }
    
    func removeEvent(at offsets: IndexSet, from group: GroupedEvent) {
        for index in offsets {
            for event in self.events {
                if event.id == group.events[index].id {
                    context.delete(event)
                    LocalNotificationManager.removeNotification(id: event.id)
                }
            }
        }
        do {
            try context.save()
        } catch {
            print(error)
        }
    }
}
