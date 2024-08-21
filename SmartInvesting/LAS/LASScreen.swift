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
    
    @EnvironmentObject var hostingProvider: ViewControllerProvider
    @EnvironmentObject var lasUserMode: LASUserMode
    
//    @EnvironmentObject var lasUser: LASUser
    
    @State private var gatewayName: String? = LASSessionManager.gatewayName
    
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
                            gatewayName = $0.lowercased()
                            LASSessionManager.gatewayName = $0.lowercased()
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
                        set: {
                            intent = $0
                            LASSessionManager.lasIntent = $0
                        }
                    ))
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    Text("Config")
                        .font(.subheadline)
                    
                    HStack(spacing: 20.0) {
                        TextField("amount", text: Binding(
                            get: { amount ?? "" },
                            set: {
                                amount = $0
                                LASSessionManager.losAmount = $0
                            }
                        ))
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        
                        TextField("type", text: Binding(
                            get: { type ?? "" },
                            set: {
                                type = $0.lowercased()
                                LASSessionManager.losType = $0.lowercased()
                            }
                        ))
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    
                    HStack(spacing: 20.0) {
                        TextField("lender", text: Binding(
                            get: { lender ?? "" },
                            set: {
                                lender = $0.lowercased()
                                LASSessionManager.lender = $0.lowercased()
                            }
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
                
                VStack(alignment: .center) {
                    
                    Button(action: {
                        service()
                    }) {
                        Text("Service")
                            .foregroundColor(.white)
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical)
                            .background(Color.blue)
                            .cornerRadius(10)
                    }.edgesIgnoringSafeArea(.horizontal)
                }.padding()
                
                HStack(alignment: .center) {
                    
                    Button(action: {
                        payLoanAmount()
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
                        withdrawAmount()
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
                
                Button(action: {
                    triggerInteraction()
                }) {
                    Text("Trigger Interaction")
                        .foregroundColor(.white)
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical)
                        .background(Color.blue)
                        .cornerRadius(10)
                }.edgesIgnoringSafeArea(.horizontal)
                .padding()
            
                
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
    
    func registerNewOrExistingUser() {
        
        switch lasUserMode.userMode {
            case .newUser: createUser()
            case .existingUser: getUser()
        }

    }
    
    func createUser() {
        SmartinvestingApi.shared.createUser() { result in
            switch result {
                case .success(let response):
                    
                if let res = response.toJson(), let resData = res["data"] as? [String: String] {
                    showAlertDialog("Registered User", resData.toJsonString ?? "")
                    LASSessionManager.lasUser = LASUser(lasUserId: resData["lasUserId"]!, opaqueId: resData["opaqueId"]!)
                    
                    ///set the UI Fields
                    opaqueId = LASSessionManager.lasUser?.opaqueId
                    userId = LASSessionManager.lasUser?.lasUserId
                    lender = LASSessionManager.lender
                    }
                case .failure(let error):
                showAlertDialog("Error Registering User", error.localizedDescription)
            }
        }
    }
    
    func getUser() {
        SmartinvestingApi.shared.getUser() { result in
            switch result {
                case .success(let response):
                    
                if let res = response.toJson(), let resData = res["data"] as? [String: String] {
                    showAlertDialog("Registered User", resData.toJsonString ?? "")
                    LASSessionManager.lasUser = LASUser(lasUserId: resData["lasUserId"]!, opaqueId: resData["opaqueId"]!)
                    
                    ///set the UI Fields
                    opaqueId = LASSessionManager.lasUser?.opaqueId
                    userId = LASSessionManager.lasUser?.lasUserId
                    lender = LASSessionManager.lender
                    }
                case .failure(let error):
                showAlertDialog("Error Registering User", error.localizedDescription)
            }
        }
    }
    
    func setupLoansSDK() {
        ScLoan.instance.setup(config: ScLoanConfig(gatewayName: gatewayName ?? "gatewaydemo", environment: LASSessionManager.lasEnvironment)) { result in
            
            switch result {
                case .success(let res):
                showAlertDialog("Setup Success", "\(String(describing: res.data))")
                
                case .failure(let error):
                showAlertDialog("Error Registering User", error.debugDescription)
                print(error.debugDescription)
            }
        }
    }
    
    func getInteractionToken() {
        SmartinvestingApi.shared.createInteraction() { result in
            switch result {
            case .success(let response):
                if let res = response.toJson(), let resData = res["data"] as? [String: String] {
                    showAlertDialog("Interaction Created", resData.toJsonString ?? "")
                    
                    ///set UI fields
                    interactionToken = resData["interactionToken"]
                }
            case .failure(let error):
                showAlertDialog("Error creating interaction token", "\(error)")
                print(error.localizedDescription)
            }
        }
    }
    
    func triggerLOSJourney() {
        ScLoan.instance.apply(presentingController: hostingProvider.viewController!, loanInfo: ScLoanInfo(interactionToken: interactionToken!)) { result in
            switch result {
            case .success(let ScLoanSuccess):
                print(ScLoanSuccess.data ?? "")
                showAlertDialog("Success", ScLoanSuccess.data ?? "")
                
            case .failure(let error):
                showAlertDialog("Error in apply", "\(String(describing: error.toPrettyJson()))")
                print(error.code)
            }
        }
    }
    
    func withdrawAmount() {
        ScLoan.instance.withdraw(presentingController: hostingProvider.viewController!, loanInfo: ScLoanInfo(interactionToken: interactionToken!)) { result in
            switch result {
            case .success(let ScLoanSuccess):
                print(ScLoanSuccess.data ?? "")
                showAlertDialog("Success", ScLoanSuccess.data ?? "")
                
            case .failure(let error):
                showAlertDialog("Error in withdraw", "\(String(describing: error.toPrettyJson()))")
                print(error.code)
            }
        }
    }
    
    func payLoanAmount() {
        ScLoan.instance.pay(presentingController: hostingProvider.viewController!, loanInfo: ScLoanInfo(interactionToken: interactionToken!)) { result in
            switch result {
            case .success(let ScLoanSuccess):
                print(ScLoanSuccess.data ?? "")
                showAlertDialog("Success", ScLoanSuccess.data ?? "")
                
            case .failure(let error):
                showAlertDialog("Error in pay", "\(String(describing: error.toPrettyJson()))")
                print(error.code)
            }
        }
    }
    
    func service() {
        ScLoan.instance.service(presentingController: hostingProvider.viewController!, loanInfo: ScLoanInfo(interactionToken: interactionToken!)) { result in
            switch result {
            case .success(let scLoanSuccess):
                print(scLoanSuccess.data ?? "")
                showAlertDialog("Success", scLoanSuccess.data ?? "")
            case .failure(let error):
                showAlertDialog("Error in service", "\(String(describing: error.toPrettyJson()))")
                print(error.code)
            }
        }
    }

func triggerInteraction() {
    ScLoan.instance.triggerInteraction(presentingController: hostingProvider.viewController!, loanInfo: ScLoanInfo(interactionToken: interactionToken!)) { result in
        switch result {
        case .success(let scLoanSuccess):
            print(scLoanSuccess.data ?? "")
            showAlertDialog("Success", scLoanSuccess.data ?? "")
        case .failure(let error):
            showAlertDialog("Error in trigger interaction", "\(String(describing: error.toPrettyJson()))")
            print(error.code)
        }
    }
}


    
    func showAlertDialog(_ title: String, _ message: String) {
        showingAlert = true
        alertTitle = title
        alertMessage = message
    }
}

@available(iOS 13.0, *)
struct LASScreen_Previews: PreviewProvider {
    static var previews: some View {
        LASScreen()
    }
}


extension ScLoanError {
    func toPrettyJson() -> String? {
        var errorDict : [String: Any?] = [
            "errorCode": errorCode,
            "errorMessage": errorMessage,
        ]
        
        if let errorData = data {
            errorDict["data"] = errorData.toDictionary
        }
        
        return errorDict.toJsonString
    }
}
