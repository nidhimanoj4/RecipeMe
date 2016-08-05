//
//  DetailsViewController.swift
//  Food_Network
//
//  Created by Grace Kotick on 7/15/16.
//

import UIKit
import Parse
import ParseUI

class DetailsViewController: UIViewController {
    
    @IBOutlet weak var completeView: UIView!
    @IBOutlet weak var finishedView: UIView!
    @IBOutlet weak var completedButton: UIButton!
    @IBOutlet weak var likesCountLabel: UILabel!
    @IBOutlet weak var commentLabel: UITextField!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var authorImage: UIImageView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var instructionsLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var imageView: PFImageView!
    @IBOutlet weak var okayImage: UIImageView!
    @IBOutlet weak var successImage: UIImageView!
    @IBOutlet weak var failImage: UIImageView!
    @IBOutlet weak var finishedCommentLabel: UILabel!
    var author: PFUser?
    var facebookID: String?
    var recipe: PFObject?
    var rating: String = "success"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        instructionsLabel.text = recipe![RecipeParams.instructions.rawValue] as? String
        
        //make instructions label expand based on length of text
        instructionsLabel.sizeToFit()
        
        //Make the profile image a circle
        authorImage.layer.cornerRadius = authorImage.frame.height / 2
        authorImage.clipsToBounds = true
        
        likesCountLabel.text = "\(recipe![RecipeParams.likesCount.rawValue] as! Int)"
        titleLabel.text = recipe![RecipeParams.title.rawValue] as? String
        imageView.file = recipe![RecipeParams.image.rawValue] as? PFFile
        imageView.loadInBackground()
        
        //get profile picture and name from facebook
        let authorNotFetched = recipe![RecipeParams.author.rawValue] as? PFUser
        do {
            author = try authorNotFetched!.fetchIfNeeded()
        } catch {
            author = authorNotFetched!
            print("fetchIfNeeded for author in the DetailsViewController failed")
        }
        facebookID = author!.valueForKey("facebookID") as! String
        self.returnUserData()
        
        //set up finished view and complete view to be below instructions
        finishedView.frame.origin.y = instructionsLabel.frame.origin.y + instructionsLabel.frame.height + 10
        completeView.frame.origin.y = instructionsLabel.frame.origin.y + instructionsLabel.frame.height + 10
        
        //default is to hide finished view
        finishedView.hidden = true
        
        //setup scrollview to go to the end of the last element which is ingredients
        scrollView.contentSize = CGSize(width: scrollView.frame.size.width, height: completeView.frame.origin.y + completeView.frame.height)
        
        //hide completed button if author is user
        if author?.username == PFUser.currentUser()?.username{
            completeView.hidden = true
        }
        
        //find if user has completed this recipe
        let user = PFUser.currentUser()
        print(user)
        let journal = user!["my_journal"] as! [NSDictionary]
        var previouslyCompleted = false
        var comment: String?
        for dictionary in journal{
            if (dictionary.valueForKey("recipeID") as? String) == self.recipe?.objectId!{
                previouslyCompleted = true
                //get rating and comment if recipe has been completed
                self.rating = (dictionary.valueForKey("rating") as? String)!
                comment = dictionary.valueForKey("comment") as? String
            }
        }
        
