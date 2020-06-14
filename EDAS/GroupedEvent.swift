//
//  GroupedEvent.swift
//  EDAS
//
//  Created by Bla bla on 06.06.2020.
//  Copyright © 2020 Bla bla. All rights reserved.
//

import Foundation

struct GroupedEvent: Identifiable {
    let id = UUID()
    var title: String
    var events: [Event]
    
    init(title: String) {
        self.title = title
        events = [Event]()
    }
}
