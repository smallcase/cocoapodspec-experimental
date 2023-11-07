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
    
    @State private var environmentIndex = 0
    
    @State private var PAN: String? = nil
    @State private var notes: String? = nil
    @State private var fromDate: String? = nil
    @State private var lender: String? = nil
    
    @State private var existingUserId: String? = nil
    
    @State private var currentTransactionId: String? = nil
    
    @State private var showingAlert = false
    @State private var isAlertMf = false
    @State private var alertTitle = "Success"
    @State private var alertMessage = ""
    
    func mfAlert() -> Alert {
        return Alert(
            title: Text(alertTitle),
            message: Text(alertMessage),
            primaryButton: .destructive(Text("Copy")) {
                UIPasteboard.general.string = alertMessage
                showingAlert = false
                isAlertMf = false
                print("SUCCESS POPUP COMPLETED")
                self.getMfHoldings(transactionId: currentTransactionId ?? "")
            },
            secondaryButton: .cancel() {
                showingAlert = false
                isAlertMf = false
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
                
            }
            
        }.alert(isPresented: $showingAlert) {
            isAlertMf ? mfAlert() :
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
    

    
    func importMFHoldings(transactionId:String) {
        do {
            try  SCGateway.shared.triggerMfTransaction(presentingController: hostingProvider.viewController!, transactionId: transactionId, completion: { [self] (result) in
                switch result {
                case .success(let response):
                    print("HOLDING RESPONSE: \(response)")
                    isAlertMf = true
                    self.showAlertDialog("Holdings Response", "\(response)")
                    
                case .failure(let error):
                    print(error)
                    self.showAlertDialog("Holdings Error", hostingProvider.viewController!.convertErrorToJsonString(error: error) ?? "error converting transaction error to JSON")
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
        showingAlert = true
        alertTitle = title
        alertMessage = message
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

