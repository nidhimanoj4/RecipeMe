//
//  JournalCell.swift
//  Food_Network
//
//  Created by Nidhi Manoj on 7/19/16.

import UIKit

class JournalCell: UITableViewCell {
    @IBOutlet weak var recipeTitle: UILabel!
    @IBOutlet weak var recipeImageView: PFImageView!
    @IBOutlet weak var commentLabel: UILabel!
    
    @IBOutlet weak var successImage: UIImageView!
    @IBOutlet weak var okayimage: UIImageView!
    @IBOutlet weak var failImage: UIImageView!
    var recipeForCell = PFObject(className: "Recipe")

    
    var journalItem : NSDictionary? {
        didSet {
            let recipeID = journalItem!["recipeID"] as! String
            let rating = journalItem!["rating"] as! String
            let comment = journalItem!["comment"] as! String
            
            commentLabel.text = comment
            commentLabel.sizeToFit()
            //Depending on the rating, show a success,okay, or fail message to indicate how the recipe turned out
            successImage.hidden = true
            okayimage.hidden = true
            failImage.hidden = true
            if rating == "success"{
                successImage.hidden = false
            } else if rating == "okay"{
                okayimage.hidden = false
            } else {
                failImage.hidden = false
            }
            
            let query = PFQuery(className: "Recipe")
            do {
                //Get the recipe with the given recipeID, then set the title and image
                if let recipe = try query.getObjectWithId(recipeID) as? PFObject {
                    recipeForCell = recipe
                    let recipeTitleValue = recipe[RecipeParams.title.rawValue] as! String
                    self.recipeTitle.text = recipeTitleValue

                    /* To be dicussed: Recipe images do not show up. The loadInBackground prints a message of an
                     * unacceptable Response Code 404. Not sure how to fix it since the recipe and title are
                     * correct, a PFFile exists, but the loadInBackground fails. Images are not nil
                     * because they appear in ResultsViewController
                     */
                    //The recipe's image is a PFFile so make the imageView in the storyboard a PFImageView
                    let fileOfRecipeImage = recipe[RecipeParams.image.rawValue] as! PFFile
                    self.recipeImageView.file = fileOfRecipeImage
                    self.recipeImageView.loadInBackground()
                }
            } catch {
                print("error from new query attempt")
            }
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
