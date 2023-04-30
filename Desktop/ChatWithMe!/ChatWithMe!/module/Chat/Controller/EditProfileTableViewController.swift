//
//  EditProfileTableViewController.swift
//  ChatWithMe!
//
//  Created by Mohamed Hadwa on 01/01/2023.
//

import UIKit
import Gallery
import ProgressHUD
class EditProfileTableViewController: UITableViewController, UITextFieldDelegate {

   
    // MARK: - IBOutlets.
    @IBOutlet weak var imageEdit: UIImageView!
    @IBOutlet weak var userNameTxt: UITextField!
    @IBOutlet weak var infoLbl: UILabel!
    @IBOutlet weak var statusLbl: UILabel!
    // MARK: - Private Variables.
    var gallery : GalleryController!
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        tableView.tableFooterView = UIView()
        showUserInfo()
        configureTextFiled()
        
    }
    // MARK: - IBActions.
    
    @IBAction func editBtn(_ sender: Any) {
        showImageGallery()
    }
    
    // MARK: - Private Functions.
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor(named: "ColorTableView")
        return headerView
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 0 && section == 1 ? 0.0: 10.0
        
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return section == 0 ? 0.0 : 0.0
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 2 && indexPath.row == 0 {
            performSegue(withIdentifier: "status", sender: self)
        }
    }
    // MARK: - show informetion of user ib edit profile .
        private func showUserInfo(){
        if let user = User.currentUser {
            userNameTxt.text = user.userName
            statusLbl.text = user.status
            if user.avtarLink != ""{
                FileStorage.downloadImage(imgUrl: user.avtarLink) { (avatarImage) in
                    self.imageEdit.image = avatarImage?.circleMasked
                }
            }
        }
    }
    
    // MARK: - Configure Textfiled.
    private func configureTextFiled(){
        userNameTxt.delegate = self
        userNameTxt.clearButtonMode = .whileEditing
    }
    
    // MARK: - Text feild delegate func .
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == userNameTxt{
            if textField.text != "" {
                if var user = User.currentUser {
                    user.userName = textField.text!
                    saveUserLocally(user)
                    FUserListener.shared.saveUserToFirestore(user)
                }
            }
            textField.resignFirstResponder()
            return false
        }
        return true
    }
    // MARK: - Show Image in Gallery Func.
    func showImageGallery (){
        self.gallery = GalleryController()
        self.gallery.delegate = self
        Config.tabsToShow = [.cameraTab , .imageTab]
        Config.Camera .imageLimit = 1
        Config .initialTab = .imageTab
        self.present(gallery, animated: true , completion: nil)
            
        
    }
    // MARK: - Uploud Avatar image to Firestore.
    func uploudAvatarImage (_ image :UIImage){
        let fileDirectory = "Avatars/ "+"_\(User.currentId)"+".jpg"
        FileStorage.uploudImage(image, directory: fileDirectory) { (avatarLink) in
            if var user = User.currentUser{
                user.avtarLink = avatarLink ?? ""
                saveUserLocally(user)
                FUserListener.shared.saveUserToFirestore(user)
            }
            // TODO: - save user locally
            FileStorage.saveFileLocally(fileData: image.jpegData(compressionQuality: 0.5)!  as NSData, fileName: User.currentId)
        }
         
    }


}
extension EditProfileTableViewController :GalleryControllerDelegate{
    func galleryController(_ controller: Gallery.GalleryController, didSelectImages images: [Gallery.Image]) {
        if images.count > 0 {
            images.first!.resolve {(avatarImage) in
                if avatarImage != nil {
                    self.uploudAvatarImage (avatarImage!)
                    self.imageEdit.image = avatarImage
                    
                }else{
                    ProgressHUD.showError("could not select image")
                }
            }
        }
        
        
        controller.dismiss(animated: true , completion: nil)
    }
    
    func galleryController(_ controller: Gallery.GalleryController, didSelectVideo video: Gallery.Video) {
        controller.dismiss(animated: true , completion: nil)
    }
    
    func galleryController(_ controller: Gallery.GalleryController, requestLightbox images: [Gallery.Image]) {
        controller.dismiss(animated: true , completion: nil)
    }
    
    func galleryControllerDidCancel(_ controller: Gallery.GalleryController) {
        controller.dismiss(animated: true , completion: nil)
    }
    
    
}

