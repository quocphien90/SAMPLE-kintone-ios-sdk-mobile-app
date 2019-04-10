//
//  ListCommentViewCell.swift
//  sampleAppUsingKintoneIOSSDK
//
//  Created by Cuc Kim on 10/12/18.
//  Copyright © 2018 Cuc Kim. All rights reserved.
//

import UIKit
import kintone_ios_sdk

protocol CommentCellDelegate {
    func handleReply(_ cell: ListCommentViewCell)
    func handleCommentDelete(_ cell: ListCommentViewCell)
}

class RoundedTopBordersView: UIView {
    override func layoutSubviews() {
        super.layoutSubviews()
        self.round(corners: [.topLeft, .topRight], radius: 5)
    }
}

class RoundedBottomBordersView: UIView {
    override func layoutSubviews() {
        super.layoutSubviews()
        self.round(corners: [.bottomLeft, .bottomRight], radius: 5)
    }
}

class ListCommentViewCell: UITableViewCell {
    @IBOutlet weak var commentIdTextLabel: UILabel!
    @IBOutlet weak var creatorTextLabel: UILabel!
    @IBOutlet weak var mentionTextLabel: UILabel!
    @IBOutlet weak var createdDateTimeTextLabel: UILabel!
    @IBOutlet weak var commentTextView: UILabel!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var commentBottomContainer: UIView!
    @IBOutlet weak var commentContentContainer: UIView!
    var delegate: CommentCellDelegate?
    var indexPath: IndexPath?
    var cellData: Comment?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code  
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        //
        // Configure the view for the selected state
    }
    
    @IBAction func replyButtonHandler(_ sender: Any) {
        delegate?.handleReply(self)
    }
    

    @IBAction func deleteButtonHandler(_ sender: Any) {
        delegate?.handleCommentDelete(self)
    }
}
