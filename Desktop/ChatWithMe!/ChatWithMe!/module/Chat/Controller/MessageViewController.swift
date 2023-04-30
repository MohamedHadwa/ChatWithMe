//
//  MessageViewController.swift
//  ChatWithMe!
//
//  Created by Mohamed Hadwa on 14/01/2023.
//

import UIKit
import MessageKit
import InputBarAccessoryView
import Gallery
import RealmSwift
class MessageViewController: MessagesViewController {
    
    // MARK: - custom views.
    
    
    let leftBarButtonView : UIView = {
        return UIView(frame: CGRect(x: 0, y: 0, width: 200, height: 50))
    }()
    let titleLabel : UILabel = {
        let title = UILabel(frame: CGRect(x: 5, y: 0, width: 100, height: 25))
        title.textAlignment = .left
        title.font = UIFont.systemFont(ofSize: 16 ,weight: .medium)
        title.adjustsFontSizeToFitWidth = true
        return title
    }()
    let subTitleLabel : UILabel = {
        let title = UILabel(frame: CGRect(x: 5, y:22 , width: 100, height: 24))
        title.textAlignment = .left
        title.font = UIFont.systemFont(ofSize: 13 ,weight: .medium)
        title.adjustsFontSizeToFitWidth = true
        return title
    }()

    
    // MARK: - Private Variables.
    private var chatId = ""
    private var recipientId = ""
    private var recipientName = ""
    var refreshController = UIRefreshControl()
    let micButton = InputBarButtonItem()
    let currentUser = MKSender(senderId: User.currentId, displayName: User.currentUser!.userName)
    var mkMessages :[MKMessages] = []
    var allLocalMessages :Results<LocalMessage>!
    let realm = try! Realm()
    var notificationToken :NotificationToken?
    var displayingMessageCount = 0
    var maxMessageNumber = 0
    var minMessageNumber = 0
    var typingCounter = 0
    var gallary : GalleryController!
    var longPressGesture : UILongPressGestureRecognizer!
    
    var audioFileName : String = ""
    var audioStartTime:Date = Date()
    
    open lazy var audioController = BasicAudioController(messageCollectionView: messagesCollectionView)

    
    
    // MARK: - init.
    init(chatId:String , recipientId : String , recipientName:String){
        super.init(nibName: nil, bundle: nil)
        self.chatId = chatId
        self.recipientId = recipientId
        self.recipientName = recipientName
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureGestureRecognizer()

        configureMSGCollectionView()
        configureMessageInputBar()
        loadMessages()
        checkForNewMessage()
        configureCustomTitle()
        createTypingObserver()
        listenForReadStatusUpdates()
        navigationItem.largeTitleDisplayMode = .never

        
    }
    // MARK: - IBActions.
    
    
    // MARK: - Private Functions.
    
    private func configureMSGCollectionView(){
        
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messageCellDelegate = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        
        scrollsToLastItemOnKeyboardBeginsEditing = true
        maintainPositionOnKeyboardFrameChanged = true
        messagesCollectionView.refreshControl = refreshController
        
    }
    // MARK: - func Configure massage inputBar .
    private func configureMessageInputBar(){
        messageInputBar.delegate = self
        let attachButton = InputBarButtonItem()

                attachButton.image = UIImage(systemName: "paperclip" , withConfiguration: UIImage.SymbolConfiguration(pointSize: 30))
        attachButton.setSize(CGSize(width: 30, height: 30), animated: false)
        attachButton.onTouchUpInside { item in
            print("attaching...")
            self.actionAttachMessage()
            
        }
        
        
        micButton.image = UIImage(systemName: "mic.fill" , withConfiguration: UIImage.SymbolConfiguration(pointSize: 30))
        micButton.setSize(CGSize(width: 30, height: 30), animated: false)
        
        // MARK: - add gesture recognizer
        micButton.addGestureRecognizer(longPressGesture)
        messageInputBar.setStackViewItems([attachButton], forStack: .left, animated: false)
        messageInputBar.setLeftStackViewWidthConstant(to: 36, animated: false)
        // TODO: - update Mic button status show or not
        updateMicButtonStatus(show: true)
        messageInputBar.inputTextView.isImagePasteEnabled = false
        messageInputBar.backgroundView.backgroundColor = .systemBackground
        messageInputBar.inputTextView.backgroundColor = .systemBackground
        
    }
    // MARK: -  long press gesture.
    
