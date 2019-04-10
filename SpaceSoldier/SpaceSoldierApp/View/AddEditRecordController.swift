//
//  AddEditRecordController.swift
//  sampleAppUsingKintoneIOSSDK
//
//  Created by Cuc Kim on 10/12/18.
//  Copyright © 2018 Cuc Kim. All rights reserved.
//

import UIKit
import Photos
import kintone_ios_sdk
import AssetsLibrary
import Promises

class AddEditRecordController: UIViewController,UICollectionViewDelegate, UICollectionViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate, AddEditRecordAttachmentCellDelegate {
    
    @IBOutlet weak var saveButton: UILabel!
    @IBOutlet weak var notesTextAreaField: UITextView!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var attachmentButton: UIButton!
    @IBOutlet weak var txtNote: UITextView!
    @IBOutlet weak var screenTitle: UINavigationItem!
    @IBOutlet weak var collectionView: UICollectionView!
    var screenType: String?
    var attachmentsArray = [[String: String]]()
    var pickingImage = false
    var recordId: Int?
    var deletedFileKeys = [String]()
    var recordDetail: [String: FieldValue]? = nil
    var isNewPic = false
    let imageCache = NSCache<NSString, UIImage>()
    var appName = AppCommon.shared.getAppName()!
    let screenTitleLocalized = [
        "Add": NSLocalizedString("add-record-title", comment: ""),
        "Edit": NSLocalizedString("edit-record-title", comment: ""),
    ]
    
