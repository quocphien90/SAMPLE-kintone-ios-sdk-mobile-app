//
//  AddCommentController.swift
//  sampleAppUsingKintoneIOSSDK
//
//  Created by Cuc Kim on 10/12/18.
//  Copyright © 2018 Cuc Kim. All rights reserved.
//

import UIKit

class AddCommentController: UIViewController {

    @IBOutlet weak var saveCommentView: UIView!
    @IBOutlet weak var replyCommentView: UIView!
    @IBOutlet weak var txtComment: UITextView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setViewBorder(view: saveCommentView)
        self.setViewBorder(view: replyCommentView)
        self.setTextViewBorder(textVew: txtComment)
        self.title = "App Name"
    }
    
    func setViewBorder(view: UIView) {
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0).cgColor
    }
    func setTextViewBorder(textVew: UITextView) {
        textVew.layer.borderColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0).cgColor
        textVew.layer.borderWidth = 1.0
        textVew.layer.cornerRadius = 5
    }


}
