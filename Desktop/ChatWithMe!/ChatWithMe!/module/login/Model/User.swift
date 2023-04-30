//
//  User.swift
//  ChatWithMe!
//
//  Created by Mohamed Hadwa on 31/12/2022.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift



struct User : Codable ,Equatable {
    var userName:String
    var id :String
    var email :String
    var pushId = ""
    var avtarLink : String
    var status : String
    
    static var currentId :String{
        return Auth.auth().currentUser!.uid
    }
    static var currentUser : User? {
        if Auth.auth().currentUser != nil {
            if let data = userDefults.data(forKey: KCURRENRUSER){
                let decoder = JSONDecoder()
                do {
                    let userObject = try decoder.decode(User.self, from: data)
                    return userObject
                }catch{
                    print(error.localizedDescription)
                }
            }
        }
            return nil 
    }
    static func == (lhs:User ,rhs:User)-> Bool{
        lhs.id == rhs.id
    }
    
}
func saveUserLocally (_ user:User){
    let encoder = JSONEncoder()
    do{
        let data = try encoder.encode(user)
        userDefults.set(data, forKey:KCURRENRUSER)
    }catch{
        print(error.localizedDescription)
    }
}
// MARK: - Creating dummy user.
func createDummyUsers(){
    print("creating dummy users ...")
    let names = ["anas", "u3" ,"khalid" , "hossam" , "mostafa"]
    var imageIndex = 1
    var userIndex = 1
    for i in 0..<6{
        let id = UUID().uuidString
        let fileDirectory = "Avatars/"+"_\(id)"+".jpg"
        FileStorage.uploudImage(UIImage(named: "user\(imageIndex)")!, directory: fileDirectory) { (avatarLink) in
            let user = User(userName: names[i], id: id, email: "user\(userIndex)@mail.com", avtarLink: avatarLink ?? "", status: "No Status")
            userIndex += 1
            FUserListener.shared.saveUserToFirestore(user)
        }
        imageIndex += 1
        if imageIndex == 6{
            imageIndex = 1
            
        }
    }
}

