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
    var body: some View {
        
        Button("Apply for Loan") {
            print("-----------Trigger LOS Journey ----------- ")
        }
    }
}

@available(iOS 13.0, *)
struct LASScreen_Previews: PreviewProvider {
    static var previews: some View {
        LASScreen()
    }
}
