//
//  ChatTableViewCell.swift
//  ChatWithMe!
//
//  Created by Mohamed Hadwa on 04/01/2023.
//

import UIKit

class ChatTableViewCell: UITableViewCell {
    // MARK: - IBOUTLETS.

 @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var userNameLbl: UILabel!
    @IBOutlet weak var messagesLbl: UILabel!
    @IBOutlet weak var uiViewCounter: UIView!
    @IBOutlet weak var dateLbl: UILabel!
    @IBOutlet weak var couiterLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        uiViewCounter.layer.cornerRadius = uiViewCounter.frame.width/2
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    func configure(chatRoom:ChatRoom){
        userNameLbl.text = chatRoom.reciverName
        //userNameLbl.minimumScaleFactor = 0.9
        
        messagesLbl.text = chatRoom.lastMessage
       // messagesLbl.minimumScaleFactor = 0.9
        if chatRoom.unreadCounter != 0 {
            self.couiterLbl.text = "\(chatRoom.unreadCounter)"
            self.uiViewCounter.isHidden = false
            
        }else{
            self.uiViewCounter.isHidden = true
        }
        if chatRoom.avatarLink != ""{
            FileStorage.downloadImage(imgUrl: chatRoom.avatarLink) { (avatarImage) in
                self.userImage.image = avatarImage?.circleMasked
            }
        }else{
            self.userImage.image = UIImage(named: "Ellipse 3")
        }
        dateLbl.text =  timeElapsed(chatRoom.date ?? Date())
        
    }

}
