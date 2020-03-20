//
//  CreateViewController+SearchDelegate.swift
//  WebViewTester
//
//  Created by Shivani on 12/06/19.
//  Copyright © 2019 smallcase. All rights reserved.
//

import UIKit

extension CreateViewController: UISearchBarDelegate {
    @objc func dismissKeyboard() {
        searchBar.resignFirstResponder()
        quantityTextField.resignFirstResponder()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        dismissKeyboard()
        searchTableView.isHidden = false
        if !searchBar.text!.isEmpty {
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
            queryService.getSearchResults(searchTerm: searchBar.text!) { (results, errorMessage) in
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                if let results = results {
                    self.searchResults = results
                    self.searchTableView.reloadData()
                  //  self.searchTableView.setContentOffset(CGPoint.zero, animated: false)
                    
                }
                 if !errorMessage.isEmpty { print("Search error: " + errorMessage) }
            }
        }
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        view.addGestureRecognizer(tapRecognizer)
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        view.removeGestureRecognizer(tapRecognizer)
    }
    
}
