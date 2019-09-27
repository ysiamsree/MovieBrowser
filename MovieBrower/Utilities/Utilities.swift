//
//  Utilities.swift
//  MovieBrower
//
//  Created by sreejith on 26/09/19.
//  Copyright © 2019 sreejith. All rights reserved.
//

import Foundation
import Alamofire

class Utilities {

    /// To check the reachability status. Will return 'true' if network is reachable.
    class  var isConnectedToInternet: Bool {
        return NetworkReachabilityManager()!.isReachable
    }
    
    class func toastMessage(_ message: String) {
        guard let window = UIApplication.shared.keyWindow else {return}
        let messageLbl = UILabel()
        messageLbl.text = message
        messageLbl.textColor = UIColor.white
        messageLbl.textAlignment = .center
        messageLbl.font.withSize(12.0)
        messageLbl.text = message
        messageLbl.clipsToBounds  =  true
        messageLbl.numberOfLines = 0
        messageLbl.backgroundColor = message.isEmpty ? UIColor.clear : UIColor.black.withAlphaComponent(0.8)
        let textSize: CGSize = messageLbl.intrinsicContentSize
        let labelWidth = min(textSize.width, window.frame.width - 40)
        
        messageLbl.frame = CGRect(x: 20, y: window.frame.height - 90, width: labelWidth + 30, height: 50)
        messageLbl.center.x = window.center.x
        messageLbl.layer.cornerRadius = messageLbl.frame.height/2
        messageLbl.layer.masksToBounds = true
        window.addSubview(messageLbl)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            UIView.animate(withDuration: 0.5, delay: 1.5, options: .curveEaseOut, animations: {
                messageLbl.alpha = 0
            }) { (_) in
                messageLbl.removeFromSuperview()
            }
        }
    }
    /// Convert Date formater
    class func convertDateFormater(_ date: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-mm-dd"
        let date = dateFormatter.date(from: date)
        dateFormatter.dateFormat = "DD MMM YYYY"
        return  dateFormatter.string(from: date!)
    }
}
