//
//  AddEditRecordAttachmentCell.swift
//  SpaceSoldierApp
//
//  Created by Trinh Hung Anh on 10/19/18.
//  Copyright © 2018 Cuc Kim. All rights reserved.
//

import UIKit

protocol AddEditRecordAttachmentCellDelegate {
    func deleteButtonClicked(indexPath: IndexPath)
}

class AddEditRecordAttachmentCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var imageName: UILabel!
    @IBOutlet weak var imageSize: UILabel!
    
    var delegate: AddEditRecordAttachmentCellDelegate?
    var indexPath: IndexPath?

    @IBAction func deleteButtonHandler(_ sender: Any) {
        delegate?.deleteButtonClicked(indexPath: self.indexPath!)
    }
    
}
