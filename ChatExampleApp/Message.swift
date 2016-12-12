//
//  Message.swift
//  ChatExampleApp
//
//  Created by dmss on 23/11/16.
//  Copyright © 2016 pranith. All rights reserved.
//

import UIKit
import Firebase
class Message: NSObject
{
    var text : String?
    var fromId: String?
    var toId: String?
    var timestamp: NSNumber?
    
    var imageURL : String?
    var imageWidth: NSNumber?
    var imageHeight: NSNumber?
    
    
    func chatPartnerID() -> String
    {
        return (fromId == FIRAuth.auth()?.currentUser?.uid ? toId : fromId)!
    }
    
    init(dic: [String: AnyObject])
    {
        super.init()
        
        fromId = dic["fromId"] as? String
        toId = dic["toId"] as? String
        text = dic["text"] as? String
        timestamp = dic["timestamp"] as? NSNumber
        imageURL = dic["imageURL"] as? String
        imageWidth = dic["imageWidth"] as? NSNumber
        imageHeight = dic["imageHeight"] as? NSNumber
        
        
    }
    
}
