//
//  MessagesDisplayDelegate.swift
//  ChatWithMe!
//
//  Created by Mohamed Hadwa on 14/01/2023.
//

import Foundation
import MessageKit

extension MessageViewController : MessagesDisplayDelegate{
    func textColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return .label
    }
    
    func backgroundColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        let bubbleColorOutgoing = UIColor(named: "ColorOuttingBubble")
        let bubbleColorIncoming = UIColor(named: "ColorIncommingBubble")
        return isFromCurrentSender(message: message) ? bubbleColorOutgoing ?? UIColor.green: bubbleColorIncoming ?? UIColor.lightGray
    }
    func messageStyle(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageStyle {
        let tail : MessageStyle.TailCorner = isFromCurrentSender(message: message) ? .bottomRight : .bottomLeft
        return .bubbleTail(tail, .curved)
    }
}
