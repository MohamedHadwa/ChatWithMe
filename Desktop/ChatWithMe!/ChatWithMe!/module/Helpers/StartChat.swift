//
//  StartChat.swift
//  ChatWithMe!
//
//  Created by Mohamed Hadwa on 05/01/2023.
//

import Foundation
import Firebase

// MARK: - restart Chat if chat was exist.

func restartChat (chatroomId :String ,memberIds : [String] ){
    // MARK: - download users using memberIds.
    FUserListener.shared.downloadUsersFromFirestore(whithIds: memberIds) { (allUsers) in
        if allUsers.count > 0{
            creatChatRoom(chatRoomId: chatroomId, users: allUsers)
        }
    }
    
}





func startChat (sender:User ,reciver:User)->String{
    var chatRoomId = ""
    let value = sender.id .compare(reciver.id).rawValue
    chatRoomId = value < 0 ? (sender.id + reciver.id) : (reciver.id + sender.id)
    creatChatRoom(chatRoomId:chatRoomId ,users:[sender,reciver])
        return chatRoomId
}

func creatChatRoom(chatRoomId :String ,users :[User]){
    // MARK: - if user has already chatroom we will not creat one.
    var usersToCreateChatFor : [String]
    usersToCreateChatFor = []
    for user in users {
        usersToCreateChatFor.append(user.id)
    }
    firestoreRefernce(.Chat).whereField(KCHATROOMID,isEqualTo: chatRoomId).getDocuments { (querySnapshot,error) in
        guard let snapshot = querySnapshot else{return}
        if !snapshot.isEmpty{
            for chatData in snapshot.documents{
                let currentChat = chatData.data() as Dictionary
                if let currentUserId = currentChat[KSENDERID]{
                    if usersToCreateChatFor.contains(currentUserId as! String){
                        usersToCreateChatFor.remove(at:usersToCreateChatFor.firstIndex(of: currentUserId as! String)!)
                    }
                }
            }
        }
        for userId in usersToCreateChatFor{
            let senderUser = userId == User.currentId ? User.currentUser! :getReciverFrom(users: users)
            let reciverUser = userId == User.currentId ? getReciverFrom(users: users) :User.currentUser!
            let chatRoomObject = ChatRoom(id: UUID().uuidString, chatRoomId: chatRoomId, senderId: senderUser.id, senderName:senderUser.userName, reciverId: reciverUser.id, reciverName: reciverUser.userName, date: Date(), memberIds: [senderUser.id ,reciverUser.id], lastMessage: "" , unreadCounter: 0 , avatarLink: reciverUser.avtarLink)
            
            
            // MARK: - save chat on firestore .
            FChatRoomListener.shared.saveChatRoom(chatRoomObject)
            
        }
        
    }
    
}
// MARK: -  get reciver user from user.

func getReciverFrom (users:[User])->User{
    var allUsers = users
    allUsers.remove(at: allUsers.firstIndex(of: User.currentUser!)!)
    return allUsers.first!
}


