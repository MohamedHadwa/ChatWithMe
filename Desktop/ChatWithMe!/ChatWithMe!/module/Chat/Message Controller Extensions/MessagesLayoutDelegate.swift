//
//  MessagesLayoutDelegate.swift
//  ChatWithMe!
//
//  Created by Mohamed Hadwa on 14/01/2023.
//

import Foundation
import MessageKit

extension MessageViewController : MessagesLayoutDelegate{
    // MARK: - func cell top label height.
     
    func cellTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        if indexPath.section % 3 == 0 {

            if ((indexPath.section == 0 ) && (allLocalMessages.count > displayingMessageCount)) {
                return 50
            }
        }
        return 10
    }
    // MARK: - func cell bottom label height.
    func cellBottomLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return isFromCurrentSender(message: message) ? 17 : 0
    }
    func messageBottomLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return indexPath.section != mkMessages.count - 1 ? 10 : 0
    }

    // MARK: -  avater .
    func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        avatarView.set(avatar: Avatar( initials: mkMessages[indexPath.section].senderInitials) )
    }

    
}
