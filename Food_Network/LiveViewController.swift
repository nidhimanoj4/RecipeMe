//
//  LiveViewController.swift
//  Food_Network
//
//  Created by Nidhi Manoj on 7/26/16.

import UIKit
import AVKit
import AVFoundation
import DGElasticPullToRefresh

class LiveViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet weak var collectionView: UICollectionView!
    var videoDictionaries: [NSDictionary]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
        collectionView.dataSource = self
        refreshCollectionViewData()
        
        /* Here is where pull to refresh animation code begins */
        let loadingView = DGElasticPullToRefreshLoadingViewCircle()
        //Set color of loading view circle
        loadingView.tintColor = UIColor.darkGrayColor()
        collectionView.dg_addPullToRefreshWithActionHandler({ [weak self] () -> Void in
            self!.refreshCollectionViewData()
            self?.collectionView.dg_stopLoading()
            }, loadingView: loadingView)
        collectionView.dg_setPullToRefreshFillColor(UIColor(red: 132/255.0, green: 115/255.0, blue: 180/255.0, alpha: 1.0))
        collectionView.dg_setPullToRefreshBackgroundColor(collectionView.backgroundColor!)
        /* Here is where the pull to refresh animation code ends. */
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func refreshCollectionViewData() {
        let request: FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "/1777124462509631/videos", parameters: ["fields": "permalink_url,picture,description,source"], HTTPMethod: "GET")
        request.startWithCompletionHandler({(connection, result, error) -> Void in
            
            if let resultDictionary = result as? NSDictionary {
                self.videoDictionaries = resultDictionary["data"]! as? [NSDictionary]
                print("videoDictionaries from request: \n \(self.videoDictionaries!)")
                self.addTastyVideos()
            } else {
                print("Error in the network request for video posts: \(error.localizedDescription)")
            }
        })
    }
    
    func addTastyVideos() {
        let request: FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "/1614251518827491/videos", parameters: ["fields": "permalink_url,picture,description,source"], HTTPMethod: "GET")
        request.startWithCompletionHandler({(connection, result, error) -> Void in
            
            if let resultDictionary = result as? NSDictionary {
                let tastyVideoDictionaries = resultDictionary["data"]! as? [NSDictionary]
                (self.videoDictionaries!).appendContentsOf(tastyVideoDictionaries!)
                print("videoDictionaries from request: \n \(self.videoDictionaries!)")
                self.collectionView.reloadData()
            } else {
                print("Error in the network request for video posts: \(error.localizedDescription)")
            }
        })
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return (videoDictionaries != nil) ? min(videoDictionaries!.count,20) : 0
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("VideoCell", forIndexPath: indexPath) as! VideoCell
        let videoDictionary = videoDictionaries![indexPath.row]
        cell.videoDictionary = videoDictionary
        return cell
    }

    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        let cell = sender as! VideoCell
        let destinationVC = segue.destinationViewController as!
        AVPlayerViewController
        let url = NSURL(string: cell.sourceURL!)
        if let videoURL = url {
            destinationVC.player = AVPlayer(URL: videoURL)
        }
    }
}
