//
//  ListRecordController.swift
//  sampleAppUsingKintoneIOSSDK
//
//  Created by Cuc Kim on 10/9/18.
//  Copyright © 2018 Cuc Kim. All rights reserved.
//

import UIKit
import kintone_ios_sdk
import Promises

class ListRecordController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    var listRecord:[[String:FieldValue]]?
    var connection = AppCommon.shared.getConnection()
    var appId = AppCommon.shared.getAppId()!
    var appName = AppCommon.shared.getAppName()!
    var selectedRecordId: Int? = 0
    var indexStatus = 2
    var userTimeZone: String = AppCommon.shared.getUserTimezone()
    private var UserStorage = UserDefaults.standard
    
    var defaultLimit = 10;
    var limit:Int = 0
    var isBottom = false
    var spinner:UIView?
    var refreshControl: UIRefreshControl!
    var totalCommentOfRecords:[String] = []
    let imageCache = NSCache<NSString, UIImage>()
    let localizedStatuses = [
        0: NSLocalizedString("confirmed", comment: ""),
        1: NSLocalizedString("unconfirmed", comment: ""),
        2: NSLocalizedString("all-records", comment: ""),
    ]
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var recordsFilterBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        self.title = appName
        self.navigationItem.setHidesBackButton(true, animated:true)
        
        NotificationCenter.default.addObserver(forName: .radio, object: nil, queue: OperationQueue.main) { (Notification) in
            let status = Notification.object as! StatusPopupController
            self.indexStatus = status.selectedIndex!
            // set label
            self.recordsFilterBtn.setTitle(self.localizedStatuses[self.indexStatus], for: .normal)
             self.setDataTable()
        }
        
        setRefreshControlAttr()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setDataTable()
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if(refreshControl.isRefreshing) {
            handleRefreshTable()
        }
    }
    
        func setRefreshControlAttr() {
            refreshControl = UIRefreshControl()
            tableView.addSubview(refreshControl)
            refreshControl.tintColor = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.5)
    
        }
        func handleRefreshTable() {
            self.getListRecord().then{ listRecord in
                self.listRecord = listRecord
                self.limit = self.getLimit(newLimit: self.defaultLimit)
                
                self.totalCommentOfRecords = []
                for _ in 0...self.limit {
                    self.totalCommentOfRecords.append("")
                }
                DispatchQueue.main.async {
                    self.refreshControl.endRefreshing()
                    self.tableView.reloadData()
                }
                
            }.catch { error in
                if type(of: error) is KintoneAPIException.Type
                {
                    self.alert(message: (error as! KintoneAPIException).toString()!)
                } else {
                    self.alert(message: error.localizedDescription)
                }
            }
            
        }
    
    func setDataTable() -> Promise<Void>{
        let spinner = UIViewController.displaySpinner(onView: self.view)
        return Promise{fulfill, reject in
            self.getListRecord().then{ listRecord in
                self.listRecord = listRecord
                self.limit = self.getLimit(newLimit: self.defaultLimit)
                self.totalCommentOfRecords = []
                for _ in 0...self.limit {
                    self.totalCommentOfRecords.append("")
                }
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
                
                fulfill(())
            }.catch { error in
                if type(of: error) is KintoneAPIException.Type
                {
                    self.alert(message: (error as! KintoneAPIException).toString()!)
                } else {
                    self.alert(message: error.localizedDescription)
                }
                reject(error)
            }.always {
                UIViewController.removeSpinner(spinner: spinner)
            }
        }
    }

    @IBAction func handleSignOut(_ sender: Any) {
        UserStorage.removeObject(forKey: KintoneConstants.PASSWORD_KEY)
        UserStorage.removeObject(forKey: KintoneConstants.AUTHENTICATE_KEY)
        UserStorage.removeObject(forKey: KintoneConstants.CERT_PASSWORD)
        AppCommon.shared.setAppId(nil)
        AppCommon.shared.setAppName(nil)
        AppCommon.shared.setConnection(nil)
        try! await(Router.updateRootViewController())
    }
    
    @IBAction func handleAddButton(_ sender: Any) {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let view = sb.instantiateViewController(withIdentifier:"AddEditRecordController") as! AddEditRecordController
        
        view.screenType = "Add"
        self.navigationController?.pushViewController(view, animated: false)
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(limit == 0) {
            UIViewController.EmptyMessage(message: "no-records".localized ,icon: "icon-no-record", tableView: tableView)
        }
        else {
            DispatchQueue.main.async {
                tableView.backgroundView = nil
            }
        }
        return limit
    }
    
    func getLimit(newLimit: Int) -> Int {
        var limit = newLimit
        if newLimit > (listRecord?.count)! {
            limit = (listRecord?.count)!
        }
        return limit
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CELL") as! ListRecordViewCell
        cell.customView()
        cell.selectionStyle = UITableViewCell.SelectionStyle.default
        return getRecordViewCellData(cell: cell, record: listRecord![indexPath.row], index: indexPath.row)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedRecord = self.listRecord![indexPath.row]
        selectedRecordId = Int(selectedRecord[PhotoMappingKeys.Id.rawValue]?.getValue()! as! String) ?? 0
        tableView.cellForRow(at: indexPath)?.selectionStyle = .default
        // initialize new view controller and cast it as your view controller
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let detailRecordView = sb.instantiateViewController(withIdentifier: "RecordDetailController") as! RecordDetailController
        detailRecordView.recordId = self.selectedRecordId
         self.navigationController?.pushViewController(detailRecordView, animated: false)
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let oldLimit = limit
        let temp = limit + defaultLimit
        let floatBottomEdge = scrollView.contentOffset.y + scrollView.frame.size.height;
        if scrollView.contentOffset.y > 0 && floatBottomEdge >= scrollView.contentSize.height {
            self.limit = getLimit(newLimit: temp)
            
            if (oldLimit != (listRecord?.count)!) {
                for _ in oldLimit...self.limit {
                    self.totalCommentOfRecords.append("")
                }
                self.tableView.reloadData()
            }
        }
    }
    
    func getRecordViewCellData(cell:ListRecordViewCell,record:[String:FieldValue], index: Int) -> ListRecordViewCell {
        let cellData = cell
        
        let createdDateStr = record[PhotoMappingKeys.CreateDateTime.rawValue]?.getValue() as! String
        let createdDate = createdDateStr.toDate()
        cellData.lblCreateDatetime.text = createdDate.formatToString(dateFormat: "MMM dd, yyyy HH:mm" , timezone: userTimeZone)
        cellData.lblTitle.text = (record[PhotoMappingKeys.Summary.rawValue]?.getValue() as! String)
        cellData.lblNote.text = (record[PhotoMappingKeys.Notes.rawValue]?.getValue() as! String)
        
        let creator = record[PhotoMappingKeys.Creator.rawValue]?.getValue()! as! Member
        cellData.lblCreator.text = String(creator.name!)
        
        let recordId = record[PhotoMappingKeys.Id.rawValue]?.getValue() as! String
        if (self.totalCommentOfRecords[index] == "") {
                
          getNumCommentOfRecord(recordID: Int(recordId)!, offset: 0, limmit: 10)
            .then {commentTotal in
                if commentTotal > 9 {
                    self.totalCommentOfRecords[index] = "9+"
                } else {
                    self.totalCommentOfRecords[index] = "\(commentTotal)"
                }
                let comment = self.totalCommentOfRecords[index]
                if !(self.totalCommentOfRecords[index] == "") {
                    DispatchQueue.main.sync {
                        cellData.lblCommentTotal.text = comment
                    }
                }
            }
        }
        
        cellData.lblCommentTotal.text = self.totalCommentOfRecords[index]

        let images =  record[PhotoMappingKeys.Photo.rawValue]?.getValue()! as! [Any]
        if images.count > 0 {
            let image = images[0] as!FileModel
            cellData.photoView.loadImage(fileKey: image.getFileKey()!, imageCache: imageCache)
        } else {
            cellData.photoView.image = UIImage(named: ("default"))
        }
        
        return cellData
    }
    
    func getNumCommentOfRecord(recordID: Int, offset: Int, limmit: Int) -> Promise<Int>{
        let record = Record(connection!)
        return Promise {fulfill, reject in
            record.getComments(self.appId, recordID, nil, offset, limmit)
            .then{ listComment in
                fulfill((listComment.getComments()?.count)!)
            }.catch { error in
                if type(of: error) is KintoneAPIException.Type
                {
                    self.alert(message: (error as! KintoneAPIException).toString()!)
                } else {
                    self.alert(message: error.localizedDescription)
                }
            }
        }
    }
    
    func getListRecord() -> Promise<[[String:FieldValue]]>{
        var query:String?
        if self.indexStatus == 1 {
            query = "\(PhotoMappingKeys.Status) in (\"\(PhotoStatusConstant.Unconfirmed)\")"
        }
        if self.indexStatus == 0 {
            query = "\(PhotoMappingKeys.Status) in (\"\(PhotoStatusConstant.Confirmed)\")"
        }
        
        let record = Record(connection!)
        return Promise {fulfill, reject in
            record.getRecords(self.appId, query, nil, nil)
                .then{ listRecord in
                    fulfill(listRecord.getRecords()!)
                }.catch{ error in
                    reject(error)
            }
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.destination is StatusPopupController
        {
            let vc = segue.destination as? StatusPopupController
            vc!.selectedIndex = indexStatus
        }
    }
}
