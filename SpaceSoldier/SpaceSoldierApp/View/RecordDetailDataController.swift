//
//  RecordDetailDataController.swift
//  SpaceSoldierApp
//
//  Created by Trinh Hung Anh on 10/22/18.
//  Copyright © 2018 Cuc Kim. All rights reserved.
//

import UIKit
import kintone_ios_sdk
import Promises

class RecordDetailDataController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate{
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var creatorTextField: UILabel!
    @IBOutlet weak var createdDateTimeTextField: UILabel!
    @IBOutlet var titleTextField: UILabel!
    @IBOutlet weak var noAttachmentTextField: UILabel!
    
    @IBOutlet weak var noteTextField: UILabel!
    @IBOutlet weak var lblStatus: UILabel!
    
    let connection = AppCommon.shared.getConnection()
    let appId = AppCommon.shared.getAppId()
    let MAX_ATTACHMENTS_COUNT = 3
    let imageCache = NSCache<NSString, UIImage>()
    var recordModule: Record?
    var arrayImages: [Any]? = [Any]()
    var userTimeZone: String = AppCommon.shared.getUserTimezone()
    var recordDetail = [String: FieldValue]()
    var recordId: Int?
    var spinner: UIView?
    var zoomedImage: UIImageView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        clearView()
        self.getRecordDetailById().then{recordDetail in
            self.recordDetail = recordDetail
            DispatchQueue.main.async{
                self.assignData()
                 UIViewController.removeSpinner(spinner: (self.parent as! RecordDetailController).spinner!)
            }
        }.catch{ error in
            if type(of: error) is KintoneAPIException.Type {
                let err = error as! KintoneAPIException
                self.alert(message: err.toString()!)
            } else {
                self.alert(message: error.localizedDescription)
            }
            UIViewController.removeSpinner(spinner: (self.parent as! RecordDetailController).spinner!)
        }
    }
    
    func clearView() {
        (self.parent as! RecordDetailController).titleNavigationBar.title = ""
        createdDateTimeTextField.text = ""
        titleTextField.text = ""
        noteTextField.text = ""
        creatorTextField.text = ""
        lblStatus.text = ""
        arrayImages = [Any]()
        collectionView.reloadData()
    }
    
    func assignData()
    {
        let createdDateStr = recordDetail[PhotoMappingKeys.CreateDateTime.rawValue]?.getValue() as! String
        let createdDate = createdDateStr.toDate()
        createdDateTimeTextField.text = createdDate.formatToString(dateFormat: "MMM dd, yyyy HH:mm", timezone: userTimeZone)
        titleTextField.text = (recordDetail[PhotoMappingKeys.Summary.rawValue]?.getValue() as! String)
        noteTextField.text = (recordDetail[PhotoMappingKeys.Notes.rawValue]?.getValue() as! String)
        let creator = recordDetail[PhotoMappingKeys.Creator.rawValue]?.getValue()! as! Member
        creatorTextField.text = String(creator.name!)
        lblStatus.text = (recordDetail[PhotoMappingKeys.Status.rawValue]?.getValue() as! String)
        arrayImages =  recordDetail[PhotoMappingKeys.Photo.rawValue]?.getValue()! as? [Any]
        collectionView.reloadData()
    }
    
    func getRecordDetailById() -> Promise<[String: FieldValue]>
    {
        return Promise {fulfill, reject in
            self.recordModule!.getRecord(self.appId!, self.recordId!).then{ recordResponse in
                let recordDetail = (recordResponse.getRecord())!
                (self.parent as! RecordDetailController).titleNavigationBar.title = (recordDetail[PhotoMappingKeys.Summary.rawValue]?.getValue() as! String)
                
                fulfill(recordDetail)
                self.recordDetail = recordDetail
            }.catch{ error in
                reject(error)
            }
        }
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if (arrayImages?.count)! > 0 {
            self.collectionView.backgroundColor = nil
            self.noAttachmentTextField.isHidden = true
            self.collectionView.layer.borderColor  = UIColor.white.cgColor
        } else {
            self.noAttachmentTextField.isHidden = false
        
            self.collectionView.layer.masksToBounds = true
            self.collectionView.layer.borderWidth = 1.0
            self.collectionView.layer.cornerRadius = 5.0
            self.collectionView.layer.borderColor =  UIColor(displayP3Red: 242/255, green: 242/255, blue: 242/255, alpha: 1).cgColor
            
            self.collectionView.backgroundColor = UIColor(displayP3Red: 242/255, green: 242/255, blue: 242/255, alpha: 1)
        }
        
        return arrayImages!.count <= MAX_ATTACHMENTS_COUNT ? arrayImages!.count : MAX_ATTACHMENTS_COUNT
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCell", for: indexPath) as! ImageCell
        let image = arrayImages![indexPath.row] as! FileModel
        cell.thumbnailImage.loadImage(fileKey: image.getFileKey()!, imageCache: imageCache)
        cell.layer.masksToBounds=true
        cell.layer.cornerRadius=5
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let imageCell = collectionView.cellForItem(at: indexPath) as! ImageCell
        let imageView = imageCell.thumbnailImage!
        if(imageView.image?.pngData() != nil) {
            self.zoomedImage = UIImageView(image: imageView.image)
            self.zoomedImage!.frame = UIScreen.main.bounds
            self.zoomedImage!.backgroundColor = .black
            self.zoomedImage!.contentMode = .scaleAspectFit
            self.zoomedImage!.isUserInteractionEnabled = true
            self.parent!.view.addSubview(self.zoomedImage!)
            self.parent!.navigationController?.isNavigationBarHidden = true
            self.parent!.tabBarController?.tabBar.isHidden = true
            
            // close button
            let button = UIButton(frame: CGRect(x: self.parent!.view.bounds.maxX - 40, y: 40, width: 25, height: 25))
            button.setImage(UIImage(named: "deleteFile"), for: .normal)
            button.addTarget(self, action: #selector(dismissFullscreenImage), for: .touchUpInside)
            self.parent!.view.addSubview(button)
            //
        }
    }
    
    @objc func dismissFullscreenImage(sender: UIButton!) {
        self.parent!.navigationController?.isNavigationBarHidden = false
        self.parent!.tabBarController?.tabBar.isHidden = false
        sender.removeFromSuperview()
        self.zoomedImage!.removeFromSuperview()
    }
}

class ImageCell: UICollectionViewCell {
    @IBOutlet weak var thumbnailImage: UIImageView!
    var isHeightCalculated: Bool = false
}
