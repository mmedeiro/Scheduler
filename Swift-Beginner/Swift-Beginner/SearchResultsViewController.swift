//
//  ViewController.swift
//  Swift-Beginner
//
//  Created by Mariana Medeiro on 03/06/15.
//  Copyright (c) 2015 Mariana Medeiro. All rights reserved.
//

import UIKit

class SearchResultsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, APIControllerProtocol {
    
    let kCellIdentifier: String = "SearchResultCell"
    var api : APIController!
    var albums = [Album] ()
    var imageCache = [String: UIImage]()
    
    
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        api = APIController(delegate: self)
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        api.searchItunesFor("Beatles")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return albums.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: UITableViewCell = tableView.dequeueReusableCellWithIdentifier(kCellIdentifier) as! UITableViewCell
        let album = self.albums[indexPath.row]
        
        cell.detailTextLabel?.text = album.price

        cell.textLabel?.text = album.title
        
        cell.imageView?.image = UIImage(named: "Blank52")
        
        let thumbnailURLString = album.thumbnailImageURL
        let thumbnailURL = NSURL(string: thumbnailURLString)!
        
        if let img = imageCache[thumbnailURLString] {
            cell.imageView?.image = img
        }
        else {
            let request: NSURLRequest = NSURLRequest(URL: thumbnailURL)
            let mainQueue = NSOperationQueue.mainQueue()
            NSURLConnection.sendAsynchronousRequest(request, queue: mainQueue, completionHandler: { (response, data, error) -> Void in
                if error == nil {
                    
                    let image = UIImage(data: data)
                    
                    self.imageCache[thumbnailURLString] = image
                    dispatch_async(dispatch_get_main_queue(), {
                        if let cellToUpdate = tableView.cellForRowAtIndexPath(indexPath) {
                            cellToUpdate.imageView?.image = image
                        }
                    })
                }
                else {
                    println("Error: \(error.localizedDescription)")
                }
            })
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
                            self.albums = Album.albumsWithJSON(results)
                            self.tableView!.reloadData()
                        })
                    }
                }
            })
            task.resume()
        }
        
    }
    
    func didReceiveAPIResults(results: NSArray) {
        dispatch_async(dispatch_get_main_queue(), {
            self.albums = Album.albumsWithJSON(results)
            self.tableView!.reloadData()
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        })
    }
    
//    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
//        if let rowData = self.albums[indexPath.row] {
//            name = rowData["trackName"] as? String,
//            formatedPrice = rowData["formattedPrice"] as? String {
//                let alert = UIAlertController(title: name, message: formatedPrice, preferredStyle: .Alert)
//                alert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: nil))
//                self.presentViewController(alert, animated: true, completion: nil)
//        }
//    }
    
        func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
            // Get the row data for the selected row
            if let rowData = self.albums[indexPath.row] as? NSDictionary,
                // Get the name of the track for this row
                name = rowData["trackName"] as? String,
                // Get the price of the track on this row
                formattedPrice = rowData["formattedPrice"] as? String {
                    let alert = UIAlertController(title: name, message: formattedPrice, preferredStyle: .Alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: nil))
                    self.presentViewController(alert, animated: true, completion: nil)
            }
        }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let detailsViewController: DetailsViewController = segue.destinationViewController as? DetailsViewController {
            var albumIndex = tableView!.indexPathForSelectedRow()!.row
            var selectedAlbum = self.albums[albumIndex]
            detailsViewController.album = selectedAlbum
        }
    }
    
}


