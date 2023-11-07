//
//  MFHoldingsSwiftUIView.swift
//  WebViewTester
//
//  Created by Indrajit Roy on 07/11/23.
//  Copyright © 2023 smallcase. All rights reserved.
//

import SwiftUI
import SCGateway

@available(iOS 15.0, *)
struct MFHoldingsSwiftUIView: View {
    
    @EnvironmentObject var hostingProvider: ViewControllerProvider
    @StateObject var currentUserMode = LASUserMode()
    //    @StateObject var lasUser = LASUser()
    
    @State private var notes: String? = nil
    @State private var fromDate: String? = nil
    
    @State private var currentTransactionId: String? = nil
    
    @State private var showingAlert = false
    @State private var alertTitle = "Success"
    @State private var alertMessage = ""
    
    @State private var shouldFetchPostbackAfterAlerting = false
    
    func mfAlert() -> Alert {
        return Alert(
            title: Text("MF Alert!"+alertTitle),
            message: Text(alertMessage),
            primaryButton: .destructive(Text("Copy")) {
                UIPasteboard.general.string = alertMessage
                showingAlert = false
                shouldFetchPostbackAfterAlerting = false
                print("SUCCESS POPUP COMPLETED")
                self.getMfHoldings(transactionId: currentTransactionId ?? "")
            },
            secondaryButton: .cancel() {
                showingAlert = false
                shouldFetchPostbackAfterAlerting = false
                print("SUCCESS POPUP COMPLETED")
                
                self.getMfHoldings(transactionId: currentTransactionId ?? "")
            }
        )
    }
    
    var body: some View {
        ScrollView {
            
            VStack(alignment: .center) {
                TextField("Enter Notes", text: Binding(
                    get: { notes ?? "" },
                    set: {
                        notes = $0
                    }
                ))
                .padding(EdgeInsets.init(top: 15.0, leading: 0, bottom: 0, trailing: 0))
                .textFieldStyle(RoundedBorderTextFieldStyle())
                
                TextField("Enter From Date YYYY-MM-DD", text: Binding(
                    get: { fromDate ?? "" },
                    set: {
                        fromDate = $0
                    }
                ))
                .padding(EdgeInsets.init(top: 15.0, leading: 0, bottom: 0, trailing: 0))
                .textFieldStyle(RoundedBorderTextFieldStyle())
                
                Button(action: {
                    let params = CreateTransactionBody(id: "", intent: IntentType.MF_HOLDINGS_IMPORT.rawValue,notes: notes, orderConfig: nil, assetConfig: AssetConfig(fromDate: fromDate))
                    createTransactionId(params: params) { txnId in
                        guard let id = txnId else {
                            showAlertDialog("Error creating TxnId", "Something went wrong")
                            return
                        }
                        currentTransactionId = id
                        self.importMFHoldings(transactionId: id)
                    }
                }) {
                    Text("Import MF Holdings")
                        .foregroundColor(.white)
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical)
                        .background(Color.blue)
                        .cornerRadius(10)
                }.edgesIgnoringSafeArea(.horizontal)
                
                TextField("Enter MF txn Id", text: Binding(
                    get: { currentTransactionId ?? "" },
                    set: {
                        currentTransactionId = $0
                    }
                ))
                .padding(EdgeInsets.init(top: 15.0, leading: 0, bottom: 0, trailing: 0))
                .textFieldStyle(RoundedBorderTextFieldStyle())
                
                Button(action: {
                    getMfHoldings(transactionId: currentTransactionId ?? "")
                }) {
                    Text("Fetch Postback")
                        .foregroundColor(.white)
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical)
                        .background(Color.blue)
                        .cornerRadius(10)
                }.edgesIgnoringSafeArea(.horizontal)
                
                Button(action: {
                    importMFHoldings(transactionId: currentTransactionId ?? "")
                }) {
                    Text("Trigger MF Txn")
                        .foregroundColor(.white)
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical)
                        .background(Color.blue)
                        .cornerRadius(10)
                }.edgesIgnoringSafeArea(.horizontal)
                
            }
            
        }.alert(isPresented: $showingAlert) {
            shouldFetchPostbackAfterAlerting ? mfAlert() :
            Alert(
                title: Text(alertTitle),
                message: Text(alertMessage),
                primaryButton: .destructive(Text("Copy")) {
                    UIPasteboard.general.string = alertMessage
                    showingAlert = false
                },
                secondaryButton: .cancel() {
                    showingAlert = false
                }
            )
        }
        
    }
    
    
    
    func importMFHoldings(transactionId:String) {
        do {
            try  SCGateway.shared.triggerMfTransaction(presentingController: hostingProvider.viewController!, transactionId: transactionId, completion: { [self] (result) in
                switch result {
                case .success(let response):
                    print("HOLDING RESPONSE: \(response)")
                    shouldFetchPostbackAfterAlerting = true
                    self.showAlertDialog("MF Txn Response", "\(response)")
                    
                case .failure(let error):
                    print(error)
                    shouldFetchPostbackAfterAlerting = true
                    self.showAlertDialog("MF Txn Error Response", hostingProvider.viewController!.convertErrorToJsonString(error: error) ?? "error converting transaction error to JSON")
                }
            })
        }
        catch let err {
            print(err)
            self.showAlertDialog("Gateway Error", err.localizedDescription)
        }
    }
    
    func getMfHoldings(transactionId: String) -> Void {
        SmartinvestingApi.shared.getPostbackResponse(transactionId: transactionId) { result in
            switch result {
            case .success(let response):
                print("MF HOLDING RESPONSE: \(response)")
                self.showAlertDialog("Holdings Response", "\(response)")
                
            case .failure(let error):
                print(error)
                self.showAlertDialog("Holdings Error", "\(error)")
            }
        }
    }
    
    func showAlertDialog(_ title: String, _ message: String) {
        // Added delay bacause two alerts displayed back to back was causing an issue woth the disposal of the first one
        // Should think of a better way
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            showingAlert = true
            alertTitle = title
            alertMessage = message
        }
    }
    
}

private func createTransactionId(params: CreateTransactionBody, completion: @escaping (String?) -> Void) {
    
    SmartinvestingApi.shared.getTransactionId(params: params) { (result) in
        switch result {
        case .success(let response):
            print(response)
            guard let transactionId = response.transactionId else { return }
            completion(transactionId)
            
            
        case .failure(let error):
            print(error)
            
        }
    }
    
}

@available(iOS 15.0, *)
struct MFHoldingsSwiftUIView_Previews: PreviewProvider {
    static var previews: some View {
        MFHoldingsSwiftUIView()
    }
}

