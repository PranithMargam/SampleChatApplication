//
//  ChatListVC.swift
//  ChatExampleApp
//
//  Created by dmss on 17/11/16.
//  Copyright © 2016 pranith. All rights reserved.
//

import UIKit
import Firebase

class ChatListVC: UITableViewController,communicationDelegate,loginDelegate
{
    let cellId = "CellId"
    var messages = [Message]()
    var messageDic = [String: Message]()
    var timer : Timer?
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(handleSearchForUsers))
        
        tableView.register(ChatListTVCell.self , forCellReuseIdentifier: cellId)
        tableView.separatorColor = UIColor.clear
        tableView.allowsMultipleSelectionDuringEditing = true
        checkUserLoginStatus()
      //  loadMessages()
      //  loadUserMessages() //It Should be after checking current user status
    }
    func loadUserMessages()
    {
        guard let uId = FIRAuth.auth()?.currentUser?.uid else {
            return
        }
        let ref = FIRDatabase.database().reference().child("user-messages").child(uId)
        
        ref.observe(.childAdded, with: { (snapchat) in
            let userId = snapchat.key
            FIRDatabase.database().reference().child("user-messages").child(uId).child(userId).observe(.childAdded, with: { (Msgsnapchat) in
                //
                let messageId = Msgsnapchat.key
                self.fetchMessageWithMessagaID(messageId: messageId)
            }, withCancel: nil)
        }, withCancel: nil)
        
        ref.observe(.childRemoved, with: {(snapchot) in
            //
            print(snapchot.key)
        
            self.messageDic.removeValue(forKey: snapchot.key)
            self.attemptRelodOfTable()
            
        }, withCancel: nil)
        
    }
    
   private func fetchMessageWithMessagaID(messageId : String)
    {
        let mesagesRef = FIRDatabase.database().reference().child("messages").child(messageId)
        mesagesRef.observeSingleEvent(of: .value, with: { (messageSnapChat) in
            
            if let messageDic  = messageSnapChat.value as? [String: AnyObject]
            {
                let message = Message(dic: messageDic)
                //message.setValuesForKeys(messageDic) //No need..we are implementend custome init in Message Class
                // self.messages.append(message)
                let chatPartnerId = message.chatPartnerID()
                
                self.messageDic[chatPartnerId] = message
               
                
                self.attemptRelodOfTable()
                
            }
            
        }, withCancel: nil)
    }
    
    private func attemptRelodOfTable()
    {
        self.messages = Array(self.messageDic.values)
        self.messages.sort(by: { (message1, message2) -> Bool in
            return (message1.timestamp?.intValue)! > (message2.timestamp?.intValue)!
        })
        
        self.timer?.invalidate()
        self.timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(self.handleReloadTable), userInfo: nil, repeats: false)
    }
    func handleReloadTable()
    {
     //   print("handleReloadTable")
        DispatchQueue.main.async
            {
                self.tableView.reloadData()
        }
    }
    func loadMessages()
    {
        let ref = FIRDatabase.database().reference().child("messages")
        ref.observe(.childAdded, with:
            { (snapchat) in
                //
                
                if let messageDic  = snapchat.value as? [String: AnyObject]
                {
                    let message = Message(dic: messageDic)
                 //   message.setValuesForKeys(messageDic)////No need..we are implementend custome init in Message Class
                    // self.messages.append(message)
                    let chatPatnerId = message.chatPartnerID()
                    
                    self.messageDic[chatPatnerId] = message
                    self.messages = Array(self.messageDic.values)
                    //                        self.messages.sort(by: { (message1, message2) -> Bool in
                    //
                    //                            return (message1.timestamp?.intValue)! > (message2.timestamp?.intValue)!
                    //                        })
                    
                    DispatchQueue.main.async
                        {
                            self.tableView.reloadData()
                    }
                }
                
                
        }, withCancel: nil)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func  checkUserLoginStatus()
    {
        let uid = FIRAuth.auth()?.currentUser?.uid
        if uid == nil
        {
            self.perform(#selector(handleSignOut), with: nil, afterDelay: 0)
        }else
        {
            fetchUsersAndSetUpData()
        }

    }
    
    func fetchUsersAndSetUpData()
    {
        
        let uid = FIRAuth.auth()?.currentUser?.uid
        FIRDatabase.database().reference().child("users").child(uid!).observe(.value, with: { (snapshot) in
            
            if let userDetailDic = snapshot.value as? [String : AnyObject]
            {
                let user = User()
                user.setValuesForKeys(userDetailDic)
                self.setUpNavBarWithUser(user: user)
                
            }
            
            }, withCancel: { (error) in
                
                print("failed to get details with error: \(error)")
        })

    }
    func setUpNavBarWithUser(user: User)
    {
        messages.removeAll()
        messageDic.removeAll()
        tableView.reloadData()
        loadUserMessages()
        
        
        let titleVw = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 30))
        
        // self.navigationItem.title = userDetailDic["name"] as? String
        
        let nameLabel = UILabel()
        
        nameLabel.frame = titleVw.bounds
        titleVw.addSubview(nameLabel)
        //                    nameLabel.centerXAnchor.constraint(equalTo: titleVw.centerXAnchor)
        //                    nameLabel.centerYAnchor.constraint(equalTo: titleVw.centerYAnchor)
        nameLabel.text = user.name
        nameLabel.textColor = UIColor.black
        nameLabel.textAlignment = .center
        titleVw.backgroundColor = UIColor.clear
        //                    titleVw.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.handleTitleViewGesture)))
        self.navigationItem.titleView = titleVw
    }
    
    func showChatViewControllerForUser(user: User)
    {
        let chatLogVC = ChatLogVC(collectionViewLayout: UICollectionViewFlowLayout())
        chatLogVC.user = user
        navigationController?.pushViewController(chatLogVC, animated: true)
        
        
    }
    func handleSearchForUsers()
    {
        let chatListVC = NewChatListVC()
        chatListVC.delegate = self
        let navVC = UINavigationController(rootViewController: chatListVC)
        self.present(navVC, animated: true, completion: nil)
        
    }
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return messages.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! ChatListTVCell
        cell.message = messages[indexPath.row]
     
 
        return cell
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        
        return 72.0
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        
        let message = messages[indexPath.row]
        
         let chatPartnerID = message.chatPartnerID()
        
        let ref = FIRDatabase.database().reference().child("users").child(chatPartnerID)
        ref.observe(.value, with: { (snapchat) in
            
            if let userDic = snapchat.value as? [String : AnyObject]
            {
                let user = User()
                user.id = chatPartnerID
                user.setValuesForKeys(userDic)
                self.showChatViewControllerForUser(user: user)
            }
            }, withCancel: nil)

    }
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        guard let uid  = FIRAuth.auth()?.currentUser?.uid else {
            return
        }
        let messsage = self.messages[indexPath.row]
        
        FIRDatabase.database().reference().child("user-messages").child(uid).child(messsage.chatPartnerID()).removeValue { (error, ref) in
            
            if error != nil
            {
                print("failed to delete message with error:\(error?.localizedDescription)")
                return
            }
            self.messageDic.removeValue(forKey: messsage.chatPartnerID())
            self.attemptRelodOfTable()
            
//            //This is one way of deleteing table but not actually safe...(becaues we are handling table with Messagedic Variable not with Messages varibale
//            self.messages.remove(at: indexPath.row)
//            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
        
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

   @IBAction func signOutBtnTouch(sender: AnyObject)
    {
        handleSignOut()
    }
    func handleSignOut()
    {
        do
        {
            try FIRAuth.auth()?.signOut()
        }catch let signOutErr
        {
            print("failed to SignOut with error:\(signOutErr)")
        }
        
        let firstVC = FirstVC()
        firstVC.delegate = self
        self.present(firstVC, animated: true, completion: nil)
    }
    func  goToChatVCForUser(user: User)
    {
        showChatViewControllerForUser(user: user)
    }
}
