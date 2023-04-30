//
//  ChatRoom.swift
//  ChatWithMe!
//
//  Created by Mohamed Hadwa on 04/01/2023.
//

import Foundation
import FirebaseFirestoreSwift


struct ChatRoom :Codable {
    var id = ""
    var chatRoomId = ""
    var senderId = ""
    var senderName = ""
    var reciverId = ""
    var reciverName = ""
    @ServerTimestamp var date = Date()
    var memberIds = [""]
    var lastMessage = ""
    var unreadCounter : Int
    var avatarLink = ""
}
