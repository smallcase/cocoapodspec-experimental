//
//  HistoricalViewController.swift
//  WebViewTester
//
//  Created by Shivani on 20/11/19.
//  Copyright © 2019 smallcase. All rights reserved.
//

import UIKit
import SCGateway

class HistoricalViewController: UIViewController {
    
    var scid: String? {
        didSet {
            loadHistoricalData()
        }
    }
    var benchmarkId: String?
 
    @IBOutlet weak var textView: UITextView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    
    func loadHistoricalData() {
        SCGateway.shared.getHistorical(scid: scid!, benchmarkId: benchmarkId ?? ".NSEI" , duration: nil) { [weak self] (data, error)  in
            
            guard let response = data else {
                if let error = error {
                    DispatchQueue.main.async { [weak self] in
                        self?.textView.text = error.localizedDescription
                    }
                }
                return
            }
            
            DispatchQueue.main.async { [weak self] in
                self?.textView.text = String(data: response, encoding: .utf8)
            }
            
        }
        
    }
    /*
     // MARK: - Navigation
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}
