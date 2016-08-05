//
//  SavedCollectionViewCell.swift
//  Food_Network
//
//  Created by Grace Kotick on 7/25/16.
//

import UIKit

class SavedCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var imageView: PFImageView!
    @IBOutlet weak var title: UILabel!
    var index: Int?
    var recipeForCell = PFObject(className: "Recipe")
    
    var recipeID: String? {
        didSet{
            //query for recipe with recipeID
            let query = PFQuery(className: "Recipe")
            do {
                //Get the recipe with the given recipeID, then set the title and image
                if let recipe = try query.getObjectWithId(recipeID!) as? PFObject {
                    recipeForCell = recipe
                    let recipeTitleValue = recipe[RecipeParams.title.rawValue] as! String
                    self.title.text = recipeTitleValue
                    let fileOfRecipeImage = recipe[RecipeParams.image.rawValue] as! PFFile
                    self.imageView.file = fileOfRecipeImage
                    self.imageView.loadInBackground()
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

}
