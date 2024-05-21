//
//  View+Ext.swift
//  WebViewTester
//
//  Created by Ankit Deshmukh on 30/05/23.
//  Copyright © 2023 smallcase. All rights reserved.
//

import Foundation
import UIKit
import SwiftUI


@available(iOS 13.0, *)
internal extension View {
    func embeddedInHostingController() -> UIHostingController<some View> {
      let provider = ViewControllerProvider()
      let hostingAccessingView = environmentObject(provider)
      let hostingController = UIHostingController(rootView: hostingAccessingView)
      provider.viewController = hostingController
      return hostingController
    }
}

@available(iOS 13.0, *)
final class ViewControllerProvider: ObservableObject {
  fileprivate(set) weak var viewController: UIViewController?
}
