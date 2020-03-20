//
//  ViewController.swift
//  WebViewTester
//
//  Created by Shivani on 06/06/19.
//  Copyright © 2019 smallcase. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    let segueId = "openWebView"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        urlTextField.text = "https://www.google.co.in/"
        // Do any additional setup after loading the view.
    }
    
    @IBOutlet weak var urlTextField: UITextField!
    
    @IBOutlet weak var errorLabel: UILabel!
    //MARK: - Action
    @IBAction func openWebView(_ sender: UIButton) {
        let urlString = urlTextField.text ?? ""
        if URL(string: urlString) != nil  {
            performSegue(withIdentifier: segueId, sender: self)
        }
        else {
            errorLabel.text = "Invalid URL string entered"
        }
    }
    
    @IBAction func openBrowser(_ sender: UIButton) {
        let urlString = urlTextField.text ?? ""
        if let url = URL(string: urlString)  {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
            
        }
        else {
            errorLabel.text = "Invalid URL string entered"
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destVC: WebViewController = segue.destination as! WebViewController
        destVC.urlString = urlTextField.text
    }
}


