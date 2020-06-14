//
//  EventEditView.swift
//  EDAS
//
//  Created by Bla bla on 06.06.2020.
//  Copyright © 2020 Bla bla. All rights reserved.
//

import SwiftUI
import CoreData

struct EventEditView: View {
    var event: Event? = nil
    
    @Environment(\.managedObjectContext) var context
    @Environment(\.presentationMode) var presentationMode
    
    @FetchRequest(entity: Event.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \Event.date, ascending: true)]
    ) var events: FetchedResults<Event>
    
    @State var title: String
    @State var date: Date
    @State var desc: String
    @State var needNotify: Bool
    @State var notifyDate: Date
    
    init() {
        self.event = nil
        _title = State(wrappedValue: "")
        _date = State(wrappedValue: Date())
        _desc = State(wrappedValue: "")
        _needNotify = State(wrappedValue: false)
        _notifyDate = State(wrappedValue: Date())
    }
    
    init(event: Event) {
        self.event = event
        _title = State(wrappedValue: event.title ?? "")
        _date = State(wrappedValue: event.date ?? Date())
        _desc = State(wrappedValue: event.desc ?? "")
        _needNotify = State(wrappedValue: event.notifyDate != nil)
        _notifyDate = State(wrappedValue: event.notifyDate ?? Date())
    }
    var body: some View {
        List {
            Section {
                TextField(NSLocalizedString("name", comment: ""), text: $title)
                DatePicker(NSLocalizedString("date", comment: ""), selection: $date, displayedComponents: .date)
                DatePicker(NSLocalizedString("time", comment: ""), selection: $date, displayedComponents: .hourAndMinute)
            }
            Section(header: Text(NSLocalizedString("optional", comment: ""))) {
                TextField(NSLocalizedString("desc", comment: ""), text: $desc)
                Toggle(isOn: $needNotify, label: {
                    Text(NSLocalizedString("notifyAtDay", comment: ""))
                })
                if self.needNotify {
                    DatePicker(NSLocalizedString("dateTime", comment: ""), selection: $notifyDate)
                }
            }
        }
        .navigationBarTitle(Text(event != nil ? NSLocalizedString("edit", comment: "") : NSLocalizedString("new", comment: "")), displayMode: .inline)
        .navigationBarItems(trailing: Button(action: {
            self.saveEvent()
            self.presentationMode.wrappedValue.dismiss()
        }, label: { Text(NSLocalizedString("done", comment: ""))}))
        .listStyle(GroupedListStyle())
    }
    
    func saveEvent() {
        if self.event == nil {
            let newEvent = Event(context: context)
            newEvent.id = Int64(events.count)
            newEvent.title = self.title
            newEvent.date = self.date
            newEvent.desc = self.desc
            newEvent.notifyDate = self.notifyDate
            do {
                try context.save()
                if self.needNotify {
                    LocalNotificationManager.addNotification(id: newEvent.id, title: self.title, date: self.notifyDate)
                }
            } catch {
                print(error)
            }
        } else {
            let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "Event")
            let eventId = self.event!.id as NSNumber
            fetchRequest.predicate = NSPredicate(format: "id == %@", eventId as CVarArg)
            fetchRequest.fetchLimit = 1
            do {
                let test = try context.fetch(fetchRequest)
                let updatedEvent = test[0] as! NSManagedObject
                updatedEvent.setValue(self.title, forKey: "title")
                updatedEvent.setValue(self.date, forKey: "date")
                updatedEvent.setValue(self.desc, forKey: "desc")
                updatedEvent.setValue(self.needNotify ? self.notifyDate : nil, forKey: "notifyDate")
                try context.save()
                if self.needNotify {
                    LocalNotificationManager.addNotification(id: self.event!.id, title: self.title, date: self.notifyDate)
                } else {
                    LocalNotificationManager.removeNotification(id: event!.id)
                }
            } catch {
                print("__________________________")
                print(error)
            }
        }
    }
}
