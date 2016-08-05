//
//  FoodApi.swift
//  Food_Network
//
//  Created by Kenya Gordon on 7/15/16.
//  Copyright © 2016 Facebook. All rights reserved.
//

import UIKit
import Alamofire
class FoodApi: NSObject {
    
    class func populate(ingredient: String){
        let updatedIngredient = ingredient.stringByReplacingOccurrencesOfString(" ", withString: "+", options: NSStringCompareOptions.LiteralSearch, range: nil)
        
        let headers = [
            "X-Mashape-Key": "atC8uqnrUWmsh2TfdRv5Zyh1qqNxp1CQd1RjsnaAA9qaEkDMe6", "Accept": "application/json"
        ]
        //Network request for find by ingredients
        Alamofire.request(.GET, "https://spoonacular-recipe-food-nutrition-v1.p.mashape.com/recipes/findByIngredients?fillIngredients=false&ingredients=\(updatedIngredient)&limitlicense=false&number=15&ranking=1", headers:headers).validate()
            .responseJSON{
                response in
                switch response.result {
                case .Success:
                    print("Find recipes request successful")
                    print(response.result.value)
                    let results = response.result.value
                    let recipeResults = results as! [NSDictionary]
                    for recipe in recipeResults{
                        let id = recipe["id"] as! Int
                        var recipeImage:String = recipe["image"] as! String
                        var imgURL: NSURL = NSURL(string: recipeImage)!
                        let request: NSURLRequest = NSURLRequest(URL: imgURL)
                        NSURLConnection.sendAsynchronousRequest(
                            request, queue: NSOperationQueue.mainQueue(),
                            completionHandler: {(response: NSURLResponse?,data: NSData?,error: NSError?) -> Void in
                                if error == nil {
                                    let imagetype = recipe["imageType"] as! String
                                    let title = recipe["title"] as! String
                                    //get image, imagetype, title
                                    //call a function that gets the recipe information and instructions
                                    getRecipeInformation(id, image: UIImage(data: data!)!, imagetype: imagetype, title: title)
                                }
                        })
                    }
                case.Failure(let error):
                    print(error)
                }
        }
    }
    
    class func  getRecipeInformation(id: Int, image: UIImage, imagetype : String, title : String){
        //create two requests and call recipe.postRecipe with new information
        var _ingredients: String? = ""
        var _instructions: String? = ""
        let string_id = "\(id)"
        let headers = [
            "X-Mashape-Key": "atC8uqnrUWmsh2TfdRv5Zyh1qqNxp1CQd1RjsnaAA9qaEkDMe6", "Accept": "application/json"
        ]
        
        Alamofire.request(.GET, "https://spoonacular-recipe-food-nutrition-v1.p.mashape.com/recipes/\(id)/information?includeNutrition=false", headers: headers).validate().responseJSON{ response in
            
            switch response.result {
            case.Success:
                print("Recipe information request successful")
                
                let recipeInformationResults = response.result.value
                let informationResults = recipeInformationResults as! NSDictionary
                let ingredients = informationResults.valueForKey("extendedIngredients") as! [NSDictionary]
                for i in 0...ingredients.count-1{
                    let ingredient = ingredients[i]
                    let originalString = ingredient["originalString"]
                    let name = ingredient["name"]
                    if i == 0{
                        _ingredients = _ingredients! + "\(name!)"
                    }
                    else{
                        _ingredients = _ingredients! + ",\(name!)"
                    }
                    _instructions = _instructions! + "\(originalString!)\n"
                }
                
                Alamofire.request(.GET, "https://spoonacular-recipe-food-nutrition-v1.p.mashape.com/recipes/\(id)/analyzedInstructions?stepBreakdown=true", headers: headers).validate().responseJSON{ response in
                    
                    switch response.result {
                    case.Success:
                        print("Recipe Instructions Request Successful")
                        
                        let analyzedInstructionsResults = response.result.value
                        let instructionsResults = analyzedInstructionsResults as! [NSDictionary]
                        for result in instructionsResults{
                            let name = (result["name"] as! String).uppercaseString
                            _instructions = _instructions! + "\(name)\n"
                            let steps = result["steps"] as! [NSDictionary]
                            for step in steps{
                                let number = step["number"]
                                let stepDescription = step["step"]
                                _instructions = _instructions! + "\(number!). \(stepDescription!)\n"
                            }
                        }
                        
                        let ingredientsArray = _ingredients!.componentsSeparatedByString(",")
                        
                        Recipe.postRecipe(image, withTitle: title, withIngredients: ingredientsArray, withInstructions: _instructions, withComments: "Great Recipe"){ (success: Bool, error: NSError?) in
                            if success {
                                print("Posted new recipe!")
                            } else {
                                print(error?.localizedDescription)
                            }
                        }
                        
                    case.Failure(let error):
                        print (error)
                    }
                    
                }
                
            case.Failure(let error):
                print(error)
                
            }
        }
        
    }
}