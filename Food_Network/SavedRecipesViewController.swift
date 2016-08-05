//
//  SavedRecipesViewController.swift
//  Food_Network
//
//  Created by Grace Kotick on 7/22/16.
//

import UIKit

class SavedRecipesViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    @IBOutlet weak var collectionView: UICollectionView!
    var savedRecipesStrings: [String]!
    var user: PFUser?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.dataSource = self
        collectionView.delegate = self
        user = PFUser.currentUser()
        savedRecipesStrings = user!["saved_recipes"] as! [String]
        collectionView.reloadData()
    }
    
    override func viewDidAppear(animated: Bool) {
        savedRecipesStrings = user!["saved_recipes"] as! [String]
        collectionView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return (savedRecipesStrings != nil) ? savedRecipesStrings!.count : 0
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("SavedCell", forIndexPath: indexPath) as! SavedCollectionViewCell
        let recipeID = savedRecipesStrings![indexPath.row]
        cell.recipeID = recipeID
        cell.index = indexPath.row
        return cell
    }
    
    @IBAction func removeSavedRecipe(sender: AnyObject) {
        //function to unsave a previously saved recipe by clicking a button in the cell
        /* Accessing ingredientCell the following way relies on the fact that
         * there are only two superviews on top. Apple has changed this in
         * the past so it's not super reliable in the future. Make sure to check
         * this before use.
         */
        let removeButton = sender as! UIButton
        let cell = removeButton.superview!.superview! as! SavedCollectionViewCell
        let indexPath = collectionView.indexPathForCell(cell)
        savedRecipesStrings?.removeAtIndex((indexPath?.row)!)
        user!["saved_recipes"] = savedRecipesStrings as? [String]!
        user?.saveInBackground()
        collectionView?.reloadData()
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        //segue to detail view of clicked on recipe
        let cell = sender as! SavedCollectionViewCell
        let indexPath = collectionView.indexPathForCell(cell)
        let recipeID = savedRecipesStrings![indexPath!.row]
        var recipeForCell: PFObject?
        let query = PFQuery(className: "Recipe")
        query.includeKey("author")
        do {
            //Get the recipe with the given recipeID, then set the title and image
            if let recipe = try query.getObjectWithId(recipeID) as? PFObject {
                recipeForCell = recipe
            }
        } catch {
            print("error from new query attempt")
        }
        let detailsViewController = segue.destinationViewController as! DetailsViewController
        detailsViewController.recipe = recipeForCell
    }
 
}
