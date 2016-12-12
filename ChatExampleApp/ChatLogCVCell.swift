//
//  ChatLogCVCell.swift
//  ChatExampleApp
//
//  Created by dmss on 29/11/16.
//  Copyright © 2016 pranith. All rights reserved.
//

import UIKit
protocol imageZoomingDelegate
{
    func performZoomingForStartingImageView(startingImgVw : UIImageView)
}
class ChatLogCVCell: UICollectionViewCell {
    
    var  delegate: imageZoomingDelegate? = nil
    let chatTxtVw : UITextView = {
       
        let tv = UITextView()
        tv.text = "Sample Text View"
        tv.backgroundColor = UIColor.clear
        tv.font = UIFont.systemFont(ofSize: 16)
        tv.textColor = UIColor.white
        tv.isUserInteractionEnabled = false
        tv.translatesAutoresizingMaskIntoConstraints = false
        
        return tv
    }()
    let bubbleVw: UIView = {
       
        let vw = UIView()
        vw.backgroundColor = blueColor
        vw.layer.cornerRadius = 16
        vw.layer.masksToBounds = true
        vw.translatesAutoresizingMaskIntoConstraints = false
        return vw
    }()
    let profileImgVw : UIImageView = {
        
        let imgVw = UIImageView()
        imgVw.backgroundColor = UIColor.black
        imgVw.layer.cornerRadius = 16
        imgVw.layer.masksToBounds = true
        imgVw.translatesAutoresizingMaskIntoConstraints = false
        return imgVw

    }()
    
    let messageImgVw: UIImageView = {
        let imgVw = UIImageView()
        imgVw.layer.cornerRadius = 16
        imgVw.layer.masksToBounds = true
        imgVw.translatesAutoresizingMaskIntoConstraints = false
        imgVw.contentMode = .scaleAspectFill
//        imgVw.isUserInteractionEnabled = true //Here not coming need to check.........
//        imgVw.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleZoopTap)))
        return imgVw

    }()
    
    func handleZoopTap(tapGesture : UITapGestureRecognizer)
    {
        //Pro Tip: dont perfom a lot of custome logic in Cell Classes
        if let imageVw = tapGesture.view as? UIImageView
        {
            delegate?.performZoomingForStartingImageView(startingImgVw: imageVw)
        }
        
    }
    var bubbleVwWidthAnchor : NSLayoutConstraint?
    var bubbleVwRightAnchor: NSLayoutConstraint?
    var bubbleVwLeftAnchor: NSLayoutConstraint?
    
    override  init(frame: CGRect) {
        super.init(frame: frame)

        addSubview(bubbleVw)
        addSubview(chatTxtVw)
        addSubview(profileImgVw)
        
        messageImgVw.isUserInteractionEnabled = true
        messageImgVw.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleZoopTap)))
        bubbleVw.addSubview(messageImgVw)
        //  chatTxtVw.backgroundColor = UIColor.blue
        //Need x,y,Width,Height
        messageImgVw.leftAnchor.constraint(equalTo: bubbleVw.leftAnchor).isActive = true
        messageImgVw.topAnchor.constraint(equalTo: bubbleVw.topAnchor).isActive = true
        messageImgVw.widthAnchor.constraint(equalTo: bubbleVw.widthAnchor).isActive = true
        messageImgVw.heightAnchor.constraint(equalTo: bubbleVw.heightAnchor).isActive = true
        
        //Need x,y,Width,Height
        profileImgVw.leftAnchor.constraint(equalTo: leftAnchor, constant: 8).isActive = true
        profileImgVw.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        profileImgVw.widthAnchor.constraint(equalToConstant: 32).isActive = true
        profileImgVw.heightAnchor.constraint(equalToConstant: 32).isActive = true
        //Need x,y,Width,Height
        //   bubbleVw.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        bubbleVwRightAnchor = bubbleVw.rightAnchor.constraint(equalTo: rightAnchor, constant: -8)
        bubbleVwRightAnchor?.isActive = true
        
        bubbleVwLeftAnchor = bubbleVw.leftAnchor.constraint(equalTo: profileImgVw.rightAnchor, constant: 4)
     //   bubbleVwLeftAnchor?.isActive = false //No Need by defalut it is false
        
        
        bubbleVw.topAnchor.constraint(equalTo: topAnchor).isActive = true
        bubbleVwWidthAnchor = bubbleVw.widthAnchor.constraint(equalToConstant: 200)
        bubbleVwWidthAnchor?.isActive = true
        bubbleVw.heightAnchor.constraint(equalTo: heightAnchor).isActive = true
        
        //Need x,y,Width,Height
        //  chatTxtVw.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        chatTxtVw.leftAnchor.constraint(equalTo: bubbleVw.leftAnchor, constant: 8).isActive = true
        chatTxtVw.topAnchor.constraint(equalTo: topAnchor).isActive = true
        //chatTxtVw.widthAnchor.constraint(equalToConstant: 200).isActive = true
        chatTxtVw.rightAnchor.constraint(equalTo: bubbleVw.rightAnchor).isActive = true
        chatTxtVw.heightAnchor.constraint(equalTo: heightAnchor).isActive = true
        
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
