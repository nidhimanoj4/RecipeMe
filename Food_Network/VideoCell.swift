//
//  VideoCell.swift
//  Food_Network
//
//  Created by Nidhi Manoj on 7/29/16.

import UIKit
import AFNetworking

class VideoCell: UICollectionViewCell {
    
    @IBOutlet weak var videoScreenshotImage: UIImageView!
    var sourceURL: String?
    
    var videoDictionary: NSDictionary? {
        didSet {
            let video_pictureUrlString = videoDictionary!["picture"] as? String
            let source_url = videoDictionary!["source"] as? String
            
            sourceURL = source_url
            
            let video_pictureURL = NSURL(string: video_pictureUrlString!)
            videoScreenshotImage.setImageWithURL(video_pictureURL!)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
}
