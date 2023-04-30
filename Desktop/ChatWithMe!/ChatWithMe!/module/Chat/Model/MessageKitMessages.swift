//
//  MessageKitMessages.swift
//  ChatWithMe!
//
//  Created by Mohamed Hadwa on 14/01/2023.
//

import Foundation
import UIKit
import MessageKit
import CoreLocation

class MKMessages : NSObject, MessageType {
    var messageId: String
    var kind: MessageKind
    var sentDate: Date
    var mksender :MKSender
    var sender: SenderType{return mksender}
    var senderInitials : String
    var photoItem : PhotoMessage?
    var videoItem : VideoMessage?
    var locationItem : LocationMessage?
    var audioItem : AudioMessage?
    var status :String
    var readDate :Date
    var incoming : Bool
    
    
     init(message :LocalMessage) {
         self.messageId = message.id
         self.kind = MessageKind.text(message.message)
         
         switch message.type {
         case KTEXT :
             self.kind = MessageKind.text(message.message)
             
         case KPHOTO :
             let photoItem = PhotoMessage(path: message.pictureUrl)
             self.kind = MessageKind.photo(photoItem)
             self.photoItem = photoItem
             
         case KVIDEO :
             let videoItem = VideoMessage(url: nil)
             self.kind = MessageKind.video(videoItem)
             self.videoItem = videoItem

         case KLOCATION :
             let locationItem = LocationMessage(location: CLLocation(latitude: message.latitude, longitude: message.longitude))
             self.kind = MessageKind.location(locationItem)
             self.locationItem = locationItem
         case KAUDIO :
             let audioItem = AudioMessage(duration: 2.0)
             self.kind = MessageKind.audio(audioItem)
             self.audioItem = audioItem
         default:
             self.kind = MessageKind.text(message.message)
         }
         self.mksender = MKSender(senderId: message.senderId, displayName: message.senderName)
         self.senderInitials = message.senderInitials
         self.sentDate = message.date
         self.readDate = message.readDate
         self.incoming = User.currentId != mksender.senderId
         self.status = message.status
    }
    
}
