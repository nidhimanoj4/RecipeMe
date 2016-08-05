//
//  MyRecipeCell.swift
//  Food_Network
//
//  Created by Grace Kotick on 7/25/16.
//  Copyright © 2016 Facebook. All rights reserved.
//

import UIKit

class MyRecipeCell: UITableViewCell {

    @IBOutlet weak var commentLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var recipeImage: PFImageView!
    var recipe: PFObject? {
        didSet {
            let recipeTitleValue = recipe![RecipeParams.title.rawValue] as! String
            self.titleLabel.text = recipeTitleValue
            let fileOfRecipeImage = recipe![RecipeParams.image.rawValue] as! PFFile
            self.recipeImage.file = fileOfRecipeImage
            self.recipeImage.loadInBackground()
            //uncomment when recipe has comment stored
            let comment = recipe![RecipeParams.comments.rawValue] as! String
            commentLabel.text = comment
            commentLabel.sizeToFit()
            
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
