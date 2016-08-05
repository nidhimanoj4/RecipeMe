//
//  IngredientCell.swift
//  Food_Network
//
//  Created by Nidhi Manoj on 7/8/16.

import UIKit

class IngredientCell: UITableViewCell {
    @IBOutlet weak var ingredientName: UILabel!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var ingredientImage: UIImageView!
    var ingredient: Ingredient? {
        didSet {
            //When the ingredient variable of the IngredientCell is set, 
            //the name and image for that cell is set here
            print("Ingredient name: \(ingredient!.name!) and chosen: \(ingredient!.chosen)")
            ingredientName.text = String(ingredient!.name!) ?? ""
            //addButton has two states: default "+" and selected "-"
            //This sets the button state appropriately depending on whether the ingredient was chosen already
            addButton.selected = ingredient!.chosen == true
            //add images
            let ingredientString = "https://spoonacular.com/cdn/ingredients_100x100/\(ingredient!.ingredientPictureString!)"
            let imageURL: NSURL = NSURL(string: ingredientString)!
            let request: NSURLRequest = NSURLRequest(URL: imageURL)
            NSURLConnection.sendAsynchronousRequest(
                request, queue: NSOperationQueue.mainQueue(),
                completionHandler: {(response: NSURLResponse?,data: NSData?,error: NSError?) -> Void in
                    if error == nil {
                        let image = UIImage(data: data!)
                        self.ingredientImage.image = image
                    } else {
                        print(error?.localizedDescription)
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