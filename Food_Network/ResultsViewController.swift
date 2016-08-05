//
//  ResultsViewController.swift
//  Food_Network
//
//  Created by Grace Kotick on 7/15/16.
//

import UIKit
import DGElasticPullToRefresh

class ResultsViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    @IBOutlet weak var collectionView: UICollectionView!
    var ingredientNamesChosen: [String]?
    var recipes:[PFObject]?
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.dataSource = self
        collectionView.delegate = self
        self.collectionView.backgroundColor = UIColor.whiteColor();
        
        refreshCollectionViewData()
        
        /* Here is where pull to refresh animation code begins */
        let loadingView = DGElasticPullToRefreshLoadingViewCircle()
        //Set color of loading view circle
        loadingView.tintColor = UIColor.darkGrayColor()
        collectionView.dg_addPullToRefreshWithActionHandler({ [weak self] () -> Void in
            self!.refreshCollectionViewData()
            self?.collectionView.dg_stopLoading()
            }, loadingView: loadingView)
        collectionView.dg_setPullToRefreshFillColor(UIColor(red: 132/255.0, green: 115/255.0, blue: 180/255.0, alpha: 1.0))
        collectionView.dg_setPullToRefreshBackgroundColor(collectionView.backgroundColor!)
        /* Here is where the pull to refresh animation code ends. */
    }
    
    // This code removes pull to refresh on view controller deinit so no error is thrown when navigating to other view controllers
    deinit {
        collectionView.dg_removePullToRefresh()
    }
    
    func refreshCollectionViewData() {
        Recipe.filterByIngredients(ingredientNamesChosen!, success: { (filteredRecipes: [PFObject]) in
            self.recipes = Recipe.filteredRecipes
            self.collectionView.reloadData()
        }) {
            print("Call to filter recipes by ingredients failed. ")
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let recipes = recipes {
            return recipes.count
        } else{
            return 0
        }
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("RecipeCell", forIndexPath: indexPath) as! RecipeCollectionViewCell
        let recipe = recipes![indexPath.row]
        cell.recipe = recipe
        return cell
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "DetailSegue"{
            let cell = sender as! UICollectionViewCell
            let indexPath = collectionView.indexPathForCell(cell)
            let recipe = recipes![indexPath!.row]
            let detailsViewController = segue.destinationViewController as! DetailsViewController
            detailsViewController.recipe = recipe
        }
    }
    
}