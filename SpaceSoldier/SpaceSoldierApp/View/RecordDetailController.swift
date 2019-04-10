//
//  RecorDetail.swift
//  sampleAppUsingKintoneIOSSDK
//
//  Created by Cuc Kim on 10/10/18.
//  Copyright © 2018 Cuc Kim. All rights reserved.
//

import UIKit
import kintone_ios_sdk
import Promises

class RecordDetailController: UIViewController {
    
    @IBOutlet weak var dataView: UIView!
    @IBOutlet weak var commentView: UIView!
    @IBOutlet weak var rightMostButton: UIButton!
    @IBOutlet weak var editButton: UIButton!
    
    public var recordId: Int? = 0
    let connection = AppCommon.shared.getConnection()
    let appId = AppCommon.shared.getAppId()
    let appName = AppCommon.shared.getAppName()!
    var recordModule: Record?
    var spinner: UIView?
    @IBOutlet weak var titleNavigationBar: UINavigationItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = appName
        self.navigationController?.navigationItem.hidesBackButton = true
        self.navigationItem.setHidesBackButton(true, animated: false)
        if self.recordId == 0 {
            self.alert(message: "Data Not Found")
        }
        recordModule = Record(connection!)
        guard let dataViewController = children.first as? RecordDetailDataController else {
            fatalError("Check storyboard for missing RecordDetailDataController")
        }
        guard let commentsViewController = children[1] as? ListCommentController else {
            fatalError("Check storyboard for missing ListCommentController")
        }
        dataView.isHidden = false
        commentView.isHidden = true
        dataViewController.recordId = self.recordId
        dataViewController.recordModule = recordModule
        commentsViewController.recordId = self.recordId
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.spinner = UIViewController.displaySpinner(onView: self.view)
    }
    
    @IBAction func handleBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: false)
    }
    
    @IBAction func handleEditButtonClick(_ sender: Any) {
        if let editRecordView = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "AddEditRecordController") as? AddEditRecordController {
            editRecordView.recordId = self.recordId
            editRecordView.screenType = "Edit"
            self.navigationController?.pushViewController(editRecordView, animated: false)
        }
    }
    
    @IBAction func handleRightButtonClick(_ sender: UIButton) {
        let dialogMessage = UIAlertController(title: NSLocalizedString("delete-confirm-title", comment: ""), message: NSLocalizedString("delete-confirm-message", comment: ""), preferredStyle: .alert)
        let ok = UIAlertAction(title: NSLocalizedString("delete-confirm-ok", comment: ""), style: .default, handler: { (action) -> Void in
            let spinner = UIViewController.displaySpinner(onView: self.view)
            
            self.deleteRecord().always {
                UIViewController.removeSpinner(spinner: spinner)
                DispatchQueue.main.async {
                    self.navigationController?.popViewController(animated: false)
                }
            }
        })
        let cancel = UIAlertAction(title: NSLocalizedString("delete-confirm-cancel", comment: ""), style: .cancel) { (action) -> Void in
        }
        dialogMessage.addAction(ok)
        dialogMessage.addAction(cancel)
        self.present(dialogMessage, animated: true, completion: nil)
    }
    
    @IBAction func segmentedValueChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            dataView.isHidden = false
            guard let commentsViewController = children[1] as? ListCommentController else {
                fatalError("Check storyboard for missing ListCommentController")
            }
            commentsViewController.hideKeyboard()
            commentView.isHidden = true
            rightMostButton.isHidden = false
            editButton.isHidden = false
        case 1:
            dataView.isHidden = true
            commentView.isHidden = false
            editButton.isHidden = true
            rightMostButton.isHidden = true
        default:
            break;
        }
    }
  
    func deleteRecord() -> Promise<Void>
    {
        var recordIdsDelete: [Int] = [Int]()
        recordIdsDelete.append(self.recordId!)
        return Promise{ fulfill, reject in
            self.recordModule!.deleteRecords(self.appId!, recordIdsDelete)
            .then {_ in
                fulfill(())
            }.catch{error in
                 reject(error)
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
    }
}
