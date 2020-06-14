//
//  ContentView.swift
//  EDAS
//
//  Created by Bla bla on 06.05.2020.
//  Copyright © 2020 Bla bla. All rights reserved.
//

import SwiftUI

struct EventListView: View {
    @FetchRequest(entity: Event.entity(),
                  sortDescriptors: [NSSortDescriptor(keyPath: \Event.date, ascending: true)]
    ) var events: FetchedResults<Event>
    
    @Environment(\.managedObjectContext) var context
    
    @State var title: String = ""
    @State var menuIsShowing = false
    
    @ObservedObject var tokenHolder = TokenHolder()
    @ObservedObject var isLoginView = ObservableBool()
    @ObservedObject var isMapView = ObservableBool()
    
    @State var login = ""
    @State var password = ""
    
    @State var alertTitle = ""
    @State var showAlert = false
    @State var alertMsg = ""
    
    var body: some View {
        NavigationView {
            List {
                NavigationLink(destination: EventEditView(), label: {
                    Text(NSLocalizedString("createNewEvent", comment: ""))
                })
                ForEach(toGropedList()) { group in
                    Section(header: Text(group.title)) {
                        ForEach(group.events, id: \.myHash) { event in
                            NavigationLink(destination: EventEditView(event: event), label: {
                                HStack {
                                    Text(event.getTime())
                                    Text(event.title ?? "")
                                }
                            })
                        }
                        .onDelete(perform: {offsets in
                            self.removeEvent(at: offsets, from: group)
                        })
                    }
                }
            }
            .navigationBarTitle(NSLocalizedString("appName", comment: ""))
            .navigationBarItems(trailing: Button(action: {
                print(self.menuIsShowing)
                self.menuIsShowing = true}, label: {Text(NSLocalizedString("menuTitle", comment: ""))}))
            .actionSheet(isPresented: self.$menuIsShowing, content: {ActionSheet(title: Text(NSLocalizedString("menu", comment: "")), message: Text(NSLocalizedString("menuDetails", comment: "")), buttons: self.getButtons())})
            .popover(isPresented: self.$isLoginView.value, content: { LoginView(tokenHolder: self.tokenHolder, isLoginView: self.isLoginView)})
            .alert(isPresented: self.$showAlert, content: {
                Alert(title: Text(self.alertTitle), message: Text(self.alertMsg), dismissButton: .default(Text("ok"), action: {
                    self.showAlert = false
                }))
                })
                .sheet(isPresented: self.$isMapView.value, content: {
                        MapView()
                })
        }
    }
}
