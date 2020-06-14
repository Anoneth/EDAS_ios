//
//  LoginView.swift
//  EDAS
//
//  Created by Bla bla on 12.06.2020.
//  Copyright © 2020 Bla bla. All rights reserved.
//

import SwiftUI

struct LoginView: View {
    @State var login = ""
    @State var password = ""
    
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var tokenHolder: TokenHolder
    @ObservedObject var isLoginView: ObservableBool
    
    @State var hasError = false
    @State var errorMsg = ""
    
    var body: some View {
        NavigationView {
            VStack {
                TextField(NSLocalizedString("login", comment: ""), text: self.$login)
                    .padding()
                    .background(Color("flash-white"))
                    .cornerRadius(4.0)
                    .padding(EdgeInsets(top: 0, leading: 0, bottom: 15, trailing: 0))
                SecureField(NSLocalizedString("password", comment: ""), text: self.$password)
                    .padding()
                    .background(Color("flash-white"))
                    .cornerRadius(4.0)
                Button(action: {
                    self.doLogin()
                }, label: {
                    HStack(alignment: .center) {
                        Spacer()
                        Text(NSLocalizedString("doLogin", comment: "")).foregroundColor(self.login.isEmpty || self.password.isEmpty ? Color.gray : Color.white).bold()
                        Spacer()
                    }
                }).disabled(self.login.isEmpty || self.password.isEmpty)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(4.0)
            }
            .padding()
            .navigationBarTitle(NSLocalizedString("auth", comment: ""))
            .navigationBarItems(leading: Button(action: {
                self.isLoginView.value = false
            }, label: {
                Image(systemName: "chevron.left")
                Text(NSLocalizedString("back", comment: ""))
            }))
                .alert(isPresented: self.$hasError, content: {
                    Alert(title: Text(NSLocalizedString("error", comment: "")), message: Text(self.errorMsg), dismissButton: .destructive(Text("ok"), action: {
                        self.hasError = false
                        self.isLoginView.value = false
                    }))
                })
        }
    }
    
    func doLogin() {
        let params = ["login": self.login, "password": self.password]
        //let url = URL(string: "http://10.0.2.2:8080/Server_war/auth")!
        let url = URL(string: "https://56fbea53-d9ac-49e8-acca-c875a163c928.mock.pstmn.io/auth")!
        let session = URLSession.shared
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: params, options: .prettyPrinted)
        } catch {
            self.errorMsg = NSLocalizedString("internalError", comment: "")
            self.hasError = true
            print(error)
            return
        }
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        let task = session.dataTask(with: request, completionHandler: { (data, response, error) in
            guard error == nil else {
                self.errorMsg = NSLocalizedString("internalError", comment: "")
                self.hasError = true
                return
            }
            guard let data = data else {
                self.errorMsg = NSLocalizedString("internalError", comment: "")
                self.hasError = true
                return
            }
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any] {
                    if let code = json["code"] as? Int {
                        if code == 1 {
                            self.tokenHolder.setToken(token: json["token"] as! String)
                            self.isLoginView.value = false
                        } else {
                            self.errorMsg = NSLocalizedString("badPass", comment: "")
                            self.hasError = true
                        }
                    }
                }
            } catch {
                print(error)
            }
        })
        task.resume()
    }
}
