//
//  ViewController.swift
//  Food_Network
//
//  Created by Nidhi Manoj on 7/6/16.
//

import UIKit
import ParseFacebookUtilsV4

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewDidAppear(animated: Bool) {
        //FBSDKAccessToken.currentAccessToken()
        if (PFUser.currentUser() != nil)
        {
            // User is already logged in, do work such as go to next view controller.
            performSegueWithIdentifier("LoginSegue", sender: nil)
        }
    }
 
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
   
    @IBAction func loginWithFacebook(sender: AnyObject) {
        // Set permissions required from the facebook user account
        var permissionsArray: [String] = ["public_profile", "email", "user_friends"]
        // Login PFUser using Facebook
        PFFacebookUtils.logInInBackgroundWithReadPermissions(permissionsArray) {(user: PFUser?, error: NSError?) -> Void in
            if let user = user {
                let basicIngredArray = ["water", "salt", "pepper", "sugar", "oil", "butter"]
                if user.isNew {
                    print("User signed up and logged in through Facebook!")
                    user["my_recipesCount"] = 0
                    user["my_journal"] = [NSDictionary]()
                    user["saved_recipes"] = [String]()
                    user["ingredientsNamesChosen"] = basicIngredArray //initial basic ingredients array
                    self.returnUserData()
                } else {
                    print("User logged in through Facebook!")
                }
            } else {
                print("Uh oh. The user cancelled the Facebook login.")
            }
        }
    }
    
    func returnUserData()
    {
        let graphRequest : FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, name"])
        graphRequest.startWithCompletionHandler({ (connection, result, error) -> Void in
            
            if error != nil {
                // Process error
                print("Error: \(error.localizedDescription)")
            } else {
                //load name label and profileImage from user facebook data
                let me: PFUser = PFUser.currentUser()!
                me["facebookID"] = result.valueForKey("id") as! String
                me["name"] = result.valueForKey("name") as! String
                me.saveInBackground()
            }
        })

    }

}