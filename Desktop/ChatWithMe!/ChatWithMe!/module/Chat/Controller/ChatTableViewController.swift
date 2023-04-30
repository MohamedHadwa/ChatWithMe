//
//  ChatTableViewController.swift
//  ChatWithMe!
//
//  Created by Mohamed Hadwa on 04/01/2023.
//

import UIKit

class ChatTableViewController: UITableViewController {
    // MARK: -  variables.
    let searchController = UISearchController(searchResultsController: nil)

    var allChatRooms :[ChatRoom] = []
    var filteredChatRooms :[ChatRoom] = []
    override func viewDidLoad() {
        
        super.viewDidLoad()
        tableView.tableFooterView = UIView()
        downloadChatRooms()
                navigationItem.searchController = searchController
                navigationItem.hidesSearchBarWhenScrolling = true
                searchController.obscuresBackgroundDuringPresentation = false
                searchController.searchBar.placeholder = "Search in Chats"
                searchController.searchResultsUpdater = self
    }
    // MARK: - IBaction.
    
    @IBAction func barEditBtn(_ sender: Any) {
        let showUsers = UIStoryboard(name: "Chat", bundle: nil).instantiateViewController(withIdentifier: "usersId") as! UsersTableViewController
        navigationController?.pushViewController(showUsers, animated: true)
    }
    
    
    // MARK: - Table view data source
    
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return searchController.isActive ? filteredChatRooms.count : allChatRooms.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "userCell", for: indexPath) as! ChatTableViewCell
     
        cell.configure(chatRoom: searchController.isActive ? filteredChatRooms[indexPath.row] :  allChatRooms[indexPath.row])
            return cell
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
        
    }
    // MARK: - delete funcs.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let chatRoom = searchController.isActive ? filteredChatRooms[indexPath.row] : allChatRooms[indexPath.row]
            FChatRoomListener.shared.deleteChat(chatRoom)
            searchController.isActive ? self.filteredChatRooms.remove(at: indexPath.row) : allChatRooms.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let chatRoomObject = searchController.isActive ? filteredChatRooms[indexPath.row] : allChatRooms[indexPath.row]
        
        goToChatRoom(chatRoom: chatRoomObject)
    }
    
    func downloadChatRooms(){
        FChatRoomListener.shared.downloadChatRooms { (allChat) in
            self.allChatRooms = allChat
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
        
    }
    // MARK: -  go to chat room .
    func goToChatRoom (chatRoom :ChatRoom){
        
        restartChat(chatroomId: chatRoom.chatRoomId, memberIds: chatRoom.memberIds)
        let PrivateMessageView = MessageViewController(chatId: chatRoom.chatRoomId, recipientId: chatRoom.reciverId, recipientName: chatRoom.reciverName)
        navigationController?.pushViewController(PrivateMessageView, animated: true)
    }

}

extension ChatTableViewController :UISearchResultsUpdating{
    func updateSearchResults(for searchController: UISearchController) {
        filteredChatRooms = allChatRooms.filter({ (chatRoom) ->Bool in
        return chatRoom.reciverName .lowercased().contains(searchController.searchBar.text!.lowercased())
    })
    tableView.reloadData()

    }
}