    let connection = AppCommon.shared.getConnection()
    let imagePicker = UIImagePickerController()
    let MAX_ATTACHMENTS_COUNT = 4
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.setHidesBackButton(true, animated: false)
        self.title = appName
        screenTitle.title = screenTitleLocalized[screenType!]
        txtNote.layer.borderColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0).cgColor
        txtNote.layer.borderWidth = 1.0
        txtNote.layer.cornerRadius = 5
    
        collectionView.delegate = self
        collectionView.dataSource = self
        imagePicker.delegate = self
    
        if((recordId) != nil) {
            loadRecord()
        }
        self.attachmentsArray.insert(["Addfile" : "Addfile"], at: 0)
        self.hideKeyboardWhenTappedAround()
    }
    
    private func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            return attachmentsArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.row == 0 && !self.attachmentsArray[indexPath.row].keys.contains("fileName") {
            self.addFileButtonClicked()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.row == 0 && !self.attachmentsArray[indexPath.row].keys.contains("fileName")  {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "RecordAddFileCell", for: indexPath)
            cell.layer.masksToBounds = true
            cell.layer.cornerRadius = 5.0
            cell.layer.borderWidth = 1
            cell.layer.borderColor = UIColor(red:233/255, green:235/255, blue:255/255, alpha: 1).cgColor
            return cell
        }
        else {
            if(attachmentsArray.count > 0 && attachmentsArray.count <= MAX_ATTACHMENTS_COUNT) {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "RecordFileList", for: indexPath) as! AddEditRecordAttachmentCell
                let cellData = attachmentsArray[indexPath.row]
                cell.imageName.text = cellData["fileName"]
                cell.imageSize.text = cellData["fileSize"]
                if cellData.keys.contains("filePath") {
                    let imageView = UIImage(contentsOfFile: cellData["filePath"]!)
                    cell.imageView.image = imageView
                }
                
                if cellData.keys.contains("fileKey") {
                    cell.imageView.loadImage(fileKey: cellData["fileKey"]!, imageCache: imageCache)
                }
                cell.delegate = self
                cell.indexPath = indexPath
                return cell
            }
        }
        return UICollectionViewCell()
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if(self.isNewPic) {
            self.dismiss(animated: true, completion: {
                guard let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else { return }
                let docDir = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
                let imageUniqueName : Int64 = Int64(Date().timeIntervalSince1970 * 1000);
                let filePath = docDir.appendingPathComponent("\(imageUniqueName).png");
                do {
                    if let jpgImageData = image.jpegData(compressionQuality: 1){
                        try jpgImageData.write(to : filePath , options : .atomic)
                        let imageSize: Int = jpgImageData.count
                        //file name
                        let fileName = filePath.lastPathComponent
                        //file size
                        let fileSize = self.converByteToHumanReadable(Int64(imageSize))
                        //add to file arrays and reload table
                        if(self.attachmentsArray.count < self.MAX_ATTACHMENTS_COUNT) {
                            var newAttachment = [String: String]()
                            newAttachment["fileName"] = fileName;
                            newAttachment["fileSize"] = fileSize;
                            newAttachment["fileUrl"] = filePath.absoluteString
                            newAttachment["filePath"] = filePath.path
                            self.attachmentsArray.append(newAttachment)
                            if self.attachmentsArray.count == self.MAX_ATTACHMENTS_COUNT {
                                self.attachmentsArray.remove(at: 0)
                            }
                            self.collectionView.reloadData()
                        }
                    }
                } catch {
                    let ac = UIAlertController(title: "Save error", message: error.localizedDescription, preferredStyle: .alert)
                    ac.addAction(UIAlertAction(title: "OK", style: .default))
                    self.present(ac, animated: true)

                }
            })
        } else {
            if(self.pickingImage) {
                return
            }
            self.pickingImage = true
            self.dismiss(animated: true, completion: {
                guard let fileUrl = info[UIImagePickerController.InfoKey.imageURL] as? URL else { return }
                guard let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else { return }
                var imgData = image.jpegData(compressionQuality: 1)
                let imageSize: Int = imgData!.count
                //file name
                let fileName = fileUrl.lastPathComponent
                //file size
                let fileSize = self.converByteToHumanReadable(Int64(imageSize))
                //add to file arrays and reload table
                if(self.attachmentsArray.count < self.MAX_ATTACHMENTS_COUNT) {
                    var newAttachment = [String: String]()
                    newAttachment["fileName"] = fileName;
                    newAttachment["fileSize"] = fileSize;
                    newAttachment["fileUrl"] = fileUrl.absoluteString
                    newAttachment["filePath"] = fileUrl.path
                    self.attachmentsArray.append(newAttachment)
                    if self.attachmentsArray.count == self.MAX_ATTACHMENTS_COUNT {
                        self.attachmentsArray.remove(at: 0)
                    }
                    self.collectionView.reloadData()
                }
                self.pickingImage = false
            })
        }
    }
   
    func converByteToHumanReadable(_ bytes:Int64) -> String {
        let formatter:ByteCountFormatter = ByteCountFormatter()
        formatter.countStyle = .binary
        return formatter.string(fromByteCount: Int64(bytes))
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func deleteButtonClicked(indexPath: IndexPath) {
        if(attachmentsArray[indexPath.row]["fileKey"] != nil) {
            deletedFileKeys.append(attachmentsArray[indexPath.row]["fileKey"]!)
        }
        attachmentsArray.remove(at: indexPath.row)
        collectionView.reloadData()
        if ( self.attachmentsArray.count == 2 && !self.attachmentsArray[0].keys.contains("Addfile")) {
            self.attachmentsArray.insert(["Addfile" : "Addfile"], at: 0)
            collectionView.reloadData()
        }
    }
    
    func goBack() {
        if(screenType! == "Add") {
            self.navigationController?.popViewController(animated: false)
        }
        else {
            self.navigationController?.popViewController(animated: false)
        }
    }
    
    func loadRecord() -> Promise<Void> {
        let spinner = UIViewController.displaySpinner(onView: self.view)
            let recordModule = Record(self.connection!)
            var attachmentFile: FileModel?
        return Promise{fulfill, reject in
            recordModule.getRecord(AppCommon.shared.getAppId()!, self.recordId!)
                .then{record in
                    if record.getRecord() != nil {
                        self.recordDetail = (record.getRecord())!
                        let attachmentsArr =  self.recordDetail![PhotoMappingKeys.Photo.rawValue]?.getValue()! as! [Any?]
                        if(attachmentsArr.count > 0) {
                            for attachment in attachmentsArr {
                                if(self.attachmentsArray.count < self.MAX_ATTACHMENTS_COUNT) {
                                    var attachmentArrayElement = [String:String]()
                                    attachmentFile = attachment as? FileModel
                                    attachmentArrayElement["fileName"] = attachmentFile?.getName()!
                                    attachmentArrayElement["fileSize"] = self.converByteToHumanReadable(Int64((attachmentFile?.getSize()!)!)!)
                                    attachmentArrayElement["fileKey"] = attachmentFile?.getFileKey()!
                                    self.attachmentsArray.append(attachmentArrayElement)
                                    if(self.attachmentsArray.count == self.MAX_ATTACHMENTS_COUNT) {
                                        self.attachmentsArray.remove(at: 0)
                                        break
                                    }
                                }
                            }
                            DispatchQueue.main.async {
                                self.collectionView.reloadData()
                            }
                        }
                        DispatchQueue.main.async {
                            self.titleTextField.text = (self.recordDetail![PhotoMappingKeys.Summary.rawValue]!.getValue() as! String)
                            self.notesTextAreaField.text = (self.recordDetail![PhotoMappingKeys.Notes.rawValue]!.getValue() as! String)
                        }
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
    
    func saveRecord(recordId: Int? = nil) -> Promise<Void>{
        let recordModule = Record(connection!)
        let summary = FieldValue()
        let notes = FieldValue()
        summary.setType(FieldType.SINGLE_LINE_TEXT)
        notes.setType(FieldType.MULTI_LINE_TEXT)
        summary.setValue(self.titleTextField.text)
        notes.setValue(self.notesTextAreaField.text)
        var recordModel = [String: FieldValue]()
        recordModel["Summary"] = summary
        recordModel["Notes"] = notes
       
        return Promise {fulfil, reject in
            if(recordId == nil) {
                self.uploadAttachments()
                    .then{photoField -> Promise<AddRecordResponse>  in
                        recordModel["Photo"] = photoField
                        return (recordModule.addRecord(AppCommon.shared.getAppId()!, recordModel))
                    }
                    .then{_ in
                        fulfil(())
                    }
                    .catch { error in
                        if type(of: error) is KintoneAPIException.Type
                        {
                            self.alert(message: (error as! KintoneAPIException).toString()!)
                        } else {
                            self.alert(message: error.localizedDescription)
                        }
                        reject(error)
                    }.always {
                        DispatchQueue.main.async {
                            self.goBack()
                        }
                    }
            } else {
                let existingAttachments = self.recordDetail![PhotoMappingKeys.Photo.rawValue]?.getValue()
                self.uploadAttachments(existingAttachments: existingAttachments as? [FileModel])
                    .then{photoField -> Promise<UpdateRecordResponse> in
                        recordModel["Photo"] = photoField
                        return recordModule.updateRecordByID(AppCommon.shared.getAppId()!, self.recordId!, recordModel, -1)
                    }
                    .then{_ in
                        fulfil(())
                    }
                    .catch { error in
                        if type(of: error) is KintoneAPIException.Type
                        {
                            self.alert(message: (error as! KintoneAPIException).toString()!)
                        } else {
                            self.alert(message: error.localizedDescription)
                        }
                        reject(error)
                    }.always {
                        DispatchQueue.main.async {
                            self.goBack()
                        }
                   }
            }
        }
    }
    
    func uploadAttachments(existingAttachments: [FileModel]? = nil) -> Promise<FieldValue?> {
        
        return Promise{ fulfill, reject in
            let photoField = FieldValue()
            let fileModule = File(self.connection!)
            var photos = existingAttachments != nil ? existingAttachments! : [FileModel]()
            photoField.setType(FieldType.FILE)
            // delete removed attachments
            if(self.deletedFileKeys.count > 0) {
                self.deletedFileKeys.forEach { fileKey in
                    let index = photos.index {
                        $0.getFileKey()! == fileKey
                    }
                    if(index != nil) {
                        photos.remove(at: index!)
                    }
                }
            }
            if(self.attachmentsArray.count > 0) {
                let attachentsValibles = self.attachmentsArray.drop { $0["fileUrl"] == nil }
                all(
                    attachentsValibles.map { fileModule.upload($0["fileUrl"]!) }
                ).then { multipleFileResp in
                    photos.append(contentsOf: multipleFileResp)
                
                    photoField.setValue(photos)
                    fulfill(photoField)
                }.catch{ error in
                    reject(error)
                }
            }else {
                photoField.setValue(photos)
                fulfill(photoField)
            }
        }
    }
    
    @IBAction func cancelButtonHandler(_ sender: Any) {
        self.goBack()
    }
    
    func addFileButtonClicked() {
        imagePicker.allowsEditing = false
        let alert = UIAlertController(title: "Please, choose image source", message: "", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Photo Library", style: .default, handler: { action in
            self.imagePicker.sourceType = .photoLibrary
            self.present(self.imagePicker, animated: true, completion: nil)
        }))
        alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: { action in
            self.imagePicker.sourceType = .camera
            self.isNewPic = true
            self.present(self.imagePicker, animated: true, completion: nil)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { action in
            alert.dismiss(animated: true, completion: nil)
        }))
        self.present(alert, animated: true)
    }
    
    
    @IBAction func saveButtonHandler(_ sender: Any) {
        let spinner = UIViewController.displaySpinner(onView: self.view)
        titleTextField.resignFirstResponder()
        notesTextAreaField.resignFirstResponder()
        
        if(self.screenType == "Add") {
            self.saveRecord().always {
                UIViewController.removeSpinner(spinner: spinner)
            }
        }
        else {
            self.saveRecord(recordId: self.recordId!).always {
                UIViewController.removeSpinner(spinner: spinner)
            }
        }
    }

}
