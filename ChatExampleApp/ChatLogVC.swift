//
//  ChatLogVC.swift
//  ChatExampleApp
//
//  Created by dmss on 18/11/16.
//  Copyright © 2016 pranith. All rights reserved.
//

import UIKit
import Firebase

class ChatLogVC: UICollectionViewController,UITextFieldDelegate,UICollectionViewDelegateFlowLayout,UIImagePickerControllerDelegate,UINavigationControllerDelegate,imageZoomingDelegate
{
    
    let cellId = "CellID"
    
    lazy var  chatTxtFiled : UITextField  = {
        let txtFiled = UITextField()
        txtFiled.translatesAutoresizingMaskIntoConstraints = false
        txtFiled.placeholder = "Enter Message..."
        txtFiled.delegate = self
        return txtFiled
    }()
    var messages = [Message]()
    
    var user: User? {
        didSet {
            
            navigationItem.title = user?.name
            observeMessages()
        }
    }
    
    func observeMessages()
    {
        guard let uid = FIRAuth.auth()?.currentUser?.uid,let toId = user?.id else {
            return
        }
        
        let userMsgRef = FIRDatabase.database().reference().child("user-messages").child(uid).child(toId)
        userMsgRef.observe(.childAdded, with: { (snapshot) in
    
            let messageId = snapshot.key
            let messageRef = FIRDatabase.database().reference().child("messages").child(messageId)
            messageRef.observe(.value, with: { (msgSnapchat) in
    
                guard let msgDic = msgSnapchat.value as? [String : AnyObject] else{
                    return
                }
                let message = Message(dic: msgDic)
                //it may crash if key's are not same
//                message.setValuesForKeys(msgDic)//No need..we are implementend custome init in Message Class
//                if message.chatPartnerID() == self.user?.id//Dont Need from 05-12-2016, we changed database structure
//                {
//                    
//                }
//                
              
                self.messages.append(message)
                DispatchQueue.main.async {
                    
                    self.collectionView?.reloadData()
    
                    let indexPath = IndexPath(item: self.messages.count - 1, section: 0)
                    self.collectionView?.scrollToItem(at: indexPath as IndexPath, at: .bottom, animated: true)
                }
                
                }, withCancel: nil)
            }) { (error) in
                print("----<error>--------")
        }
        
    }

    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        collectionView?.keyboardDismissMode = .interactive
        
