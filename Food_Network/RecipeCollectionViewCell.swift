//
//  RecipeCollectionViewCell.swift
//  Food_Network
//
//  Created by Grace Kotick on 7/15/16.
//

import UIKit

class RecipeCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var titleView: UIView!
    @IBOutlet weak var likesCount: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var imageView: PFImageView!
    
    var recipe: PFObject?{
        didSet {
            let title = recipe![RecipeParams.title.rawValue] as! String
            titleLabel.text = title
            self.imageView.file = recipe![RecipeParams.image.rawValue] as? PFFile
            self.imageView.loadInBackground()
            self.likesCount.text = "     \(recipe?.valueForKey(RecipeParams.likesCount.rawValue) as! Int)"
            titleView.alpha = 0.5
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
}