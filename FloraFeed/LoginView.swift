//
//  LoginView.swift
//  FloraFeed
//
//  Created by Brydniak, Tiphaine on 12/10/2023.
//

import SwiftUI
import FirebaseAuth

struct LoginView: View {
    
    @State var email: String = ""
    @State var password: String = ""
    @State var showPassword: Bool = false
    @State var isShowingPlantView = false
    
    var loginIsDisabled: Bool {
        [email, password].contains(where: \.isEmpty)
    }
    
    //todo update colour scheme etc
    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 15) {
                Spacer()
                
                TextField("Email",
                          text: $email ,
                          prompt: Text("Login").foregroundColor(.blue)
                )
                .padding(10)
                .overlay {
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(.blue, lineWidth: 2)
                }
                .padding(.horizontal)
                
                HStack {
                    Group {
                        if showPassword {
                            TextField("Password",
                                      text: $password,
                                      prompt: Text("Password").foregroundColor(.red))
                        } else {
                            SecureField("Password",
                                        text: $password,
                                        prompt: Text("Password").foregroundColor(.red))
                        }
                    }
                    .padding(10)
                    .overlay {
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(.red, lineWidth: 2)
                    }
                    Button {
                        showPassword.toggle()
                    } label: {
                        Image(systemName: showPassword ? "eye.slash" : "eye")
                            .foregroundColor(.red)
                    }
                    
                }.padding(.horizontal)
                
                Spacer()
                Button {
                    // handleFirebaseLogin()
                    toggleLogin()
                } label: {
                    Text("Login")
                        .font(.title2)
                        .bold()
                        .foregroundColor(.white)
                }
                .frame(height: 50)
                .frame(maxWidth: .infinity)
                .background(
                    loginIsDisabled ? LinearGradient(colors: [.gray], startPoint: .topLeading, endPoint: .bottomTrailing) :
                        LinearGradient(colors: [.blue, .red], startPoint: .topLeading, endPoint: .bottomTrailing)
                )
                .cornerRadius(20)
                .disabled(loginIsDisabled) // how to disable while some condition is applied
                .padding()
                NavigationLink(destination: PlantTableView(), isActive: $isShowingPlantView) {  }
            }
        }
    }
    
    func handleFirebaseLogin() {
        if email != "" && password != "" {
            Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
                if let error = error {
                    //todo add actual alert action
                    print("there was an error logging in"+error.localizedDescription)
                } else {
                    //todo remove logs etc
                    print("success!")
                    isShowingPlantView = true
                }
            }
        }
    }
    
    func toggleLogin() {
        //while testing
        isShowingPlantView = !isShowingPlantView
        print(isShowingPlantView)
    }
}
