//
//  InputBarAccessoryViewDelegate.swift
//  ChatWithMe!
//
//  Created by Mohamed Hadwa on 14/01/2023.
//

import Foundation
import MessageKit
import InputBarAccessoryView

extension MessageViewController : InputBarAccessoryViewDelegate {
    func inputBar(_ inputBar: InputBarAccessoryView, textViewTextDidChangeTo text: String) {
        print("typing" , text)
        updateMicButtonStatus(show: text == "" )
        if text != "" {
            startTypingIndicator()
        }

    }
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
//        print("sending message" , text)
        send(text: text, photo: nil, video: nil, audio: nil, location: nil)
        messageInputBar.inputTextView.text = ""
        messageInputBar.invalidatePlugins()
    }
}
