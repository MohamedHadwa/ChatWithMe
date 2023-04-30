//
//  SettingsTableViewController.swift
//  ChatWithMe!
//
//  Created by Mohamed Hadwa on 01/01/2023.
//

import UIKit

class SettingsTableViewController: UITableViewController {
    
    
    // MARK: - IBOutlets.
    
    @IBOutlet weak var userImg: UIImageView!
    
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var userStatus: UILabel!
    @IBOutlet weak var appVersion: UILabel!
    // MARK: - Private Variables.
    
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        tableView.tableFooterView = UIView()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        showUserInfo()
    }
    // MARK: - IBActions.
    
    @IBAction func tellFriendPressed(_ sender: Any) {
        print("Tell my friend")
    }
    
    @IBAction func termsPressed(_ sender: Any) {
        print("terms")
    }
    
    @IBAction func logoutPreesed(_ sender: Any) {
        goToLogin()
    }
    // MARK: - Private Functions.
    // MARK: - tableView Funcs.
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 && indexPath.row == 0 {
            performSegue(withIdentifier: "EditProfileId", sender: self)
        }
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor(named: "ColorTableView")
        return headerView
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 0||section == 1 ? 0.0:10.0
    }
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footerView = UIView()
        footerView.backgroundColor = nil
        return footerView
    }
    override func tableView(_ tableView: UITableView, estimatedHeightForFooterInSection section: Int) -> CGFloat {
        return 0
    }
    
    
    // MARK: - Update Info for User.

    
    private func showUserInfo (){
        if let user = User.currentUser {
            userName.text = user.userName
            userStatus.text = user.status
            appVersion.text = "Applecation Version \(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "")"
            
            
            
            if user.avtarLink != "" {
                // TODO: - download and set avatar image .
                FileStorage.downloadImage(imgUrl: user.avtarLink) { (avatarLink) in
                    self.userImg.image = avatarLink?.circleMasked
                }
            }
            
        }
    }
    
    // MARK: - Go to login .
    private func goToLogin (){
        FUserListener.shared.logoutUser { error in
            if error == nil {
                self.returnToLogin()
            }
        }
    }
    
    // MARK: - Return to Login.

    private func returnToLogin (){
        let mainView = UIStoryboard(name: "Main", bundle: nil) .instantiateViewController(withIdentifier: "RegisterId" )as! UIViewController
        DispatchQueue.main.async {
            mainView.modalPresentationStyle = .fullScreen
            self.present(mainView, animated: true ,completion: nil)
        }
    }
    // MARK: - go to edit your profile .

    private func goToEditProfile (){
        let editView = UIStoryboard(name: "Chat", bundle: nil) .instantiateViewController(withIdentifier: "EditProfileId" )as! UITableViewController
            editView.modalPresentationStyle = .fullScreen
            self.present(editView, animated: true ,completion: nil)
    }
}


