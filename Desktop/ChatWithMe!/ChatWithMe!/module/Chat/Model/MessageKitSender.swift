//
//  MessageKitSender.swift
//  ChatWithMe!
//
//  Created by Mohamed Hadwa on 14/01/2023.
//

import Foundation
import UIKit
import MessageKit

struct MKSender :SenderType ,Equatable {
    var senderId: String
    var displayName: String
    
    
}
