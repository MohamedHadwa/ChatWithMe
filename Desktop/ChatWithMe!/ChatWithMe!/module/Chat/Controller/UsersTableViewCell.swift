//
//  UsersTableViewCell.swift
//  ChatWithMe!
//
//  Created by Mohamed Hadwa on 04/01/2023.
//

import UIKit

class UsersTableViewCell: UITableViewCell {
    // MARK: - IBOUTLET.
    
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var userNameLbl: UILabel!
    @IBOutlet weak var userStatusLbl: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    func configureCell (user:User){
        userNameLbl.text = user.userName
        userStatusLbl.text = user.status
        if user.avtarLink != ""{
            FileStorage.downloadImage(imgUrl: user.avtarLink) { (avatarImage) in
                self.userImage.image = avatarImage?.circleMasked
            }
        }else{
            self.userImage.image = UIImage(named: "Ellipse 3")
        }
        
    }

}
