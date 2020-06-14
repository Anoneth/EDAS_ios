//
//  Token.swift
//  EDAS
//
//  Created by Bla bla on 12.06.2020.
//  Copyright © 2020 Bla bla. All rights reserved.
//

import Foundation
import Combine

class TokenHolder: ObservableObject {
    var didChange = PassthroughSubject<String, Never>()
    var token = ""
    
    func checkToken() -> Bool {
        let defaults = UserDefaults.standard
        token = defaults.string(forKey: "token") ?? ""
        return token != ""
    }
    
    func setToken(token: String) {
        let defaults = UserDefaults.standard
        self.token = token
        defaults.set(token, forKey: "token")
        didChange.send(self.token)
    }
    
    func clearToken() {
        let defaults = UserDefaults.standard
        self.token = ""
        defaults.set(token, forKey: "token")
        didChange.send(self.token)
    }
}
