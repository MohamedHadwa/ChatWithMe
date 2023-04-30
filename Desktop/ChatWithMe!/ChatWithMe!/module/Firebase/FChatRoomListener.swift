//
//  FChatRoomListener.swift
//  ChatWithMe!
//
//  Created by Mohamed Hadwa on 05/01/2023.
//

import Foundation
import Firebase


class FChatRoomListener{
    static let shared = FChatRoomListener()
      init (){}
    
    func saveChatRoom(_ chatRoom :ChatRoom){
        do{
            
            try firestoreRefernce(.Chat).document(chatRoom.id).setData(from:chatRoom)
            
        }catch{
            print("not able to save document " , error.localizedDescription)
            
            
        }
    }
    
    // MARK: - download chataroom from firebase.
    func downloadChatRooms(completion :@escaping(_ allFBChatRooms :[ChatRoom])->Void){
        firestoreRefernce(.Chat).whereField(KSENDERID, isEqualTo: User.currentId).addSnapshotListener { (snapshot , error) in
            var chatRooms :[ChatRoom] = []
            guard let documents = snapshot?.documents else{
                print("no documents found")
                return
            }
            let allFBChatRooms = documents.compactMap { (snapshot) ->ChatRoom? in
                print(snapshot)
                return try? snapshot.data(as:ChatRoom.self)
                
            }
            for chatRoom in allFBChatRooms{
                if chatRoom.lastMessage != ""{
                    chatRooms.append(chatRoom)
                }
            }
            chatRooms.sort(by: {$0.date! > $1.date!})
            completion(chatRooms)
        }
    }
    
    // MARK: -  delete chat from chat room.
    
    func deleteChat  (_ chatRoom :ChatRoom){
        firestoreRefernce(.Chat).document(chatRoom.id).delete()
    }
    // MARK: - rest unread counter.
    func clearUnreadCounter (chatRoom : ChatRoom){
        
        var newChatRoom = chatRoom
        newChatRoom.unreadCounter = 0
        self.saveChatRoom(newChatRoom)
        
    }
    
    func clearUnreadCounterUsingChatRommId(chatRoomId:String) {
        firestoreRefernce(.Chat).whereField(KCHATROOMID, isEqualTo: chatRoomId).whereField(KSENDERID, isEqualTo: User.currentId).getDocuments { (querySnapshot,error ) in
            guard let documents = querySnapshot?.documents else {return}
            let allChatRooms = documents.compactMap { (querySnapshot)->ChatRoom? in
                return try? querySnapshot.data(as: ChatRoom.self)
            }
            if allChatRooms .count > 0 {
                self.clearUnreadCounter(chatRoom: allChatRooms.first!)
            }
        }
    }
    
    // MARK: - update chatRoom with new mesaage.
    private func updateChatRoomWithNewMessage (chatRoom:ChatRoom , lastMessage : String){
        
        var tempChatRoom = chatRoom
        if tempChatRoom .senderId != User.currentId{
            tempChatRoom.unreadCounter += 1
        }
        tempChatRoom.lastMessage = lastMessage
        tempChatRoom.date = Date()
        self.saveChatRoom(tempChatRoom)
    }
    
    func updatChatRooms (chatRoomId : String ,lastMessage : String) {
        firestoreRefernce(.Chat).whereField(KCHATROOMID, isEqualTo: chatRoomId).getDocuments { (querySnapshot,error) in
            guard let documents = querySnapshot?.documents else{return}
            let allChatRooms = documents.compactMap { (querySnapshot)->ChatRoom? in
                return try? querySnapshot.data(as: ChatRoom.self)
            }
            for chatRoom in allChatRooms{
                self.updateChatRoomWithNewMessage(chatRoom: chatRoom, lastMessage: lastMessage)
            }
        }
        
    }




    
}
