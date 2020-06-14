//
//  ObservableBool.swift
//  EDAS
//
//  Created by Bla bla on 13.06.2020.
//  Copyright © 2020 Bla bla. All rights reserved.
//

import Foundation
import Combine

class ObservableBool: ObservableObject {
    //var didChange = PassthroughSubject<Bool, Never>()
    @Published var value = false
    
    func set(value: Bool) {
        self.value = value
        //didChange.send(self.value)
    }
}
