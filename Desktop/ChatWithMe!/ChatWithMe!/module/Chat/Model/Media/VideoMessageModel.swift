//
//  VideoMessageModel.swift
//  ChatWithMe!
//
//  Created by Mohamed Hadwa on 25/02/2023.
//

import Foundation
import MessageKit


class VideoMessage :NSObject , MediaItem{
    var url: URL?
    
    var image: UIImage?
    
    var placeholderImage: UIImage
    
    var size: CGSize
    
     init(url:URL?) {
         self.url = url
         self.placeholderImage = UIImage(named: "imageplaceholder")!
         self.size = CGSize(width: 240, height: 240)
        
    }
}
