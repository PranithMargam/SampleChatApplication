//
//  ChatListTVCell.swift
//  ChatExampleApp
//
//  Created by dmss on 24/11/16.
//  Copyright © 2016 pranith. All rights reserved.
//

import UIKit
import Firebase

class ChatListTVCell: UITableViewCell {

    var message : Message?  {
        didSet {
            //  let cell = UITableViewCell(style: .subtitle, reuseIdentifier: cellId)
            // Configure the cell...
            
            
            if let id = message?.chatPartnerID()
            {
                let ref = FIRDatabase.database().reference().child("users").child(id)
                
                ref.observe(.value, with: { (snapchat) in
                    
                        if let userDic = snapchat.value as? [String: Any]
                        {
                        let user = User()
                        user.setValuesForKeys(userDic)
                        self.textLabel?.text = user.name
                        }
                    }, withCancel: nil)
                
                
            }
            detailTextLabel?.text = message?.text//text
            if let seconds = message?.timestamp?.doubleValue
            {
                let date = NSDate(timeIntervalSince1970: seconds)
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "hh:mm:ss a"
                timeStampLbl.text = dateFormatter.string(from: date as Date)
            }
            
        }
    }
    let profileImageVw : UIImageView = {
        
        let imgVw = UIImageView()
        imgVw.backgroundColor = UIColor.darkGray
        imgVw.translatesAutoresizingMaskIntoConstraints = false
        imgVw.layer.cornerRadius = 24
        imgVw.layer.masksToBounds = true
        imgVw.contentMode = .scaleAspectFill
        return imgVw
    }()
    
    let timeStampLbl : UILabel = {
        
        let lbl = UILabel()
        lbl.text = ""
        lbl.font = UIFont.systemFont(ofSize: 12)
        lbl.textColor = UIColor.darkGray
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
     override init(style: UITableViewCellStyle, reuseIdentifier: String?)
    {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        
        addSubview(profileImageVw)
        addSubview(timeStampLbl)
        
        //Need X,Y,Width,Height
        profileImageVw.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 5).isActive = true
        profileImageVw.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        profileImageVw.widthAnchor.constraint(equalToConstant: 48).isActive = true
        profileImageVw.heightAnchor.constraint(equalToConstant: 48).isActive = true
        
        //Need X,Y,Width,Height
        timeStampLbl.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        timeStampLbl.topAnchor.constraint(equalTo: self.topAnchor, constant: 10).isActive = true
        timeStampLbl.widthAnchor.constraint(equalToConstant: 100).isActive = true
        timeStampLbl.heightAnchor.constraint(equalTo: (textLabel?.heightAnchor)!).isActive = true
    }
  
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews()
    {
        super.layoutSubviews()
        textLabel?.frame = CGRect(x: 64, y: (textLabel?.frame.origin.y)! - 2, width: (textLabel?.frame.size.width)!, height: (textLabel?.frame.size.height)!)
        detailTextLabel?.frame = CGRect(x: 64, y: (detailTextLabel?.frame.origin.y)! + 2, width: (detailTextLabel?.frame.size.width)!, height: (detailTextLabel?.frame.size.height)!)
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
