//
//  CheckStatusPopup.swift
//  SpaceSoldierApp
//
//  Created by Cuc Kim on 10/17/18.
//  Copyright © 2018 Cuc Kim. All rights reserved.
//

import UIKit

class StatusPopupController: UIViewController, RadioButtonsControllerDelegate {
    
    var radioButtonsController: RadioButtonsController!
    @IBOutlet var radioButtons: [RadioButton]!
    
    var selectedIndex:Int?
    
    @IBOutlet weak var popupView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.radioButtonsController = RadioButtonsController(radioButtons: self.radioButtons)
        self.radioButtonsController.delegate = self
        self.radioButtonsController.selectedIndex = self.selectedIndex!
        
        self.popupView.layer.cornerRadius = 15
    }
    
    func selectedButton(sender: RadioButton) {
        selectedIndex = radioButtonsController.selectedIndex
        NotificationCenter.default.post(name: .radio, object: self)
        dismiss(animated: true)
    }
}
extension Notification.Name {
    static let radio = NSNotification.Name(rawValue: "radio")
}


