//
//  Outgoing.swift
//  ChatWithMe!
//
//  Created by Mohamed Hadwa on 14/01/2023.
//

import Foundation
import UIKit
import FirebaseFirestoreSwift
import Gallery

class Outgoing{
    
    class func sendMessage (chatId :String , text :String? , photo :UIImage? , video:Video?, audio:String? , audioDuration:Float = 0.0 , location :String? , memberIds:[String]){
        
        //1. create local message from the data we have
        
        let currentUser = User.currentUser!
        
        let message = LocalMessage()
        message.id = UUID().uuidString
        message.chatRoomId = chatId
        message.senderId = currentUser.id
        message.senderName = currentUser.userName
        message.senderInitials = String(currentUser.userName.first!)
        message.status = KSENT
        message.date = Date()
          
        //2. cheak message type
        if text != nil{
            sendText(message :message , text :text! , memberIds :memberIds)
        }
        
        if photo != nil {
            sendPhoto(message: message, photo: photo!, memberIds: memberIds)

        }
        if video != nil {

           sendVideo(message: message, video: video!, memberIds: memberIds)
        }
        if location != nil {
            sendLocation(message: message, memberIds: memberIds)

        }
        if audio != nil {
sendAudio(message: message, audioFileName: audio!, audioDuration: audioDuration, memberIds: memberIds)
            
        }

        // TODO: - send push notification
        FChatRoomListener.shared.updatChatRooms(chatRoomId: chatId, lastMessage: message.message)
        
    }
    // MARK: - save massage .

    
    class func saveMessage(message :LocalMessage , memberIds :[String]){
        
        RealmManager.shared.save(message)
        for memberId in memberIds {
            FMessageListener.shared.addMessage(message, memberId: memberId)
        }
    }
}




func sendText(message:LocalMessage , text :String , memberIds: [String]){
    message.message = text
    message.type = KTEXT
    Outgoing.saveMessage(message: message, memberIds: memberIds)
}

func sendPhoto(message:LocalMessage , photo :UIImage , memberIds: [String]) {
    message.message = "photo Message"
    message.type = KPHOTO
    
    
    let fileName = Date().stringDate()
    let fileDirectory = "MediaMessages/Photo/" + "\(message.chatRoomId)" + "_\(fileName)" + ".jpg"
    
    FileStorage.saveFileLocally(fileData: photo.jpegData(compressionQuality: 0.9) as! NSData, fileName: fileName)
    FileStorage.uploudImage(photo, directory: fileDirectory) {(imageURL) in
        if imageURL != nil {
            message.pictureUrl = imageURL!
            Outgoing.saveMessage(message: message, memberIds: memberIds)
        }
    }
    
}
// MARK: - Send Video and thumbnail.
 

func sendVideo(message:LocalMessage , video :Video , memberIds: [String]) {
    message.message = "Video Message"
    message.type = KVIDEO
    
    let fileName = Date().stringDate()
    
    let thumbnailDirectory = "MediaMessages/Photo/" + "\(message.chatRoomId)" + "_\(fileName)" + ".jpg"
    let videoDirectory = "MediaMessages/Video/" + "\(message.chatRoomId)" + "_\(fileName)" + ".mov"
    
    let editor = VideoEditor()
    editor.process(video: video) { (processedVideo, videoUrl) in
       if let tempPath = videoUrl{
           let thumbnail = videoThumbnail(videoUrl: tempPath)
           FileStorage.saveFileLocally(fileData: thumbnail.jpegData(compressionQuality: 1.0)! as NSData, fileName: fileName)
           FileStorage.uploudImage(thumbnail, directory: thumbnailDirectory) { imageLink in
               if imageLink != nil {
                   let videoData = NSData(contentsOfFile: tempPath.path)
                   FileStorage.saveFileLocally(fileData: videoData!, fileName: fileName + ".mov")
                   FileStorage.uploudVideo(videoData!, directory: videoDirectory) { (videoLink )in
                       message.videoUrl = videoLink ?? ""
                       message.pictureUrl = imageLink ?? ""
                       Outgoing.saveMessage(message: message, memberIds: memberIds)

                   }
               }
           }
        }
    }

}
func sendLocation(message:LocalMessage , memberIds : [String]){
     
    let  currentLocation  = LocationManger.shared.currentLocation
    
    message.message = "Location Message"
    message.type = KLOCATION
    message.latitude = currentLocation?.latitude ?? 0.0
    message.longitude = currentLocation?.longitude ?? 0.0
    
    Outgoing.saveMessage(message: message, memberIds: memberIds)
    
}
func sendAudio(message :LocalMessage , audioFileName : String , audioDuration : Float ,memberIds : [String]) {
    message.message = "AudioMessage"
    message.type = KAUDIO
    let fileDirectory = "MediaMessages/Audio/" + "\(message.chatRoomId)" + "_\(audioFileName)" + ".m4"
    FileStorage.uploudAudio(audioFileName, directory: fileDirectory) { (audioLink) in
        
        if audioLink != nil {
            message.audioUrl = audioLink ?? ""
            message.audioDuration = Double(audioDuration)
            
            Outgoing.saveMessage(message: message, memberIds: memberIds)
        }
    }

}
