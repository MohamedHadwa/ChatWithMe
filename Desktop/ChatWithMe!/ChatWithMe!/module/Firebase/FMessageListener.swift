//
//  FMessageListener.swift
//  ChatWithMe!
//
//  Created by Mohamed Hadwa on 14/01/2023.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift

class FMessageListener {
    
    static let shared = FMessageListener()
    var newMessageListener : ListenerRegistration!
    var updatedMessageListener : ListenerRegistration!

    private init (){}
    func addMessage (_ message :LocalMessage ,memberId :String){
        do{
            try firestoreRefernce(.Message).document(memberId).collection(message.chatRoomId).document(message.id).setData(from: message)
        }catch{
            print("error Saving message to firestore" ,error.localizedDescription)
        }
    }
    func checkForOldMessage (_ documentId : String , collectionId: String) {
        firestoreRefernce(.Message).document(documentId).collection(collectionId).getDocuments { (querySnapshot , error) in
            guard let documents = querySnapshot?.documents else{return}
            var oldMessages = documents.compactMap { (querySnapshot) -> LocalMessage? in
                return try? querySnapshot.data(as: LocalMessage.self)
                
            }
            oldMessages.sort(by: {$0.date < $1.date})
            for message in oldMessages {
                RealmManager.shared.save(message)
                print("done")
            }
        }
        
    }
    func listenForNewMessage (_ documentId : String , collectionId: String , lastMessageDate: Date ){
        newMessageListener = firestoreRefernce(.Message).document(documentId).collection(collectionId).whereField(KDate, isGreaterThan: lastMessageDate).addSnapshotListener({ (querySnapshot, error) in
            guard let snapshot = querySnapshot else{return}
            for change in snapshot.documentChanges {
                if change.type == .added {
                    let result = Result {
                        try? change.document.data(as: LocalMessage.self)
                    }
                    switch result {
                    case .success(let messageObject) :
                        if let message = messageObject {
                            if message.senderId != User.currentId{
                                RealmManager.shared.save(message)
                            }
                        }
                            case .failure( let error):
                        print(error.localizedDescription)
                    }
                }
            }
        })
    }
   
    // MARK: - func update message status .
    func updateMessageStatus (_ message : LocalMessage , userId : String ) {
        let values = [KSTATUS : KREAD , KREADDATE :Date() ] as [String : Any]
        
        firestoreRefernce(.Message).document(userId).collection(message.chatRoomId).document(message.id).updateData(values)
    
    }
    // MARK: - listene for read status update.
    func listeneForReadStatus (_ documentId : String , collectionId : String , complition : @escaping(_ updateMessage:LocalMessage) ->Void ){
        updatedMessageListener = firestoreRefernce(.Message).document(documentId).collection(collectionId).addSnapshotListener({ (querySnaoshot , error) in
            guard let snapshot = querySnaoshot else {return}
            for change in snapshot.documentChanges {
                if change.type == .modified{
                    let result = Result {
                        try? change.document.data(as: LocalMessage.self)
                    }
                    switch result{
                        
                    case .success(let messageObject):
                        if let message = messageObject {
                            complition (message)
                        }
                    case .failure(let error):
                        print("Error decoding" , error.localizedDescription)
                    }
                }
            }
            
        })
    }
    // MARK: - remove listeners when exit messageviewcontroller.

    
    func removeNewMessageListener(){
        self.newMessageListener.remove()
        self.updatedMessageListener.remove()
    }


}
