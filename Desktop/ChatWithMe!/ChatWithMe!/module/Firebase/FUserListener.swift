//
//  FUserListener.swift
//  ChatWithMe!
//
//  Created by Mohamed Hadwa on 01/01/2023.
//

import Foundation
import Firebase
import FirebaseStorage

class FUserListener {
    static let shared = FUserListener()
    private init(){}
    
    
    // MARK: - login Func.
    func loginUserWith (email:String ,password :String ,complition :@escaping(_ error:Error? ,_ isEmailVerified :Bool)->Void){
        Auth.auth().signIn(withEmail: email, password: password ){(authResults ,error ) in
            if error == nil && authResults!.user.isEmailVerified{
                complition (error ,true)
                self.downloadUserFromFirestore(userId:authResults!.user.uid)
            }else {
                complition(error ,false)
            }
        }
    }
    
    
    
    // MARK: - Register Func.

    func registerUserWith (email:String ,password :String ,complition :@escaping(_ error:Error?)->Void){
        Auth.auth().createUser(withEmail: email, password: password) { [self](autResult  , error )in
            complition(error)
            if error == nil {
                autResult!.user.sendEmailVerification{(error) in
                    complition(error)
                }
            }
            if autResult?.user  != nil {
                let user = User(userName: email, id: autResult!.user.uid, email: email, avtarLink: "", status: "Hey i am using Chat With Me !")
                
                self.saveUserToFirestore(user)
                
            }
        }
    }
    
    // MARK: - logOut Func.
    func logoutUser(complition:@escaping(_ error :Error?)->Void){
        do {
            try Auth.auth().signOut()
            userDefults.removeObject(forKey: KCURRENRUSER)
            userDefults.synchronize()
            complition (nil)
            
        }catch let error as NSError     {
            complition (error)
        }
    }

    // MARK: - Forget Password.
    func forgetPassword (email : String , complition :@escaping(_ error :Error?)->Void){
        Auth.auth().sendPasswordReset(withEmail: email){(error) in
            complition(error)
        }
    }
    
    // MARK: - Resend Email Verify.

//    func resendEmailVerification (email : String ,complition : @escaping(_ error:Error?)->Void){
//
//        Auth.auth().currentUser?.reload(completion: { (error) in
//            Auth.auth().currentUser?.sendEmailVerification(completion: { (error) in
//                complition (error)
//            })
//        })
//    }
    func resendVerificationEmail(email:String ,complition :@escaping (_ error:Error?)->Void){
        Auth.auth().currentUser?.reload(completion: { (error) in
         complition (error)
            Auth.auth().currentUser?.sendEmailVerification(completion: { (error) in
                complition(error)
            })
            })
        
    }
    
    // MARK: - Save User To Firebase.

    func saveUserToFirestore(_ user :User){
        do {
            try firestoreRefernce(.User).document(user.id).setData(from: user )
        }catch{
            print(error.localizedDescription)
        }
    }
    
    // MARK: - download User From Firestore.

    func downloadUserFromFirestore (userId:String){
        
        firestoreRefernce(.User).document(userId).getDocument { document, error in
            guard let userDocument = document
            else{
                print("No Data found ")
                return
            }
            let result = Result {
                try? userDocument.data(as:User.self)
            }
            switch result {
            case .success(let userObject):
                if let user = userObject {
                    saveUserLocally(user)
                    
                }else{
                    print("document not exist")
                }
            case .failure(let error ):
                print("error decoding user ",error.localizedDescription)
            }
        }
    }
    // MARK: - downloadAllUsersFromFirestore .
    func downloadAllUsersFromFirestore(complition:@escaping (_ allUsers:[User])->Void){
        var users:[User] = []
        firestoreRefernce(.User).getDocuments{ (snapshot, error) in
            guard let documents = snapshot?.documents else{
                print("No Document found")
                return
            }
            let allUsers = documents.compactMap { (snapshot) ->User?
                in
                return try? snapshot.data(as:User.self)
            }
            for user in allUsers{
                if User.currentId != user.id{
                    users.append(user)
                }
            }
            complition(users)
        }
    }
    // MARK: - download Users from firebase using IDs.
    func downloadUsersFromFirestore(whithIds :[String] , complition :@escaping (_ allUsers : [User])->Void){
        var count = 0
        var userArray :[User] = []
        for userId in whithIds{
            firestoreRefernce(.User).document(userId).getDocument { (querySnapshot, error) in
                guard let document = querySnapshot else{
                    return
                }
                let user = try? document.data(as: User.self)
                userArray.append(user!)
                count += 1
                if count == whithIds.count {
                    complition(userArray)
                }
            }
        }
    }
    
   
}
