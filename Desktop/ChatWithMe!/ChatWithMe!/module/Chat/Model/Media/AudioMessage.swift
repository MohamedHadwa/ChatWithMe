//
//  AudioMessage.swift
//  ChatWithMe!
//
//  Created by Mohamed Hadwa on 27/02/2023.
//

import Foundation
import MessageKit

class AudioMessage : NSObject , AudioItem {
    var url: URL
    
    var duration: Float
    
    var size: CGSize
    init(duration :Float) {
        self.url = URL(fileURLWithPath: "")
        self.size = CGSize(width: 180, height: 35)
        self.duration = duration
    }
    
}
