//
//  LASScreen.swift
//  WebViewTester
//
//  Created by Ankit Deshmukh on 11/05/23.
//  Copyright © 2023 smallcase. All rights reserved.
//

import SwiftUI
import SCGateway
import Loans


@available(iOS 13.0, *)
struct LASScreen: View {
    
//    @EnvironmentObject var lasUser: LASUser
    
    @State private var gatewayName: String? = nil
    
    //Create interaction
    @State private var intent: String? = nil
    ///Config
    @State private var type: String? = nil
    @State private var lender: String? = nil
    @State private var opaqueId: String? = nil
    @State private var userId: String? = nil
    
    //Loan Details
    @State private var interactionToken: String? = nil
    @State private var loanId: String? = nil
    @State private var amount: String? = nil
    
    @State private var showingAlert = false
    @State private var alertTitle = "Success"
    @State private var alertMessage = ""
    
    var body: some View {
        ScrollView {
            
            VStack(alignment: .center) {
                
                Text("SCGateway + Loans")
                    .font(.title)
                    .padding(.top, 15)
                
                //Gateway inputs
                VStack(alignment: .leading) {
                    Text("Gateway Details")
                        .font(.headline)
                    
                    TextField("gatewayName", text: Binding(
                        get: { gatewayName ?? "" },
                        set: {
                            gatewayName = $0
                            LASSessionManager.gatewayName = $0
                        }
                    ))
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    Button(action: {
                        setupLoansSDK()
                    }) {
                        Text("Setup Loans SDK")
                            .foregroundColor(.white)
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical)
                            .background(Color.blue)
                            .cornerRadius(10)
                    }.padding(EdgeInsets.init(top: 10.0, leading: 0, bottom: 0, trailing: 0))
                    .edgesIgnoringSafeArea(.horizontal)
                    
                }.padding()
                
                //Create Interaction
                VStack(alignment: .leading, spacing: 15.0) {
                    Text("Create Interaction")
                        .font(.headline)
                    
                    TextField("intent", text: Binding(
                        get: { intent ?? "" },
                        set: { intent = $0 }
                    ))
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    Text("Config")
                        .font(.subheadline)
                    
                    HStack(spacing: 20.0) {
                        TextField("amount", text: Binding(
                            get: { amount ?? "" },
                            set: { amount = $0 }
                        ))
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        
                        TextField("type", text: Binding(
                            get: { type ?? "" },
                            set: { type = $0 }
                        ))
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    
                    HStack(spacing: 20.0) {
                        TextField("lender", text: Binding(
                            get: { lender ?? "" },
                            set: { lender = $0 }
                        ))
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        
                        
                        TextField("opaqueId", text: Binding(
                            get: { opaqueId ?? "" },
                            set: { opaqueId = $0 }
                        ))
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    
                    TextField("userId", text: Binding(
                        get: { userId ?? "" },
                        set: { userId = $0 }
                    ))
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    Button(action: {
                        getInteractionToken()
                    }) {
                        Text("Get interaction token")
                            .foregroundColor(.white)
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical)
                            .background(Color.blue)
                            .cornerRadius(10)
                    }.edgesIgnoringSafeArea(.horizontal)
                    
                }.padding()
                
                //Loan Inputs
                VStack(alignment: .leading) {
                    Text("Loan Details")
                        .font(.headline)
                    
                    TextField("interaction token", text: Binding(
                        get: { interactionToken ?? ""},
                        set: { interactionToken = $0 }
                    )).textFieldStyle(RoundedBorderTextFieldStyle())
                    
                }.padding()
                
                //LOS journey
                VStack(alignment: .center) {
                    
                    Button(action: {
                        triggerLOSJourney()
                    }) {
                        Text("Apply for Loan")
                            .foregroundColor(.white)
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical)
                            .background(Color.blue)
                            .cornerRadius(10)
                    }.edgesIgnoringSafeArea(.horizontal)
                }.padding()
                
                Text("Loan Servicing")
                    .font(.headline)
                
                HStack(alignment: .center) {
                    
                    Button(action: {
                        
                    }) {
                        Text("Pay")
                            .foregroundColor(.white)
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical)
                            .background(Color.blue)
                            .cornerRadius(10)
                    }.edgesIgnoringSafeArea(.horizontal)
                    
                    
                    Button(action: {
                        
                    }) {
                        Text("Withdraw")
                            .foregroundColor(.white)
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical)
                            .background(Color.blue)
                            .cornerRadius(10)
                    }.edgesIgnoringSafeArea(.horizontal)
                    
                }.padding()
                
            }.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        }.onAppear {
            self.registerNewOrExistingUser()
        }.alert(isPresented: $showingAlert) {
            Alert(
                title: Text(alertTitle),
                message: Text(alertMessage),
                primaryButton: .destructive(Text("Copy")) {
                    UIPasteboard.general.string = alertMessage
                    showingAlert = false
                },
                secondaryButton: .cancel()
            )
        }
    }
    
    func triggerLOSJourney() {
        SCLoans.instance.setupSCGatewayLoans(lasConfig: ScLoanConfig(gatewayName: gatewayName ?? "gatewaydemo")) { result in
            
        }
    }
    
    func getInteractionToken() {
        print(LASSessionManager.dob)
    }
    
    func setupLoansSDK() {
        SCLoans.instance.setupSCGatewayLoans(lasConfig: ScLoanConfig(gatewayName: gatewayName ?? "gatewaydemo", environment: LASSessionManager.lasEnvironment)) { result in
            
            switch result {
                case .success(_): print("Loans SDK setup successfully")
                case .failure(let error): print(error.debugDescription)
            }
        }
    }
    
    func registerNewOrExistingUser() {
        SmartinvestingApi.shared.createUser() { result in
            switch result {
                case .success(let response):
                
                    print(response.dictionaryValue)
                    print(response.dictionaryValue?["data"] as? [String: String])
                    
                    if let res = response.dictionaryValue, let resData = res["data"] as? [String: String] {
                        showingAlert = true
                        alertTitle = "Success"
                        alertMessage = resData.toJsonString ?? ""
                        LASSessionManager.lasUser = LASUser(lasUserId: resData["lasUserId"]!, opaqueId: resData["opaqueId"]!)
                    }
                case .failure(let error):
                    print(error.localizedDescription)
            }
        }
    }
}

@available(iOS 13.0, *)
struct LASScreen_Previews: PreviewProvider {
    static var previews: some View {
        LASScreen()
    }
}
