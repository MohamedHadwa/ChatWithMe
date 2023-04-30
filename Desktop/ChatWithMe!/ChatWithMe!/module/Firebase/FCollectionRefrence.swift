//
//  FCollectionRefrence.swift
//  ChatWithMe!
//
//  Created by Mohamed Hadwa on 01/01/2023.
//

import Foundation
import Firebase
enum FcollectionRefernce:String {
    case User
    case Chat
    case Message
    case Typing
}
func firestoreRefernce (_ collectionRefernce:FcollectionRefernce) ->CollectionReference{
    return Firestore.firestore().collection(collectionRefernce.rawValue)
    
}
