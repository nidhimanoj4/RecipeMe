//
//  FriendsViewCell.swift
//  Food_Network
//
//  Created by Kenya Gordon on 7/27/16.
//  Copyright © 2016 Facebook. All rights reserved.
//

import UIKit

class FriendsViewCell: UITableViewCell {

    @IBOutlet weak var friendProfileImage: UIImageView!
    @IBOutlet weak var friendName: UILabel!
    var facebookID: String!
    var name: String?
    
    var friend: PFUser? {
        didSet{
            
            //Make the profile image a circle
            friendProfileImage.layer.cornerRadius = friendProfileImage.frame.height / 2
            friendProfileImage.clipsToBounds = true
            let graphRequest : FBSDKGraphRequest = FBSDKGraphRequest(graphPath: friend!.valueForKey("facebookID") as! String, parameters: ["fields": "name, email, friends, picture, cover"])
            graphRequest.startWithCompletionHandler({ (connection, result, error) -> Void in
                
                if error != nil {
                    // Process error
                    print("Error: \(error.localizedDescription)")
                } else {
                    //load name label and profileImage from user facebook data
                    self.facebookID = result.valueForKey("id") as! String
                    //created a field in PFUser to get the users name
                    self.friend!["name"] = result.valueForKey("name")
                    self.friend?.saveInBackground()
                    self.name = result.valueForKey("name") as! String
                    self.friendName.text = self.name
                    let pictureURL: NSURL = NSURL(string: "https://graph.facebook.com/\(self.facebookID)/picture?type=large&return_ssl_resources=1")!
                    let data = NSData(contentsOfURL: pictureURL)
                    self.friendProfileImage.image = UIImage(data: data!)
                }
            })
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