        //if they have, show finished view
        if previouslyCompleted == true{
            completeView.hidden = true
            finishedView.hidden = false
            //originally set all icons hidden
            successImage.hidden = true
            okayImage.hidden = true
            failImage.hidden = true
            //set correct image to be shown
            if self.rating == "success"{
                successImage.hidden = false
            } else if self.rating == "okay"{
                okayImage.hidden = false
            } else {
                failImage.hidden = false
            }
            finishedCommentLabel.text = comment
        }
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillShow:"), name:UIKeyboardWillShowNotification, object: nil);
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillHide:"), name:UIKeyboardWillHideNotification, object: nil);
        
    }
    
    func keyboardWillShow(sender: NSNotification) {
        self.view.frame.origin.y = -200
    }
    
    func keyboardWillHide(sender: NSNotification) {
        self.view.frame.origin.y = 0
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //get profile image and name of author
    func returnUserData() {
        let graphRequest : FBSDKGraphRequest = FBSDKGraphRequest(graphPath: self.facebookID, parameters: ["fields": "name, picture"])
        graphRequest.startWithCompletionHandler({ (connection, result, error) -> Void in
            if error != nil {
                // Process error
                print("Error: \(error.localizedDescription)")
            } else {
                //load name label and profileImage from user's facebook data
                var name: String = result.valueForKey("name") as! String
                self.authorLabel.text = name
                let pictureURL: NSURL = NSURL(string: "https://graph.facebook.com/\(self.facebookID!)/picture?type=large&return_ssl_resources=1")!
                let data = NSData(contentsOfURL: pictureURL)
                self.authorImage.image = UIImage(data: data!)
            }
        })
    }
    
    //rating changes depending on what segment is selected
    @IBAction func indexChanged(sender: AnyObject) {
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            rating = "success"
        case 1:
            rating = "okay"
        case 2:
            rating = "fail"
        default:
            break;
        }
    }
    
    //add recipeID, a rating, and a comment to user's journal in parse when a user has completed the recipe
    @IBAction func addToJournal(sender: AnyObject) {
        let currentUser = PFUser.currentUser()
        let comment = commentLabel.text!
        let journalEntry: NSDictionary = [
            "recipeID" : (self.recipe?.objectId!)!,
            "rating" : self.rating,
            "comment" : comment
        ]
        //add entry to journal
        var currentJournal = currentUser!["my_journal"] as! [NSDictionary]
        currentJournal.append(journalEntry)
        currentUser!["my_journal"] = currentJournal
        
        //save journal to parse
        currentUser?.saveInBackgroundWithBlock({ (success: Bool, error: NSError?) in
            if success{
                print("recipe added to my journal")
                if self.rating == "success"{
                    //update likesCount in recipe
                    let currentLikes = self.recipe![RecipeParams.likesCount.rawValue] as! Int
                    let newLikes = currentLikes + 1
                    self.recipe![RecipeParams.likesCount.rawValue] = newLikes
                    self.recipe?.saveInBackgroundWithBlock({ (success: Bool, error: NSError?) in
                        if success{
                            print("likesCount updated")
                            //update likesCount on detail view controller
                            self.likesCountLabel.text = "\(self.recipe![RecipeParams.likesCount.rawValue] as! Int)"
                        } else {
                            print(error?.localizedDescription)
                        }
                    })
                }
            } else {
                print(error?.localizedDescription)
            }
        })
        
        //hide complete view and show rating and comment
        completeView.hidden = true
        finishedView.hidden = false
        //originally set all icons hidden
        successImage.hidden = true
        okayImage.hidden = true
        failImage.hidden = true
        //set correct image to be shown
        if self.rating == "success"{
            successImage.hidden = false
        } else if self.rating == "okay"{
            okayImage.hidden = false
        } else {
            failImage.hidden = false
        }
        finishedCommentLabel.text = comment
    }
    
    //force touch - shows two action items: save for later and cancel, or if saved already: unsave and cancel
    override func previewActionItems() -> [UIPreviewActionItem] {
        let user = PFUser.currentUser()
        let recipeID = (self.recipe?.objectId)! as! String
        var saved = user!["saved_recipes"] as! [String]
        //check if recipe is already saved by current user
        var previouslySaved = false
        var savedIndex: Int?
        for savedRecipeID in saved{
            if savedRecipeID == recipeID{
                previouslySaved = true
                savedIndex = saved.indexOf(savedRecipeID)
            }
        }
        //create cancel action
        let cancelAction = UIPreviewAction(title: "Cancel", style: .Destructive) { (action, viewController) -> Void in
            print("cancelled")
        }
        //if recipe is not in user's saved recipes show save and cancel, else show unsave and cancel
        if previouslySaved == false {
            let saveAction = UIPreviewAction(title: "Save For Later", style: .Default) { (action, viewController) -> Void in
                //save recipe to user's saved recipes
                saved.append((self.recipe?.objectId)! as! String)
                user!["saved_recipes"] = saved
                user?.saveInBackground()
                print("saved")
            }
            return [saveAction, cancelAction]
        } else {
            let unSaveAction = UIPreviewAction(title: "Remove From Saved Recipes", style: .Default) { (action, viewController) -> Void in
                //let user unsave recipe
                saved.removeAtIndex(savedIndex!)
                user!["saved_recipes"] = saved
                user?.saveInBackground()
                print("unsaved")
            }
            return [unSaveAction, cancelAction]
        }
    }
    
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if (segue.identifier == "userProfileSegue") {
            let authorProfileViewController = segue.destinationViewController as! ProfileViewController
            authorProfileViewController.user = author
        }
        
        
    }
    
    
}