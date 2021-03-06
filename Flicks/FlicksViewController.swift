//
//  FlicksViewController.swift
//  Flicks
//
//  Created by Cristiano Miranda on 2/3/16.
//  Copyright © 2016 Cristiano Miranda. All rights reserved.
//

import UIKit
import AFNetworking
import MBProgressHUD

class FlicksViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var networkingErrorView: NetworkingError!
    
    var flicks: [NSDictionary]?
    
    var defaultEndPoint = EndPoints.nowPlaying
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        
        initRefreshControl()
        getMoviesFromEndPoint(defaultEndPoint) // Gets movies now playing as default
    }
    
    func hasConnectivity() -> Bool {
        let reachability: Reachability = Reachability.reachabilityForInternetConnection()
        let networkStatus: Int = reachability.currentReachabilityStatus().rawValue
        
        networkingErrorView.hidden = networkStatus != 0
        
        return networkStatus != 0
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Create the NSURLRequest
    func createNSURLRequest(tmdbEndPoint: String) -> NSURLRequest {
        let apiKey = "71731b29bc37cf711170078f3116ac38"
        let url = NSURL(string: "https://api.themoviedb.org/3\(tmdbEndPoint)?api_key=\(apiKey)")
        let request = NSURLRequest(
            URL: url!,
            cachePolicy: NSURLRequestCachePolicy.ReloadIgnoringLocalCacheData,
            timeoutInterval: 10)
    
        return request
    }
    
    func configureSession() -> NSURLSession {
        let session = NSURLSession(
            configuration: NSURLSessionConfiguration.defaultSessionConfiguration(),
            delegate: nil,
            delegateQueue: NSOperationQueue.mainQueue()
        )
        return session
    }
    
    func displayHUD() {
        // Display HUD right before the request is made
        MBProgressHUD.showHUDAddedTo(self.view, animated: true)
    }
    
    func initRefreshControl() {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: "refreshControlAction:", forControlEvents: UIControlEvents.ValueChanged)
        tableView.insertSubview(refreshControl, atIndex: 0)
    }
    
    func getMoviesFromEndPoint(endPoint: String) {
        if(hasConnectivity()) {
            let request = createNSURLRequest(endPoint)
            let session = configureSession()
            displayHUD()
            
            let task: NSURLSessionDataTask = session.dataTaskWithRequest(request,
                completionHandler: { (dataOrNil, response, error) in
                    
                // Hide HUD once the network request comes back (must be done on main UI thread)
                MBProgressHUD.hideHUDForView(self.view, animated: true)
                
                if let data = dataOrNil {
                    if let responseDictionary = try! NSJSONSerialization.JSONObjectWithData(
                        data, options:[]) as? NSDictionary {
                            self.flicks = responseDictionary["results"] as? [NSDictionary]
                            self.tableView.reloadData()
                    }
                }
            })
            task.resume()
        }
    }
    
    func refreshControlAction(refreshControl: UIRefreshControl) {
        if(hasConnectivity()) {
            let request = createNSURLRequest(defaultEndPoint)
            let session = configureSession()
            displayHUD()
            
            let task: NSURLSessionDataTask = session.dataTaskWithRequest(request,
                completionHandler: { (dataOrNil, response, error) in
                    
                    // Hide HUD once the network request comes back (must be done on main UI thread)
                    MBProgressHUD.hideHUDForView(self.view, animated: true)
                    
                    if let data = dataOrNil {
                        if let responseDictionary = try! NSJSONSerialization.JSONObjectWithData(
                            data, options:[]) as? NSDictionary {
                                self.flicks = responseDictionary["results"] as? [NSDictionary]
                                self.tableView.reloadData()
                                refreshControl.endRefreshing()
                        }
                    }
                    
            })
            task.resume()
        } else {
            refreshControl.endRefreshing()
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if let flicks = flicks {
            return flicks.count
        } else {
            return 0
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("FlickCell", forIndexPath: indexPath) as! FlickCell
        
        let flick = flicks![indexPath.row]
        let title = flick["title"] as! String
        let overview = flick["overview"] as! String
        let posterPath = flick["poster_path"] as! String
        
        let baseUrl = "http://image.tmdb.org/t/p/w500"
        let imageUrl = NSURL(string: baseUrl + posterPath)
        
        cell.titleLabel.text = title
        cell.overviewLabel.text = overview
        cell.posterView.setImageWithURL(imageUrl!)

        hasConnectivity()
        return cell
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
