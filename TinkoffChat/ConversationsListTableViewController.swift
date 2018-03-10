//
//  ConversationsListTableViewController.swift
//  TinkoffChat
//
//  Created by Александр Лыков on 10.03.2018.
//  Copyright © 2018 Lykov. All rights reserved.
//

import UIKit

class ConversationsListTableViewController: UITableViewController {

    @IBOutlet weak var barButton: UIButton!
    
    private var conversations: [SectionsNames: [ConversationCellModel]] = [.Online: [ConversationCellModel](), .Offline: [ConversationCellModel]()]
    
    enum SectionsNames: String {
        case Online = "Онлайн", Offline = "Офлайн"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let boolArray = [true,false,true,true]
        outerloop: for status in boolArray {
            for readStatus in boolArray.reversed() {
                if let newChat = ConversationCellModel.getNewConversation(online: status, andNotRead: readStatus) {
                    newChat.online ? conversations[.Online]!.append(newChat): conversations[.Offline]!.append(newChat)
                } else {
                    break outerloop
                }
            }
        }
        
        conversations[.Online]!.sort {$0.date! > $1.date!}
        conversations[.Offline]!.sort {$0.date! > $1.date!}
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        let height = self.navigationController!.navigationBar.frame.size.height / CGFloat(2).squareRoot()
        barButton.widthAnchor.constraint(equalToConstant: height).isActive = true
        barButton.heightAnchor.constraint(equalToConstant: height).isActive = true
        barButton.layer.masksToBounds = true
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: barButton)
        
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        barButton.layer.cornerRadius = barButton.frame.width / 2.0
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return conversations.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? conversations[.Online]!.count : conversations[.Offline]!.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell: ConversationTableViewCell
        if let dequeuedCell = tableView.dequeueReusableCell(withIdentifier: "conversationIdentifier", for: indexPath) as? ConversationTableViewCell {
            cell = dequeuedCell
        } else {
            cell = ConversationTableViewCell()
        }
        let cellData = indexPath.section == 0 ? conversations[.Online]![indexPath.row] : conversations[.Offline]![indexPath.row]
        
        cell.name = cellData.name
        cell.message = cellData.message
        cell.date = cellData.date
        cell.hasUnreadMessages = cellData.hasUnreadMessages
        cell.online = cellData.online

        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section == 0 ? SectionsNames.Online.rawValue : SectionsNames.Offline.rawValue
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
