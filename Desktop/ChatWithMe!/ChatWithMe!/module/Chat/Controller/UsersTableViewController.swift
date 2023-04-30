//
//  UsersTableViewController.swift
//  ChatWithMe!
//
//  Created by Mohamed Hadwa on 04/01/2023.
//

import UIKit

class UsersTableViewController: UITableViewController {
    
    

    var allUsers :[User] = []
    var filteredUser  :[User] = []
    let searchController = UISearchController(searchResultsController: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView()
       // allUsers = [User.currentUser!]
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = true
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search in Users"
        searchController.searchResultsUpdater = self
       // createDummyUsers()
        self.refreshControl = UIRefreshControl()
        self.tableView.refreshControl = self.refreshControl
        downloadUsers()

    }
    // MARK: - uiscrollview delegate func.
    override func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if self.refreshControl!.isRefreshing{
            self.downloadUsers()
            self.refreshControl!.endRefreshing()
        }
    }


    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return searchController.isActive ?filteredUser.count :allUsers.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "usersCell", for: indexPath) as! UsersTableViewCell
        let user = searchController.isActive ? filteredUser[indexPath.row] : allUsers[indexPath.row]
        cell.configureCell(user: user)
        return cell
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
        
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let user = searchController.isActive ? filteredUser[indexPath.row] : allUsers[indexPath.row]
        showProfileUser(user)
    }
    // MARK: - download users from firestore.
    func downloadUsers (){
        FUserListener.shared.downloadAllUsersFromFirestore { (firestoreAllUsers) in
            self.allUsers = firestoreAllUsers
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
}
extension UsersTableViewController :UISearchResultsUpdating{
    func updateSearchResults(for searchController: UISearchController) {
        filteredUser = allUsers.filter({ (user) ->Bool in
            return user.userName.lowercased().contains(searchController.searchBar.text!.lowercased())
        })
        tableView.reloadData()
    }
    func showProfileUser(_ user:User){
        let profileView = UIStoryboard(name: "Chat", bundle: nil).instantiateViewController(withIdentifier: "profileView")as!ProfileTableViewController
        profileView.user = user
        navigationController?.pushViewController(profileView, animated: true)
        
    }
    
    
}
