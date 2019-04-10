//
//  TableCellController.swift
//  sampleAppUsingKintoneIOSSDK
//
//  Created by Cuc Kim on 10/9/18.
//  Copyright © 2018 Cuc Kim. All rights reserved.
//

import UIKit

class ListRecordViewCell: UITableViewCell {
  
    @IBOutlet weak var photoView: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblNote: UILabel!
    @IBOutlet weak var lblCreateDatetime: UILabel!
    @IBOutlet weak var lblCreator: UILabel!
    @IBOutlet weak var lblCommentTotal: UILabel!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var timerView: UIView!
    @IBOutlet weak var userView: UIView!
    @IBOutlet weak var commentView: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func customView() {
        
        let color = UIColor(red:233/255, green:235/255, blue:255/255, alpha: 1).cgColor
        containerView.layer.masksToBounds = true
        containerView.layer.cornerRadius = 3.0
        containerView.layer.shadowOffset = CGSize(width: -1, height: 1)
        containerView.layer.shadowOpacity = 0.2
        
        photoView.layer.masksToBounds = true
        photoView.layer.cornerRadius = 5.0
        
        containerView.layer.borderWidth = 1
        containerView.layer.borderColor = color
        userView.layer.borderWidth = 1
        timerView.layer.borderWidth = 1
        timerView.layer.borderColor = color
        userView.layer.borderWidth = 1
        userView.layer.borderColor = color
        commentView.layer.borderWidth = 1
        commentView.layer.borderColor = color
        
    }

}
