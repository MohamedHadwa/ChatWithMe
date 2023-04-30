//
//  ProfileTableViewController.swift
//  ChatWithMe!
//
//  Created by Mohamed Hadwa on 04/01/2023.
//

import UIKit

class ProfileTableViewController: UITableViewController {

    // MARK: - IBOutlets.
    
    @IBOutlet weak var userImageAvatar: UIImageView!
    @IBOutlet weak var userNameForUser: UILabel!
    @IBOutlet weak var statusForUser: UILabel!
    // MARK: - Private Variables.
    var user : User?
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        updateUI()
        tableView.tableFooterView = UIView()
        navigationItem.largeTitleDisplayMode = .never
        
    }
    // MARK: - IBActions.
    
    
    // MARK: - Private Functions.
    private func updateUI(){
        if user != nil {
            self.title = user?.userName

            userNameForUser.text = user!.userName.uppercased()
            statusForUser.text = user!.status
            if user!.avtarLink != ""{
                FileStorage.downloadImage(imgUrl: user!.avtarLink) {  (avatarImage) in
                    self.userImageAvatar.image = avatarImage?.circleMasked
                }
                
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor(named: "ColorTableView")
        return headerView
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 0 ? 0.0: 5.0
        
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section  == 1 {
             print("start Chating...")
            let chatId = startChat(sender: User.currentUser!, reciver: user!)
            let privateMessageView = MessageViewController(chatId: chatId, recipientId: user!.id, recipientName: user!.userName)
            navigationController?.pushViewController(privateMessageView, animated: true)
        }
    }
    
    
    
}
//
//// MARK: - <#UI.....#> Delegate & DataSource.
//
//extension <#UIviewController#> {
//
//
//}
//
//// MARK: - APi.
//
//extension <#UIviewController#> {
//
//
//
//}



