//
//  Flicks_ViewController.swift
//  Flicks
//
//  Created by Cristiano Miranda on 2/7/16.
//  Copyright © 2016 Cristiano Miranda. All rights reserved.
//

import UIKit
import AFNetworking
import MBProgressHUD

class Flicks_ViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UISearchBarDelegate {
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    @IBOutlet weak var networkErrorView: NetworkingError!
    @IBOutlet weak var searchBar: UISearchBar!

    var movies: [NSDictionary]?
    var filteredMovies: [NSDictionary]?
    
    var defaultEndPoint = EndPoints.nowPlaying
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        //searchBar = UISearchBar()
        searchBar.delegate = self
        //searchBar.sizeToFit()
        
        //flowLayout.scrollDirection = .Horizontal
        flowLayout.minimumLineSpacing = 10
        flowLayout.minimumInteritemSpacing = 0
        flowLayout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 10)
        
        initRefreshControl()
        getMoviesFromEndPoint(defaultEndPoint) // Gets movies now playing as default

        navigationItem.titleView = searchBar
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let filteredMovies = filteredMovies {
            return filteredMovies.count
        } else {
            return 0
        }
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Flicks_Cell", forIndexPath: indexPath) as! Flicks_Cell
        
        let movie = filteredMovies![indexPath.row]
        
        let baseUrl = "http://image.tmdb.org/t/p/w500"
        
        if let posterPath = movie["poster_path"] as? String {
            let imageUrl = NSURL(string: baseUrl + posterPath)
            cell.posterView.setImageWithURL(imageUrl!)
        }
        
        hasConnectivity()
        
        return cell
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
        collectionView.insertSubview(refreshControl, atIndex: 0)
    }
    
    func hasConnectivity() -> Bool {
        let reachability: Reachability = Reachability.reachabilityForInternetConnection()
        let networkStatus: Int = reachability.currentReachabilityStatus().rawValue
        
        networkErrorView.hidden = networkStatus != 0
        
        return networkStatus != 0
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
                                self.movies = responseDictionary["results"] as? [NSDictionary]
                                self.filteredMovies = self.movies
                                self.collectionView.reloadData()
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
                                self.movies = responseDictionary["results"] as? [NSDictionary]
                                self.collectionView.reloadData()
                                refreshControl.endRefreshing()
                        }
                    }
                    
            })
            task.resume()
        } else {
            refreshControl.endRefreshing()
        }
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            filteredMovies = movies
        } else {
            
        }
        collectionView.reloadData()
    }
    

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let cell = sender as! UICollectionViewCell
        let indexPath = collectionView.indexPathForCell(cell)
        let movie = movies![indexPath!.row]
        
        let detailViewController = segue.destinationViewController as! DetailsViewController
        detailViewController.movie = movie
        
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }

}
