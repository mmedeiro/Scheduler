//
//  ViewController.swift
//  Swift-Beginner
//
//  Created by Mariana Medeiro on 03/06/15.
//  Copyright (c) 2015 Mariana Medeiro. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var dadosTableView = []
    
    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        searchItunesFor("JQ")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dadosTableView.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell: UITableViewCell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "CellTeste")
        
        if let rowData: NSDictionary = self.dadosTableView[indexPath.row] as? NSDictionary,
            urlString = rowData["artworkUrl60"] as? String,
            imgURL = NSURL(string: urlString),
            formatedPrice = rowData["formattedPrice"] as? String,
            imgData = NSData(contentsOfURL: imgURL), trackName = rowData["trackName"] as? String {
            cell.detailTextLabel?.text = formatedPrice
            cell.imageView?.image = UIImage(data: imgData)
            cell.textLabel?.text = trackName
        }
        
        
        
        return cell
    }

    
    
    func searchItunesFor(searchTerm: String) {
        
        //separa os termos
        let itunesSearchTerm = searchTerm.stringByReplacingOccurrencesOfString(" ", withString: "+", options: NSStringCompareOptions.CaseInsensitiveSearch, range: nil)
        
        
        if let escapedSearchTerm = itunesSearchTerm.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding) {
            let urlPath = "http://itunes.apple.com/search?term=\(escapedSearchTerm)&media=software"
            let url = NSURL(string: urlPath)
            let session = NSURLSession.sharedSession()
            let task = session.dataTaskWithURL(url!, completionHandler: {data, response, error -> Void in
                println("Task completed")
                
                if (error != nil){
                    println(error.localizedDescription)
                }
                
                var err: NSError?
                if let jsonResult = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: &err) as? NSDictionary{
                    if (err != nil) {
                        println("JSON Error \(err!.localizedDescription)")
                    }
                    
                    if let results: NSArray = jsonResult["results"] as? NSArray {
                        dispatch_async(dispatch_get_main_queue(), {
                            self.dadosTableView = results
                            self.tableView!.reloadData()
                        })
                    }
                }
            })
            task.resume()
        }
      
    }


}