        collectionView?.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 58, right: 0) //50 is bottomview height
        collectionView?.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: 50, right: 0)
        collectionView?.backgroundColor = UIColor.white
        collectionView?.register(ChatLogCVCell.self, forCellWithReuseIdentifier: cellId)
       // setUpBottomView()
        setUpKeyboardObserver()
    }
    override func viewDidDisappear(_ animated: Bool) {
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardDidShow, object: nil)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        
        collectionView?.collectionViewLayout.invalidateLayout()
    }
   lazy  var containerVw: UIView = {
        let containerVw = UIView()
        containerVw.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 50)
        containerVw.backgroundColor = UIColor.white
        
        return containerVw
    }()
    override var inputAccessoryView: UIView?
    {
        get{
          
            //Need x,y, width, height
            let sendBtn = UIButton(type: .system)
            sendBtn.translatesAutoresizingMaskIntoConstraints = false
            sendBtn.setTitle("Send", for: .normal)
            sendBtn.addTarget(self, action: #selector(handleSend), for: .touchUpInside)
            containerVw.addSubview(sendBtn)
            //Need x,y, width, heigh
            sendBtn.rightAnchor.constraint(equalTo: containerVw.rightAnchor, constant: -10).isActive = true
            sendBtn.centerYAnchor.constraint(equalTo: containerVw.centerYAnchor).isActive = true
            sendBtn.widthAnchor.constraint(equalToConstant: 80).isActive = true
            sendBtn.heightAnchor.constraint(equalTo: containerVw.heightAnchor).isActive = true
            
            
            //File Attachements
            let attachementsImgVw = UIImageView()
            attachementsImgVw.isUserInteractionEnabled = true
            attachementsImgVw.image = UIImage(named: "attachements_Icon")
            attachementsImgVw.translatesAutoresizingMaskIntoConstraints = false
            attachementsImgVw.contentMode = .scaleToFill
            attachementsImgVw.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.handleAttachmentTouch)))
            containerVw.addSubview(attachementsImgVw)
            
            attachementsImgVw.leftAnchor.constraint(equalTo: containerVw.leftAnchor, constant: 8).isActive = true
            attachementsImgVw.centerYAnchor.constraint(equalTo: containerVw.centerYAnchor).isActive = true
            attachementsImgVw.widthAnchor.constraint(equalToConstant: 22).isActive = true
            attachementsImgVw.heightAnchor.constraint(equalToConstant: 22).isActive = true
            
            containerVw.addSubview(chatTxtFiled)
            
            //Need x,y, width, height
            
            chatTxtFiled.leftAnchor.constraint(equalTo: attachementsImgVw.rightAnchor, constant: 8).isActive = true
            chatTxtFiled.rightAnchor.constraint(equalTo: sendBtn.leftAnchor, constant: -115).isActive = true
            chatTxtFiled.topAnchor.constraint(equalTo: containerVw.topAnchor).isActive = true
            chatTxtFiled.heightAnchor.constraint(equalTo: containerVw.heightAnchor).isActive = true
            
            
            //separator line.
            let lineLbl = UILabel()
            lineLbl.backgroundColor = UIColor.lightGray
            lineLbl.translatesAutoresizingMaskIntoConstraints = false
            containerVw.addSubview(lineLbl)
            
            lineLbl.leftAnchor.constraint(equalTo: containerVw.leftAnchor).isActive = true
            lineLbl.rightAnchor.constraint(equalTo: containerVw.rightAnchor).isActive = true
            lineLbl.topAnchor.constraint(equalTo: containerVw.topAnchor).isActive = true
            lineLbl.heightAnchor.constraint(equalToConstant: 1).isActive = true
            
            return containerVw
        }
    }
    override var canBecomeFirstResponder: Bool
        {
        get{
            return true
        }
    }
    func setUpKeyboardObserver()
    {
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardDidShow), name: .UIKeyboardDidShow, object: nil)
    }
    func handleKeyboardDidShow(notification: NSNotification)
    {
       
        if messages.count - 1 > 0
        {
            let indexpath = IndexPath(item: messages.count - 1, section: 0)
            print("Count : \(messages.count) and  indexPath : \(indexpath)")
           // collectionView?.scrollToItem(at: indexpath, at: .top, animated: true)
        }
        
    }
    func handleAttachmentTouch()
    {
        let imagePickerController = UIImagePickerController()
        //Default Type is PhotoGallery
        imagePickerController.allowsEditing = true
        imagePickerController.delegate = self
        present(imagePickerController, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        print("we selected Image")
        var selectedImageFromPicker: UIImage?
        if let editedImage = info["UIImagePickerControllerEditedImage"] as? UIImage
        {
            selectedImageFromPicker = editedImage
        }else if let orginalImage = info["UIImagePickerControllerOrginalImage"] as? UIImage
        {
            selectedImageFromPicker = orginalImage
        }
        
        if let selectedImage = selectedImageFromPicker
        {
            uploadImageToFirbase(image: selectedImage)
        }
        dismiss(animated: true, completion: nil)
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        
        print("Cancelled")
        dismiss(animated: true, completion: nil)

    }
    
    private func uploadImageToFirbase(image: UIImage)
    {
        let imageName = NSUUID().uuidString
        let ref = FIRStorage.storage().reference().child("messages-images").child(imageName)
        
        if let uploadData = UIImageJPEGRepresentation(image, 0.2)
        {
            ref.put(uploadData, metadata: nil, completion: { (metaData, error) in
                
                if error != nil
                {
                    print("failed to upload to Firbase \(error)")
                    return
                }
                
             //   print(metaData?.downloadURL()?.absoluteString)
                if let imageURL = metaData?.downloadURL()?.absoluteString
                {
                    self.sendMessageWithImageURL(imageURL: imageURL, image: image)
                }
            })
        }
    }
    
    
    func setUpBottomView()
    {
        let bottomVw = UIView()
        bottomVw.translatesAutoresizingMaskIntoConstraints = false
        bottomVw.backgroundColor = UIColor.white
        self.view.addSubview(bottomVw)
        //Need x,y, width, height
        
        bottomVw.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        bottomVw.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        bottomVw.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        bottomVw.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
    
        
        
        //Need x,y, width, height
        let sendBtn = UIButton(type: .system)
        sendBtn.translatesAutoresizingMaskIntoConstraints = false
        sendBtn.setTitle("Send", for: .normal)
        sendBtn.addTarget(self, action: #selector(handleSend), for: .touchUpInside)
        bottomVw.addSubview(sendBtn)
         //Need x,y, width, heigh
        sendBtn.rightAnchor.constraint(equalTo: bottomVw.rightAnchor, constant: -10).isActive = true
        sendBtn.centerYAnchor.constraint(equalTo: bottomVw.centerYAnchor).isActive = true
        sendBtn.widthAnchor.constraint(equalToConstant: 80).isActive = true
        sendBtn.heightAnchor.constraint(equalTo: bottomVw.heightAnchor).isActive = true
        
       
        
        
        bottomVw.addSubview(chatTxtFiled)
        
        //Need x,y, width, height
        
        chatTxtFiled.leftAnchor.constraint(equalTo: bottomVw.leftAnchor, constant: 12).isActive = true
        chatTxtFiled.rightAnchor.constraint(equalTo: sendBtn.leftAnchor, constant: -115).isActive = true
        chatTxtFiled.topAnchor.constraint(equalTo: bottomVw.topAnchor).isActive = true
        chatTxtFiled.heightAnchor.constraint(equalTo: bottomVw.heightAnchor).isActive = true
        
        
        //separator line.
        let lineLbl = UILabel()
        lineLbl.backgroundColor = UIColor.lightGray
        lineLbl.translatesAutoresizingMaskIntoConstraints = false
        bottomVw.addSubview(lineLbl)
        
        lineLbl.leftAnchor.constraint(equalTo: bottomVw.leftAnchor).isActive = true
        lineLbl.rightAnchor.constraint(equalTo: bottomVw.rightAnchor).isActive = true
        lineLbl.topAnchor.constraint(equalTo: bottomVw.topAnchor).isActive = true
        lineLbl.heightAnchor.constraint(equalToConstant: 1).isActive = true
    }
    
    func handleSend()
    {
        guard let txt = chatTxtFiled.text else {
            return
        }
        
        sendMessageWithProperties(properties: ["text": txt])
        
        chatTxtFiled.text = ""
       // NSCalendar
    }
    private func sendMessageWithImageURL(imageURL : String , image: UIImage)
    {
        let properties: [String: Any] = ["imageURL": imageURL,"imageWidth": image.size.width ,"imageHeight": image.size.height]
        sendMessageWithProperties(properties: properties)
        
    }
    private func sendMessageWithProperties(properties: [String: Any])
    {
        let ref = FIRDatabase.database().reference().child("messages")
        let childRef = ref.childByAutoId()
        let toId = user!.id!
        let fromId = FIRAuth.auth()!.currentUser!.uid
        let timestamp: NSNumber = NSNumber.init(value: Int(NSDate().timeIntervalSince1970))
       // let values  = ["imageURL": imageURL,"toId": toId , "fromId": fromId , "timestamp" : timestamp , "imageWidth": image.size.width ,"imageHeight": image.size.height] as [String : Any]
        
        var values: [String: Any]  = ["toId": toId , "fromId": fromId , "timestamp" : timestamp]
        //Need to append propertie values to values dic
        //Z$0 is key
        //$1 is value
        properties.forEach{ values[$0] = $1
        }
        //    childRef.updateChildValues(values)
        childRef.updateChildValues(values) { (error, ref) in
            if error != nil
            {
                print(error)
            }
            
        }
        
        let userMessagesRef = FIRDatabase.database().reference().child("user-messages").child(fromId).child(toId)
        let messageId = childRef.key
        userMessagesRef.updateChildValues([messageId:1])
        
        let recipentUserMessagesRef = FIRDatabase.database().reference().child("user-messages").child(toId).child(fromId)
        recipentUserMessagesRef.updateChildValues([messageId:1])
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    // MARK: - textFiled Delegates
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        handleSend()
        return true
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        
        return messages.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! ChatLogCVCell
        let message = messages[indexPath.row]
        cell.chatTxtVw.text = message.text
        cell.delegate = self
        //cell.bubbleVwWidthAnchor?.constant = 50
        setUpCell(cell: cell, message: message)
        
        return cell
        
    }
    private func setUpCell(cell: ChatLogCVCell , message: Message)
    {
        if message.fromId == FIRAuth.auth()?.currentUser?.uid
        {
            //outMessage Blue
            cell.bubbleVw.backgroundColor = blueColor
            cell.chatTxtVw.textColor = UIColor.white
            
            cell.profileImgVw.isHidden = true
            
            cell.bubbleVwRightAnchor?.isActive = true
            cell.bubbleVwLeftAnchor?.isActive = false
            
        }else
        {
            //inMessage Gray
            cell.bubbleVw.backgroundColor = lightGreyColor
            cell.chatTxtVw.textColor = UIColor.black
            
            cell.profileImgVw.isHidden = false
            
            cell.bubbleVwRightAnchor?.isActive = false
            cell.bubbleVwLeftAnchor?.isActive = true
    
        }
        
        if let text = message.text
        {
            cell.bubbleVwWidthAnchor?.constant = estimatedFrameForText(text: text).width + 32
        }else if message.imageURL != nil
        {
            cell.bubbleVwWidthAnchor?.constant = 200
        }
        
        if let imageUrl = message.imageURL
        {
            cell.messageImgVw.loadImageUsingCacheUrlString(urlString: imageUrl)
            cell.messageImgVw.isHidden = false
            cell.chatTxtVw.isHidden = true
            cell.bubbleVw.backgroundColor = UIColor.clear
        }else
        {
            cell.messageImgVw.isHidden = true
            cell.chatTxtVw.isHidden = false
            cell.bubbleVw.backgroundColor = blueColor
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        var height : CGFloat = 80
        let message = messages[indexPath.item]
        if let text = message.text
        {
            height = estimatedFrameForText(text: text).height + 20
        }else if let imageWidth = message.imageWidth?.floatValue , let imageHeight = message.imageHeight?.floatValue
        {
            //h1/w1 = h2/w2 we need h1
            //h1 = h2*w1/w2
            height = CGFloat(imageHeight / imageWidth * 200)  //width of bubbleview
        }
        let width = UIScreen.main.bounds.width
        return CGSize(width: width, height: height)
    }
    private func estimatedFrameForText(text: String) -> CGRect
    {
        let size = CGSize(width: 200, height: 1000) //200 is textview height and 80 is view height and
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        return NSString(string: text).boundingRect(with: size, options: options, attributes: [NSFontAttributeName : UIFont.systemFont(ofSize: 16)], context: nil)
    }
    var startingFrame:CGRect?
    var blackBackgroudVw: UIView?
    var startingImgVw: UIImageView?
    
    func performZoomingForStartingImageView(startingImgVw : UIImageView)
    {
        self.startingImgVw = startingImgVw
        startingImgVw.isHidden = true
        startingFrame = startingImgVw.superview?.convert(startingImgVw.frame, to: nil)
        
   //     print("startingFrame: \(startingFrame)")
        let zoomingImgVw = UIImageView(frame: startingFrame!)
        zoomingImgVw.image = startingImgVw.image
        zoomingImgVw.isUserInteractionEnabled = true
        zoomingImgVw.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleZoomOut)))
        
        if let keyWindow = UIApplication.shared.keyWindow
        {
            blackBackgroudVw = UIView(frame: keyWindow.frame)
            blackBackgroudVw?.backgroundColor = UIColor.black
            blackBackgroudVw?.alpha = 0
            keyWindow.addSubview(blackBackgroudVw!)
            keyWindow.addSubview(zoomingImgVw)
            // h1/w1 = h2/w2
            // h1 = h2/ w2 * w1
            let height = startingFrame!.height / startingFrame!.width * keyWindow.frame.width
//            UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseOut, animations: {
//               
//            }, completion: nil)
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                self.blackBackgroudVw?.alpha = 1.0
                self.inputAccessoryView?.alpha = 0
                zoomingImgVw.frame = CGRect(x: 0, y: 0, width: keyWindow.frame.width, height: height)
                zoomingImgVw.center = keyWindow.center
            }, completion: { (completed: Bool) in
                //Nothing to do
            })
        }
        
    }
    func handleZoomOut(tapGesture: UITapGestureRecognizer)
    {
        if let zoomingOutVw = tapGesture.view
        {
            zoomingOutVw.layer.cornerRadius = 16
            zoomingOutVw.layer.masksToBounds = true
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: { 
                //
                zoomingOutVw.frame = self.startingFrame!
                self.blackBackgroudVw?.alpha = 0
                self.inputAccessoryView?.alpha = 1.0
            }, completion: { (completed: Bool) in
                zoomingOutVw.removeFromSuperview()
                self.startingImgVw?.isHidden = false
                
            })
            
           
            
        }
    }
}