    private func configureGestureRecognizer(){
        longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(recordAndSend))
    }

    
    
    func updateMicButtonStatus(show:Bool){
        
        if show{
            messageInputBar.setStackViewItems([micButton], forStack: .right, animated: false)
            messageInputBar.setRightStackViewWidthConstant(to: 30, animated: false)
        }
        else{
            messageInputBar.setStackViewItems([messageInputBar.sendButton], forStack: .right, animated: false)
            messageInputBar.setRightStackViewWidthConstant(to: 55, animated: false)
        }
    }
    // MARK: -  configure custom title .
    
    private func configureCustomTitle (){
        self .navigationItem.leftBarButtonItems = [UIBarButtonItem(image: UIImage(named: "left-chevron"), style: .plain, target: self, action: #selector(self.backButtonPressed) )]
        leftBarButtonView.addSubview(titleLabel)
        leftBarButtonView.addSubview(subTitleLabel)
        let leftBarButtonItem = UIBarButtonItem(customView: leftBarButtonView)
        self.navigationItem.leftBarButtonItems?.append(leftBarButtonItem)
        titleLabel .text = self.recipientName
    }
    @objc func backButtonPressed(){
        removeListener()
        FChatRoomListener.shared.clearUnreadCounterUsingChatRommId(chatRoomId: chatId)
        navigationController?.popViewController(animated: true)
        
    }
    // MARK: -  mark message as read.
    private func markMessageAsRead (_ localMessage:LocalMessage){
        if localMessage.senderId != User.currentId {
            FMessageListener.shared.updateMessageStatus(localMessage, userId: recipientId)
        }
    }
     
    // MARK: - update read status.
    
    private func updateReadStatus (_ updatedLocalMessage :LocalMessage) {
        for index in 0 ..< mkMessages.count {
            let tempMessage = mkMessages[index]
            if updatedLocalMessage.id == tempMessage.messageId {
                mkMessages[index].status = updatedLocalMessage.status
                mkMessages[index].readDate = updatedLocalMessage.readDate
                RealmManager.shared.save(updatedLocalMessage)
                if mkMessages[index].status == KREAD {
                    self.messagesCollectionView.reloadData()
                }
                
            }
        }
    }
    private func listenForReadStatusUpdates (){
        FMessageListener.shared.listeneForReadStatus(User.currentId, collectionId: chatId) { (updateMessage) in
            self.updateReadStatus(updateMessage)
        }
    }


    func updateTypingIndictor (_ show : Bool) {
        subTitleLabel.text = show ? "Typing..." : ""
    }
    // MARK: -  start typing listener.
    
    func startTypingIndicator (){
        typingCounter += 1
        FTypingListener.saveTypingCounter(typing: true, chatRoomId: chatId)
        // MARK: - stop typing after 2.5 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5){
            self.stopTypingIndicator()
        }
    }

    // MARK: -  stop typing listener.
    
    func stopTypingIndicator (){
        typingCounter -= 1
        FTypingListener.saveTypingCounter(typing: false, chatRoomId: chatId)
    }
    // MARK: - func to create typing stauts for recepiant.

    func  createTypingObserver (){
        FTypingListener.shared.createTypingObserver(chatRoomId: chatId) { (isTyping )in
            DispatchQueue.main.async {
                self.updateTypingIndictor(isTyping)
            }
        }
    }

    
    // MARK: - Actions .
    
    func send (text:String? , photo :UIImage? , video :Video? , audio : String? ,location :String?, audioDuration :Float = 0.0 ){
        Outgoing.sendMessage(chatId: chatId, text: text, photo: photo, video: video, audio: audio, location: location, memberIds: [User.currentId , recipientId])
       // print(Realm.Configuration.defaultConfiguration.fileURL!)

    }
    // MARK: - record and send func.
    @objc func recordAndSend(){
        switch longPressGesture.state{
        case .began:
        //record and start recording
            audioFileName = Date().stringDate()
            audioStartTime = Date()
            AudioRecorder.shared.startRecording(fileName: audioFileName)
        case .ended:
        //stop recording and save audio message
            AudioRecorder.shared.finishRecording()
            if fileExistsPath(path: audioFileName + ".m4a"){
                let audioDuration = audioStartTime.interval(ofComponent: .second, to: Date())
                send(text: nil, photo: nil, video: nil, audio: audioFileName, location: nil ,audioDuration: audioDuration)
            }else {
                print("no file found")
            }
        @unknown default:
            print("unkown")
        }
        

    }


    
    // MARK: - UIScrollViewDelegete .

    override func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if refreshController.isRefreshing {
            if displayingMessageCount < allLocalMessages.count {
                self.insertMoreMKMessages()
                messagesCollectionView.reloadDataAndKeepOffset()
            }
        }
        refreshController.endRefreshing()
    }
    
    // MARK: - Load Mesaages.
    private func loadMessages(){
        let predicate = NSPredicate(format: "chatRoomId = %@", chatId)
        allLocalMessages = realm.objects(LocalMessage.self).filter(predicate).sorted(byKeyPath: KDate , ascending: true)
        if allLocalMessages .isEmpty {
            checkForOldMessage()
        }
        notificationToken = allLocalMessages.observe({(change :RealmCollectionChange) in
            
            switch change {
            case .initial :
                self.insertMKMessages()
                self.messagesCollectionView.reloadData()
                self.messagesCollectionView.scrollToLastItem(animated: true)
                self.messagesCollectionView.scrollToBottom(animated: true)

                
            case .update(_, _ ,let insertions ,_) :
                for index in insertions{
                    self.insertMKMessage(localMessage:self.allLocalMessages[index])
                    self.messagesCollectionView.reloadData()
                    self.messagesCollectionView.scrollToLastItem(animated: false)
                    self.messagesCollectionView.scrollToBottom(animated: false)
                }
            case .error(let error) :
                print("error on new insertion ",error.localizedDescription)
            }
            
        })
        
    }
    // MARK: - insert Messages .
    private func insertMKMessage(localMessage: LocalMessage){
        markMessageAsRead(localMessage)
        let incoming = Incoming(messageViewController: self)
        let mkMessages = incoming.createMKMessage(localMessage: localMessage)
        self.mkMessages.append(mkMessages)
        displayingMessageCount += 1
    }
    private func insertOlderMKMessage(localMessage: LocalMessage){
        let incoming = Incoming(messageViewController: self)
        let mkMessage = incoming.createMKMessage(localMessage: localMessage)
        self.mkMessages.insert(mkMessage, at: 0)
        displayingMessageCount += 1
    }
    
    private func insertMKMessages(){
        maxMessageNumber = allLocalMessages.count - displayingMessageCount
        minMessageNumber = maxMessageNumber - KNumberOfMessages
        if minMessageNumber < 0 {
            minMessageNumber = 0
        }
        for i in minMessageNumber ..< maxMessageNumber{
            insertMKMessage(localMessage: allLocalMessages[i])
        }
        
    }
    private func insertMoreMKMessages(){
        maxMessageNumber = minMessageNumber - 1
        minMessageNumber = maxMessageNumber - KNumberOfMessages
        if minMessageNumber < 0 {
            minMessageNumber = 0
        }
        for i in (minMessageNumber ... maxMessageNumber).reversed(){
            insertOlderMKMessage(localMessage: allLocalMessages[i])
        }
        
    }
    
    private func checkForOldMessage (){
        FMessageListener.shared.checkForOldMessage(User.currentId, collectionId: chatId)
    }
    private func checkForNewMessage (){
        FMessageListener.shared.listenForNewMessage(User.currentId, collectionId: chatId, lastMessageDate: lastMessageDate())
    }
    private func lastMessageDate ()-> Date {
        let lastMessageDate = allLocalMessages.last?.date ?? Date()
        return Calendar.current.date(byAdding: .second, value: 1, to: lastMessageDate) ?? lastMessageDate
    }
    private func removeListener(){
        FTypingListener.shared.removeTypingListener()
        FMessageListener .shared.removeNewMessageListener()
        
    }
    

}
extension MessageViewController {
    // MARK: - attaching Button.
    private func actionAttachMessage (){
        messageInputBar.inputTextView.resignFirstResponder()
        let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let takePhotoOrVideo = UIAlertAction(title: "Camera", style: .default) { (alert) in
            self.showImageGallary(camera: true)
        }
        let shareMedia = UIAlertAction(title: "Library", style: .default) { (alert) in
            self.showImageGallary(camera: false)
        }
        let shareLocation = UIAlertAction(title: "Show Location", style: .default) { (alert) in
            if let _ = LocationManger.shared.currentLocation {
                self.send(text: nil, photo: nil, video: nil, audio: nil, location: KLOCATION)
            }

        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        takePhotoOrVideo.setValue(UIImage(systemName: "camera"), forKey: "image")
        shareMedia.setValue(UIImage(systemName: "photo.fill"), forKey: "image")
        shareLocation.setValue(UIImage(systemName: "mappin.and.ellipse"), forKey: "image")

        optionMenu.addAction(takePhotoOrVideo)
        optionMenu.addAction(shareMedia)
        optionMenu.addAction(shareLocation)
        optionMenu.addAction(cancelAction)
        self.present(optionMenu, animated: true)

        
    }
    // MARK: -  show gallary .
    private func showImageGallary(camera:Bool){
        gallary = GalleryController()
        gallary.delegate = self
        Config.tabsToShow = camera ? [.cameraTab] : [.imageTab , .videoTab]
        Config.Camera.imageLimit = 1
        Config.initialTab = .imageTab
        Config.VideoEditor.maximumDuration = 150
        self.present(gallary, animated: true)
    }


}
extension MessageViewController:GalleryControllerDelegate {
    func galleryController(_ controller: Gallery.GalleryController, didSelectImages images: [Gallery.Image]) {
        
        // TODO: - send photo image.
        print("we have selected \(images.count)")
        if images.count > 0 {
            images.first?.resolve(completion: { (image) in
                self.send(text: nil, photo: image, video: nil, audio: nil, location: nil)
            })
        }
         
        
        controller.dismiss(animated: true)
    }
    
    func galleryController(_ controller: Gallery.GalleryController, didSelectVideo video: Gallery.Video) {
        self.send(text: nil, photo: nil, video: video, audio: nil, location: nil)
        
        controller.dismiss(animated: true)

    }
    
    func galleryController(_ controller: Gallery.GalleryController, requestLightbox images: [Gallery.Image]) {
        controller.dismiss(animated: true)

    }
    
    func galleryControllerDidCancel(_ controller: Gallery.GalleryController) {
        controller.dismiss(animated: true)

    }
    
    
}
