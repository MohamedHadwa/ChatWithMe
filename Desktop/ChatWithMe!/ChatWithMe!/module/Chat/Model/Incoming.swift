//
//  Incoming.swift
//  ChatWithMe!
//
//  Created by Mohamed Hadwa on 14/01/2023.
//

import Foundation
import MessageKit
import CoreLocation

class Incoming {
    var messageViewController : MessageViewController
    
    init(messageViewController: MessageViewController) {
        self.messageViewController = messageViewController
    }
    
    func createMKMessage(localMessage : LocalMessage) -> MKMessages{
        let mKMessage = MKMessages(message: localMessage)
        
        if localMessage.type == KPHOTO {
            let photoItem = PhotoMessage(path: localMessage.pictureUrl)
            mKMessage.photoItem = photoItem
            mKMessage.kind = MessageKind.photo(photoItem)
            FileStorage.downloadImage(imgUrl: localMessage.pictureUrl) { (image )in
                mKMessage.photoItem?.image = image
                self.messageViewController.messagesCollectionView.reloadData()
            }
        }
        if localMessage.type == KVIDEO {
            FileStorage.downloadImage(imgUrl: localMessage.pictureUrl) { (thumbnail) in
                FileStorage.downloadVideo(videoUrl: localMessage.videoUrl) {( readyToPlay, fileName) in
                    let videoLink = URL(fileURLWithPath: fileInDocumentDirectory(fileName: fileName))
                    let videoItem = VideoMessage(url: videoLink)
                    mKMessage.videoItem = videoItem
                    mKMessage.kind = MessageKind.video(videoItem)
                    mKMessage.videoItem?.image = thumbnail
                    self.messageViewController.messagesCollectionView.reloadData()
                }
            }
        }
        
        if localMessage.type == KLOCATION {
            let locationItem = LocationMessage(location: CLLocation(latitude: localMessage.latitude, longitude: localMessage.longitude))
            mKMessage.kind = MessageKind.location(locationItem)
            mKMessage.locationItem = locationItem
            self.messageViewController.messagesCollectionView .reloadData() 
            
        }
        if localMessage.type == KAUDIO {
            let audioMessage = AudioMessage(duration: Float(localMessage.audioDuration))
            mKMessage.kind = MessageKind.audio(audioMessage)
            mKMessage.audioItem = audioMessage
            FileStorage.downloadAudio(audioUrl: localMessage.audioUrl) { (fileName) in
                let audioURL = URL(fileURLWithPath : fileInDocumentDirectory(fileName: fileName))
                mKMessage.audioItem?.url = audioURL
                
            }
            self.messageViewController.messagesCollectionView . reloadData()
        }
        
        return mKMessage
    }
}
