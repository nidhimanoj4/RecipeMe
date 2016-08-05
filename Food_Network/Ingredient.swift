//
//  Ingredient.swift
//  Food_Network
//
//  Created by Nidhi Manoj on 7/8/16.

import UIKit

class Ingredient: NSObject {
    var name: NSString?
    var ingredientPictureString: String?
    var ingredientDictionary: NSDictionary?
    var chosen: Bool = false
    
    init(dictionary: NSDictionary) {
        ingredientDictionary = dictionary
        name = dictionary["name"] as? String //Example: "apple"
        ingredientPictureString = dictionary["image"] as? String //Example: "apple.png"

        /* This accesses the ingredients that the user has chosen and
         * updates this ingredient's chosen field appropriately
         */
        let me: PFUser = PFUser.currentUser()!
        let ingredientsNamesChosenArray = me["ingredientsNamesChosen"] as! [String]
        
        for ingredientName in ingredientsNamesChosenArray {
            if ingredientName == name {
                chosen = true
            }
        }
        
        /* To do: Set the image variable (ingredientPicture) given the
           ingredientPictureString. Is it ideal to make it an NSURL or
           is something else better?
        */
    }
    
    /* This function converts the array of NSDictionary from the network request to an array of Ingredient
     * Parameters: ingredientsDictionaries which is an array of NSDictionary
     * Return: an array of Ingredient
     */
    class func getIngredientsFromArrayDictionaries(ingredientsDictionaries: [NSDictionary]) -> [Ingredient] {
        var ingredientsArray = [Ingredient]()   //Initialize an array of Ingredient
        
        for dictionary in ingredientsDictionaries {
            let ingredient = Ingredient(dictionary: dictionary)
            ingredientsArray.append(ingredient)
        }
        return ingredientsArray
    }

}