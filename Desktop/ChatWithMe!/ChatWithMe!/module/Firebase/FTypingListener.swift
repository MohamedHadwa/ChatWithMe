//
//  FTypingListener.swift
//  ChatWithMe!
//
//  Created by Mohamed Hadwa on 15/02/2023.
//

import Foundation
import Firebase
 
class FTypingListener {
    static let shared = FTypingListener()
    
    var typingListener : ListenerRegistration!
    private init(){}
    
    func createTypingObserver(chatRoomId : String , complition :@escaping (_ isTyping : Bool) -> Void) {
        typingListener = firestoreRefernce(.Typing) .document(chatRoomId).addSnapshotListener({ (documentSnapshot , error) in
            
            guard let snapshot = documentSnapshot else {return}
            
            if snapshot.exists {
                for data in snapshot.data()! {
                    if data.key != User.currentId {
                        complition(data.value as! Bool)
                    }
                }
            }
            else {
                complition (false)

                firestoreRefernce(.Typing).document(chatRoomId).setData([User.currentId : false])
            }
            
        })
    }
    class func saveTypingCounter(typing:Bool ,chatRoomId: String){
        firestoreRefernce(.Typing).document(chatRoomId).updateData([User.currentId:typing])
        
    }
    func removeTypingListener(){
        self.typingListener.remove()
    }
}
