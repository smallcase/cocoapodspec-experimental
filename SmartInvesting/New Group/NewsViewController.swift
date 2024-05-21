//
//  NewsViewController.swift
//  WebViewTester
//
//  Created by Shivani on 19/11/19.
//  Copyright © 2019 smallcase. All rights reserved.
//

import UIKit
import SCGateway

class NewsViewController: UITableViewController {
    
    enum Constants {
        static let cellReuseId = "newsTVCell"
        static let cellNibName = "NewsTableViewCell"
    }
    
    var scid: String? {
        didSet {
            getNews()
        }
    }
    
    var iscid: String? {
        didSet {
            getNews()
        }
    }
    
    var news: [News]? {
        didSet {
            DispatchQueue.main.async { [weak self] in
                self?.tableView.reloadData()
                LoadingOverlay.shared.hideLoader()
            }
        }
    }
    
    func getNews() {
        
        SCGateway.shared.getSmallcaseNews(scid: scid, iscid: iscid, optionalParams: nil) { [weak self] data, error  in
            
            guard let response = data else {
                if let error = error {
                     print(error)
                }
                return
            }

                do {
                    let newsData = try JSONDecoder().decode(NewsResponse.self, from: response)
                    self?.news = newsData.data?.news
                }
                catch let err {
                    print(err)
                }
        }
      
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        LoadingOverlay.shared.showLoader(view: view)
        let nib = UINib(nibName: Constants.cellNibName, bundle: nil)
        
        tableView.register(nib, forCellReuseIdentifier: Constants.cellReuseId)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      
        return news?.count ?? 0
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: Constants.cellReuseId, for: indexPath) as? NewsTableViewCell  else   {  fatalError() }
        
        cell.newsItem = news![indexPath.item]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let link = news?[indexPath.item].link, let url = URL(string: link) else { return }
        
        UIApplication.shared.open(url, options: [:], completionHandler: nil)

    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

