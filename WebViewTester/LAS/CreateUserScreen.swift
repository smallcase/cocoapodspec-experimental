//
//  CreateUserScreen.swift
//  WebViewTester
//
//  Created by Ankit Deshmukh on 29/05/23.
//  Copyright © 2023 smallcase. All rights reserved.
//

import SwiftUI

@available(iOS 15.0, *)
struct CreateUserScreen: View {
    
//    @StateObject var lasUser = LASUser()
    
    @State private var environmentIndex = 0
    
    @State private var PAN: String? = nil
    @State private var userId: String? = nil
    @State private var birthDate = Date.now
    @State private var lender: String? = nil
    
    @State private var existingUserId: String? = nil
    
    var body: some View {
        ScrollView {
            
            VStack(alignment: .center) {
                Text("SCGateway + Loans")
                    .font(.title)
                    .padding(.top, 20)
                
                Picker("Environment",
                       selection: Binding(
                        get: { environmentIndex ?? 0 },
                        set: {
                            environmentIndex = $0
                            LASSessionManager.envIndex = environmentIndex
                        }
                       )
                ) {
                    Text("PROD").tag(0)
                    Text("DEV").tag(1)
                    Text("STAG").tag(2)
                }
                .pickerStyle(.segmented).padding()
                
                //New User inputs
                VStack(alignment: .leading) {
                    Text("Create new user")
                        .font(.headline)
                    
                    TextField("PAN", text: Binding(
                        get: { PAN ?? "" },
                        set: {
                            PAN = $0
                            LASSessionManager.pan = $0
                        }
                    ))
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    DatePicker(
                        selection: Binding(
                            get: { birthDate },
                            set: {
                                birthDate = $0
                                LASSessionManager.dob = birthDate.formatted(date: .numeric, time: .omitted)
                            }
                        ),
                        in: ...birthDate, displayedComponents: .date) {
                        Text("Date of birth").font(.body)
                    }.padding(EdgeInsets.init(top: 15.0, leading: 0, bottom: 0, trailing: 0))
                    
//                    Text("Date: \(birthDate.formatted(date: .numeric, time: .omitted))")
                    
                    TextField("User Id", text: Binding(
                        get: { userId ?? "" },
                        set: {
                            userId = $0
                            LASSessionManager.userId = $0
                        }
                    ))
                    .padding(EdgeInsets.init(top: 15.0, leading: 0, bottom: 0, trailing: 0))
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    TextField("Lender", text: Binding(
                        get: { lender ?? "" },
                        set: {
                            lender = $0
                            LASSessionManager.lender = $0
                        }
                    ))
                    .padding(EdgeInsets.init(top: 15.0, leading: 0, bottom: 0, trailing: 0))
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    NavigationLink(
                        "Register New User",
                        destination: LASScreen()
                    )
                    .frame(maxWidth: .infinity, alignment: .center)
                    .buttonStyle(.borderedProminent)
                    .padding(EdgeInsets.init(top: 15.0, leading: 0, bottom: 0, trailing: 0))
                    
                }.padding()

                Divider()
                
                //Existing User inputs
                VStack(alignment: .leading) {
                    Text("Continue with registered user")
                        .font(.headline)
                    
                    TextField("User Id", text: Binding(
                        get: { existingUserId ?? "" },
                        set: {
                            existingUserId = $0
                            LASSessionManager.dob = ""
                            LASSessionManager.pan = ""
                            LASSessionManager.userId = ""
                        }
                    ))
                    .padding(EdgeInsets.init(top: 15.0, leading: 0, bottom: 0, trailing: 0))
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    NavigationLink(
                        "Select Existing User",
                        destination: LASScreen()
                    )
                    .frame(maxWidth: .infinity, alignment: .center)
                    .buttonStyle(.borderedProminent)
                    .padding(EdgeInsets.init(top: 15.0, leading: 0, bottom: 0, trailing: 0))
                    
                }.padding()
            }
            
        }
    }
}

@available(iOS 15.0, *)
struct CreateUserScreen_Previews: PreviewProvider {
    static var previews: some View {
        CreateUserScreen()
    }
}
