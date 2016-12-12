//
//  Extensions.swift
//  ChatExampleApp
//
//  Created by dmss on 07/12/16.
//  Copyright © 2016 pranith. All rights reserved.
//

import UIKit
import Foundation


let imageCatche = NSCache<NSString, UIImage>()

extension UIImageView
{
    func loadImageUsingCacheUrlString(urlString: String)
    {
        self.image = nil
        
        //Check cache for image first
        if let cachedImage = imageCatche.object(forKey: urlString as NSString)
        {
                self.image = cachedImage
                return
        }
        let url = NSURL(string: urlString)
        
        URLSession.shared.dataTask(with: url! as URL){
            data,response,error  in
            
            if error != nil
            {
                print("fail to download Image from FB with error: \(error?.localizedDescription)")
                return
            }
            
            DispatchQueue.main.async {
                
                if let downloadedImage = UIImage(data: data!)
                {
                    imageCatche.setObject(downloadedImage, forKey: urlString as NSString)
                    self.image = downloadedImage
                }
            }
        }.resume()
    }
}
