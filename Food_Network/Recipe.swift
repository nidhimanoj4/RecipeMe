//
//  Recipe.swift
//  Food_Network
//
//  Created by Grace Kotick on 7/8/16.
//  Copyright © 2016 Facebook. All rights reserved.
//

import UIKit
import Parse

class Recipe: NSObject {
    static var cutoffForIngredientsPresentForRecipe = 0.6
    static var recipesQueried = [PFObject]()
    static var filteredRecipes: [PFObject] = []
    /**
     
     create a PFObject of type Recipe
     
     @param :
     image: picture of the completed recipe
     title: name of the dish
     ingredients: array of the ingredients in the recipe
     date: date the recipe was posted
     instructions: string of steps to make the dish
     
     @return: none
     
     **/
    class func postRecipe(image: UIImage?, withTitle title: String?, withIngredients ingredients: [String]?, withInstructions instructions: String?, withComments comments: String?, withCompletion completion: PFBooleanResultBlock?) {
        // Create Parse object PFObject
        let recipe = PFObject(className: "Recipe")
        // Add relevant fields to the object
        recipe[RecipeParams.image.rawValue] = getPFFileFromImage(image) // PFFile column type
        recipe[RecipeParams.title.rawValue] = title
        recipe[RecipeParams.author.rawValue] = PFUser.currentUser() // Pointer column type that points to PFUser
        recipe[RecipeParams.ingredients.rawValue] = ingredients
        recipe[RecipeParams.instructions.rawValue] = instructions
        recipe[RecipeParams.likesCount.rawValue] = 0
        recipe[RecipeParams.commentsCount.rawValue] = 0
        recipe[RecipeParams.comments.rawValue] = comments
        

        //Save the recipe in Parse
        recipe.saveInBackgroundWithBlock({(success: Bool, error: NSError?) in
            completion!(success, error)
            if success {
                let user: PFUser = PFUser.currentUser()!
                let currentRecipesCount = user["my_recipesCount"] as! Int
                user["my_recipesCount"] = currentRecipesCount + 1
                user.saveInBackground()
            } else {
                // There was a problem, check error.description
                print(error?.localizedDescription)
            }
        })
    }

    //This function will be used to get the file for an image so that we are able to store it
    class func getPFFileFromImage(image: UIImage?) -> PFFile? {
        // check if image is not nil
        if let image = image {
            // get image data and check if that is not nil
            if let imageData = UIImagePNGRepresentation(image) {
                return PFFile(name: "image.png", data: imageData)
            }
        }
        return nil
    }
    
    //This function is used to resize the image that the user chooses
    //Code snippet was taken from CodePath training when creating instagram
    class func resize(image: UIImage, newSize: CGSize) -> UIImage {
        let resizeImageView = UIImageView(frame: CGRectMake(0, 0, newSize.width, newSize.height))
        resizeImageView.contentMode = UIViewContentMode.ScaleAspectFill
        resizeImageView.image = image
        
        UIGraphicsBeginImageContext(resizeImageView.frame.size)
        resizeImageView.layer.renderInContext(UIGraphicsGetCurrentContext()!)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }
    
    /* Function: queryRecipesFromParse
     * Queries all recipes in Parse and saves the resulting array of
     * recipe in the static variable.
     */
    class func queryRecipesFromParse(success: ([PFObject]) -> (), failure: () -> ()) {
        //Construct a PFQuery
        let query = PFQuery(className: "Recipe")
        //Set up guidelines for the query
        query.orderByDescending("createdAt")
        query.includeKey("author") //Include because author is a PFUser object within the PFObject recipe
        
        //Fetch data asynchronously
        query.findObjectsInBackgroundWithBlock { (recipesArray: [PFObject]?, error: NSError?) in
            if let recipesArray = recipesArray {
                //Save the fetched data from the query to an array of recipes
                recipesQueried = recipesArray
                success(recipesQueried)
            } else {
                print("Recipes query returned error: \(error!.localizedDescription)")
                failure()
            }
        }
    }
    
    /* Function: filterByIngredients
     * Calls a query to get all the recipes in Parse and returns a
     * filtered array of recipes. A recipe is included in the filtered
     * array if user has a (static variable) cutoff percentage of the
     * recipe's ingredients. The filtered array is sorted with the recipe
     * with the minimum missing ingredients appearing first in the array.
     */
    class func filterByIngredients(ingredientsNamesChosenArray : [String], success: ([PFObject]) -> (), failure: () -> ()) {
        filteredRecipes = [PFObject]()
        let setWeHave: Set<String> = Set(ingredientsNamesChosenArray)
        
        queryRecipesFromParse({ (recipesQueried: [PFObject]) in
            for recipe in recipesQueried {
                //Calculate the percentage of the recipe's ingredients that user has
                let percentageIngredientsPresent : Double = Recipe.getPercentIngredPresentForRecipe(recipe, setWeHave: setWeHave)
                if percentageIngredientsPresent >= cutoffForIngredientsPresentForRecipe {
                    filteredRecipes.append(recipe)
                }
            }
            //Sort the filtered array of recipes by minimum missing ingredients
            filteredRecipes.sortInPlace({ (recipe1: PFObject, recipe2: PFObject) -> Bool in
                let percentIngredPresentRecipe1 = getPercentIngredPresentForRecipe(recipe1, setWeHave: setWeHave).roundToPlaces(2)
                let percentIngredPresentRecipe2 = getPercentIngredPresentForRecipe(recipe2, setWeHave: setWeHave).roundToPlaces(2)
                
                //If both recipes have the same percentage of ingredients to 2 decimal places,
                // then the one with longer/more complete instructions should come first.
                if percentIngredPresentRecipe1 == percentIngredPresentRecipe2 {
                    let recipe1Instructions = recipe1[RecipeParams.instructions.rawValue] as! String
                    let recipe2Instructions = recipe2[RecipeParams.instructions.rawValue] as! String
                    return recipe1Instructions.characters.count > recipe2Instructions.characters.count
                }
                
                return percentIngredPresentRecipe1 > percentIngredPresentRecipe2
            })
            success(filteredRecipes)
        }) {
            print("Filtering recipes by ingredients failed. ")
            failure()
        }
    }
    
    /* Function: getPercentIngredPresentForRecipe
     * Calculates the percentage of the recipe's ingredients that the user has.
     * The function implementation involves finding the intersecting set
     * of ingredients that we have and that the recipe requires.
     */
    class func getPercentIngredPresentForRecipe (recipe : PFObject, setWeHave : Set<String>) -> Double {
        let ingredientsInRecipeArray = recipe[RecipeParams.ingredients.rawValue] as! [String]
        let setInRecipe: Set<String> = Set(ingredientsInRecipeArray)
        
        //Get the set of ingredients that we have and that are also in the recipe
        let intersectIngredients = setWeHave.intersect(setInRecipe)
        
        //Calculate percentage of the recipe's ingredients that the user has
        return ( Double(intersectIngredients.count) / Double(setInRecipe.count) )
    }
}

extension Double {
    /// Rounds the double to decimal places value
    func roundToPlaces(places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return round(self * divisor) / divisor
    }
}