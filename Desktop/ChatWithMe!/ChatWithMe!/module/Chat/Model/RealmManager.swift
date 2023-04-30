//
//  RealmManager.swift
//  ChatWithMe!
//
//  Created by Mohamed Hadwa on 14/01/2023.
//

import Foundation
import  RealmSwift


class RealmManager {
    
    static let shared = RealmManager()
    let realm = try! Realm()
    
    private init(){}
    func save <T:Object> (_ object :T){
        do{
            try realm.write{
                realm.add(object,update: .all)
                
            }
        }catch{
            print("error saving data",error.localizedDescription)
        }
    }
}
