//
//  SearchFriendsViewController.swift
//  Food_Network
//
//  Created by Kenya Gordon on 7/27/16.
//  Copyright © 2016 Facebook. All rights reserved.
//

import UIKit

class SearchFriendsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {

    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    var users = [PFUser]()
    var filteredUsers = [PFUser]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        searchBar.delegate = self
        self.loadData()
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(animated: Bool) {
        searchBar.resignFirstResponder()
        self.loadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func loadData(){
        
        var query = PFQuery(className: "_User")
        query.orderByDescending("_created_at")
        query.findObjectsInBackgroundWithBlock{ (users: [PFObject]?, error: NSError?) -> Void in
            if error == nil{
                self.users = (users as? [PFUser])!
                self.filteredUsers = self.users
                self.tableView.reloadData()
                print(self.users)
            }else{
                print(error)
            }
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
            return self.filteredUsers.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        let cell = tableView.dequeueReusableCellWithIdentifier("FriendsViewCell", forIndexPath: indexPath) as! FriendsViewCell
        let user = filteredUsers [indexPath.row]
        cell.friend = user
        return cell
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        // When there is no text, filteredData is the same as the original data
        
        if searchText.isEmpty {
            filteredUsers = users
        } else {
            // The user has entered text into the search box
            // Use the filter method to iterate over all items in the data array
            // For each item, return true if the item should be included and false if the
            // item should NOT be included
            filteredUsers = users.filter({(user: PFUser) -> Bool in
                // If dataItem matches the searchText, return true to include it
                if (user["name"] as? String)!.rangeOfString(searchText, options: .CaseInsensitiveSearch) != nil {
                    return true
                } else {
                    return false
                }
            })
        }
        tableView.reloadData()
    }
    
    //segue to view profile
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if (segue.identifier == "userProfileSegue") {
            let cell = sender as! UITableViewCell
            let indexPath = tableView.indexPathForCell(cell)
            let user = filteredUsers[indexPath!.row]
            let friendsProfileViewController = segue.destinationViewController as! ProfileViewController
            friendsProfileViewController.user = user
        }
    }
  
    //function to hideKeyboard when click search
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
