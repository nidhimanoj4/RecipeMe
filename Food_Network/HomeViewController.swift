//
//  HomeViewController.swift
//  Food_Network
//
//  Created by Grace Kotick on 7/6/16.
//

import UIKit
import Alamofire

class HomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var ingredientsChosenListLabel: UILabel!
    var ingredients: [Ingredient]! = []
    var numberOfIngredientsToPresent: Int = 20
    var ingredientNamesChosen: [String]! = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        searchBar.delegate = self
        // Do any additional setup after loading the view.
        let me: PFUser = PFUser.currentUser()!
        ingredientNamesChosen = me["ingredientsNamesChosen"] as! [String]
        
        refreshIngredientsChosenList() //Refresh the list of ingredients
        refreshTableViewData()
        ingredientsChosenListLabel.sizeToFit()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /* Function: refreshTableViewData
     * This function implements an aynchronous network request to get
     * an array of ingredients from the Food API and set the ingredients
     * instance array of the ViewController. This code uses Alamofire, 
     * which is a HTTP networking library written in Swift.
     * https://cocoapods.org/pods/Alamofire
     */
    func refreshTableViewData() {
        /* To do: After implementing search bar, set the searchBarString
         * to be self.searchBar.text!. For now, the searchBarString has 
         * been set to a string "appl". 
         */
        var searchBarString = self.searchBar.text!
        if searchBarString == "" {
            searchBarString = "a"
        }
        searchBarString = searchBarString.stringByReplacingOccurrencesOfString(" ", withString: "+", options: NSStringCompareOptions.LiteralSearch, range: nil)
        
        //The X-Mashape-Key is the production key from Student Mashape account
        let headers = [
            "X-Mashape-Key": "atC8uqnrUWmsh2TfdRv5Zyh1qqNxp1CQd1RjsnaAA9qaEkDMe6", "Accept": "application/json"
        ]
        
        /* Alamofire Network request:
         * Parameters: 
         *      -numberOfIngredientsToPresent: the number of ingredients
         *          to return between [1,100]
         *      -searchBarString: the query - partial or full ingredient name
         * Calling validate before a response handler causes an error to be 
         * generated if the response had an unacceptable status code (200-299)
         * or if response's Content-Type header does not match the Accept header.
         */
        Alamofire.request(.GET, "https://spoonacular-recipe-food-nutrition-v1.p.mashape.com/food/ingredients/autocomplete?metaInformation=true&number=\(numberOfIngredientsToPresent)&query=\(searchBarString)",  headers: headers)
            .validate()
            .responseJSON { response in
                //Work with the resulting response from the network request
                switch response.result {
                case .Success:
                    print("Search Ingredient Request Successful")
                    
                    let arrayIngredientsData = response.result.value!
                    print("Search ingredient data: \(arrayIngredientsData)")
                    
                    //Get the ingredientsDictionary which is the result from the request
                    let ingredientsDictionaries = arrayIngredientsData as! [NSDictionary]
                    //Fill the ingredients variable (array of Ingredient) using the ingredientsDictionary variable (array of NSDictionary)
                    self.ingredients = Ingredient.getIngredientsFromArrayDictionaries(ingredientsDictionaries)
                    
                    //Reload the table view data
                    self.tableView.reloadData()
                case .Failure(let error):
                    print(error)
                }
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("numberOfRows")
        print(ingredients!.count)
        return (ingredients != nil) ? ingredients!.count : 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        print("cell")
        let ingredientCell = tableView.dequeueReusableCellWithIdentifier("IngredientCell", forIndexPath: indexPath) as! IngredientCell
        let ingredient = ingredients[indexPath.row]
        
        ingredientCell.ingredient = ingredient
        //In the IngredientCell, there is a didSet for the ingredient variable that will set all the cell's labels and images using the ingredient that we have given
        return ingredientCell
    }
    
    /* Function: textDidChange
     * Update the displayed ingredients search results when search bar 
     * text changes (typeahead).
     */
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        // When there is no text, do nothing - ingredients array is set in viewDidLoad()
        if !(searchBar.text!.isEmpty) {
            //When user enters text in the search box, make a network request
            refreshTableViewData()
        }
    }
    
    //quit keyboard when touch  outside of searchbar
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.searchBar.endEditing(true)
    }
    
    /* Function: refreshIngredientsChosenList
     * Update the ingredients list label on this view controller 
     * using the current ingredientNamesChosen array.
     */
    func refreshIngredientsChosenList() {
        //Get the String version of the array ingredientsChosen
        let stringOfIngredientNamesChosen = getStringFromArrayOfIngredientNames()
        ingredientsChosenListLabel.text = stringOfIngredientNamesChosen
        ingredientsChosenListLabel.sizeToFit()
    }
    
    /* Function: Use the ingredientsChosen array of ingredient names to make
     * a string of all the ingredients that were chosen
     */
    func getStringFromArrayOfIngredientNames() -> String {
        return (ingredientNamesChosen as NSArray).componentsJoinedByString(",")
    }

    /* When the +/- button is clicked, this function adds/removes the 
     * ingredient from the ingredientNamesChosen array. 
     */
    @IBAction func onAddRemoveIngredientButton(sender: AnyObject) {
        let addButton = sender as! UIButton
        /* Accessing ingredientCell the following way relies on the fact that
         * there are only two superviews on top. Apple has changed this in
         * the past so it's not super reliable in the future. Make sure to check
         * this before use.
         */
        let ingredientCell = (addButton.superview)!.superview as! IngredientCell
        let indexPath = tableView.indexPathForCell(ingredientCell)
        let ingredient = ingredients[indexPath!.row]
        let ingredientNameInCell = ingredient.name as! String

        if ingredient.chosen == false {
            //Add the ingredient to ingredientNamesChosen array
            ingredientNamesChosen.append(ingredientNameInCell)
            ingredient.chosen = true
            addButton.selected = true  //default is "+", selected is "-"
        } else {
            //Remove the ingredient from ingredientNamesChosen array
            for ingredientInChosenArray in ingredientNamesChosen {
                if (ingredientInChosenArray == ingredientNameInCell) {
                    let indexOfIngredient = ingredientNamesChosen.indexOf(ingredientInChosenArray)
                    ingredientNamesChosen.removeAtIndex(indexOfIngredient!)
                }
            }
            ingredient.chosen = false
            addButton.selected = false  //default is "+", selected is "-"
        }

        //Refresh the list of ingredients at the top of the view controller
        refreshIngredientsChosenList()
        
        // Save this list to the current user's ingredientsNamesChosen array
        let me: PFUser = PFUser.currentUser()!
        me["ingredientsNamesChosen"] = ingredientNamesChosen
        me.saveInBackground()
    }
    
    //function to hideKeyboard when click search
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    // MARK: - Navigation
//
//    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
 
        let resultsViewController = segue.destinationViewController as! ResultsViewController
        resultsViewController.ingredientNamesChosen = self.ingredientNamesChosen
    }
    
}