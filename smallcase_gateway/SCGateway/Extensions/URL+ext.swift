//
//  URL+ext.swift
//  SCGateway
//
//  Created by Ankit Deshmukh on 29/06/22.
//  Copyright © 2022 smallcase. All rights reserved.
//

import Foundation

extension URL {
    func valueOfQueryParam(_ queryParameterName: String) -> String? {
        guard let url = URLComponents(string: self.absoluteString) else { return nil }
        return url.queryItems?.first(where: { $0.name == queryParameterName })?.value
    }
}
