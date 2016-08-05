//
//  ProfileViewController.swift
//  Food_Network
//
//  Created by Grace Kotick on 7/12/16.

import UIKit
import Parse

class ProfileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    @IBOutlet weak var levelLabel: UILabel!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var tableView2: UITableView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var numberCompletedRecipesLabel: UILabel!
    @IBOutlet weak var numberMyRecipesLabel: UILabel!
    @IBOutlet weak var logoutButton: UIBarButtonItem!
    var user: PFUser!
    var journal: [NSDictionary] = []
    var facebookID: String!
    var myrecipes: [PFObject] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //so that if clicked tab bar profile item it goes to current users profile
        if user == nil {
            user = PFUser.currentUser()
        }
        //Make the profile image a circle
        profileImage.layer.cornerRadius = profileImage.frame.height / 2
        profileImage.clipsToBounds = true
        
        self.returnUserData()
        tableView.delegate = self
        tableView.dataSource = self
        tableView2.delegate = self
        tableView2.dataSource = self
        journal = user["my_journal"] as! [NSDictionary]
        self.loadData()
        tableView.hidden = true
        tableView2.hidden = false
        //logout button only appears on current users profile
        if user != PFUser.currentUser(){
            self.navigationItem.rightBarButtonItem = nil;
            self.navigationItem.leftBarButtonItem = nil;
        }
        whenScreenAppears()
    }
    
    func loadData(){
        var query = PFQuery(className: "Recipe")
        query.orderByDescending("_created_at")
        query.includeKey("author")
        query.whereKey("author", equalTo: user)
        query.findObjectsInBackgroundWithBlock{ (recipes: [PFObject]?, error: NSError?) -> Void in
            if error == nil{
                self.myrecipes = recipes!
                
                self.tableView2.reloadData()
            } else{
                print(error)
            }
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        whenScreenAppears()
    }
    
    func levelCalculator(recipeCount: Int, journal: [NSDictionary]){
        let count = recipeCount + journal.count
        if Double(count/10) < 1{
            levelLabel.text = "Level 1"
        } else {
            let level = Int(floor(log2(Double(count/10))))
            levelLabel.text = "Level \(level+2)"
        }
    }
    
    func whenScreenAppears() {
        numberMyRecipesLabel.text = "\(user.valueForKey("my_recipesCount")!)"
        numberCompletedRecipesLabel.text = "\(user.valueForKey("my_journal")!.count)"
        journal = user["my_journal"] as! [NSDictionary]
        let recipeCount = user.valueForKey("my_recipesCount")! as! Int
        levelCalculator(recipeCount, journal: journal)
        tableView.reloadData()
        loadData()
        tableView2.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func logoutButton(sender: AnyObject) {
        PFUser.logOutInBackgroundWithBlock { (error: NSError?) in
            // PFUser.currentUser() will now be nil
        }
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func returnUserData()
    {
        let graphRequest : FBSDKGraphRequest = FBSDKGraphRequest(graphPath: user.valueForKey("facebookID") as! String, parameters: ["fields": "name, email, friends, picture, cover"])
        graphRequest.startWithCompletionHandler({ (connection, result, error) -> Void in
            
            if error != nil {
                // Process error
                print("Error: \(error.localizedDescription)")
            } else {
                //load name label and profileImage from user facebook data
                self.facebookID = result.valueForKey("id") as! String
                var name: String = result.valueForKey("name") as! String
                self.nameLabel.text = name
                let pictureURL: NSURL = NSURL(string: "https://graph.facebook.com/\(self.facebookID)/picture?type=large&return_ssl_resources=1")!
                let data = NSData(contentsOfURL: pictureURL)
                self.profileImage.image = UIImage(data: data!)
            }
        })
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //if table view is journal table view
        if tableView == self.tableView{
            return journal.count
        } else {
            return myrecipes.count
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        //if table view is journal table view
        if tableView == self.tableView{
            let journalCell = tableView.dequeueReusableCellWithIdentifier("JournalCell", forIndexPath: indexPath) as! JournalCell
            let journalItem = journal[indexPath.row]
            
            journalCell.journalItem = journalItem
            //In JournalCell class, there is a didSet for the journalItem that will populate all the labels and images
            return journalCell
        } else {
            let recipeCell = tableView.dequeueReusableCellWithIdentifier("MyRecipeCell", forIndexPath: indexPath) as! MyRecipeCell
            let recipe = myrecipes[indexPath.row]
            recipeCell.recipe = recipe
            //In MyRecipeCell class, there is a didSet for the journalItem that will populate all the labels and images
            return recipeCell
        }
    }
    
    @IBAction func indexChanged(sender: AnyObject) {
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            tableView.hidden = true
            tableView2.hidden = false
        case 1:
            tableView.hidden = false
            tableView2.hidden = true
        default:
            break;
        }
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "DetailSegueFromJournal" {
            let cell = sender as! JournalCell
            let recipeForCell = cell.recipeForCell
            
            let detailsViewController = segue.destinationViewController as! DetailsViewController
            detailsViewController.recipe = recipeForCell
        } else if segue.identifier == "MyRecipeSegue" {
            let cell = sender as! MyRecipeCell
            let recipe = cell.recipe
            
            let detailsViewController = segue.destinationViewController as! DetailsViewController
            detailsViewController.recipe = recipe
        }
    }
    
}