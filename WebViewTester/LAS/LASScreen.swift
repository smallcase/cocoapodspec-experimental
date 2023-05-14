//
//  LASScreen.swift
//  WebViewTester
//
//  Created by Ankit Deshmukh on 11/05/23.
//  Copyright © 2023 smallcase. All rights reserved.
//

import SwiftUI

@available(iOS 13.0, *)
struct LASScreen: View {
    
    @State private var gatewayName: String? = nil
    
    @State private var interactionToken: String? = nil
    @State private var loanId: String? = nil
    @State private var amount: String? = nil
    
    var body: some View {
        VStack(alignment: .center) {
            
            Text("SCGateway + Loans")
                .font(.title)
                .padding(.top, 20)
            
            //Gateway inputs
            VStack(alignment: .leading) {
                Text("Gateway Details")
                    .font(.headline)
                
                TextField("gatewayName", text: Binding(
                    get: { gatewayName ?? "" },
                    set: { gatewayName = $0 }
                ))
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }.padding()
            
            //Loan Inputs
            VStack(alignment: .leading) {
                Text("Loan Details")
                    .font(.headline)
                
                TextField("interaction token", text: Binding(
                    get: { interactionToken ?? ""},
                    set: { interactionToken = $0 }
                )).textFieldStyle(RoundedBorderTextFieldStyle())
                
                TextField("loan Id", text: Binding(
                    get: {loanId ?? ""},
                    set: {loanId = $0}
                )).textFieldStyle(RoundedBorderTextFieldStyle())
                
                TextField("amount", text: Binding(
                    get: {amount ?? ""},
                    set: {amount = $0}
                )).textFieldStyle(RoundedBorderTextFieldStyle())
                
            }.padding()
            
            //LOS journey
            VStack(alignment: .center) {
                
                Button(action: {
                    print("triggering LOS journey for \(gatewayName) \(interactionToken) \(loanId) \(amount)")
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
                
                
                Button(action: {
                    
                }) {
                    Text("Close Loan")
                        .foregroundColor(.white)
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical)
                        .background(Color.blue)
                        .cornerRadius(10)
                }.edgesIgnoringSafeArea(.horizontal)
                
            }.padding()
            
            
        }.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        
    }
}

@available(iOS 13.0, *)
struct LASScreen_Previews: PreviewProvider {
    static var previews: some View {
        LASScreen()
    }
}
