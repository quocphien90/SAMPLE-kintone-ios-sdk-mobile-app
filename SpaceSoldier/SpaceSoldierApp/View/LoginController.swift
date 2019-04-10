//
//  ViewController.swift
//  sampleAppUsingKintoneIOSSDK
//
//  Created by Cuc Kim on 10/9/18.
//  Copyright © 2018 Cuc Kim. All rights reserved.
//

import UIKit
import kintone_ios_sdk
import Promises
import MobileCoreServices

class LoginController: UIViewController,UIDocumentPickerDelegate,UINavigationControllerDelegate {

    @IBOutlet weak var domainTextField: UITextField!
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var appIdTextField: UITextField!
    @IBOutlet weak var buttonLogin: UIButton!
    @IBOutlet weak var certFileUIField: UIView!
     @IBOutlet weak var certFileLabelField: UILabel!
     @IBOutlet weak var certPasswordField: UITextField!
    private var UserStorage = UserDefaults.standard
     private var certData: Data? = nil
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Space Soldier"
        // Do any additional setup after loading the view, typically from a nib.
       self.autoFillRecentAccount()
     if let fileData = UserStorage.data(forKey: KintoneConstants.CERT_DATA) {
          certData = fileData
     }
     
     buttonLogin.isEnabled = false
     self.hideKeyboardWhenTappedAround()
     [domainTextField, userNameTextField, passwordTextField, appIdTextField].forEach({ $0.addTarget(self, action: #selector(editingChanged), for: .editingChanged) })
    }
     
     @IBAction func handleLogin(_ sender: Any) {
          if(validateFormFields()) {
               let spinner = UIViewController.displaySpinner(onView: self.view)
               let username = userNameTextField.text!
               let password = passwordTextField.text!
               let domainName = domainTextField.text!
               let appId = appIdTextField.text!
               let certPassword = certPasswordField.text
          authenticationWithKintone()
               .then{isAuthenticated in
                    self.UserStorage.set(username, forKey: KintoneConstants.USERNAME_KEY)
                    let encryptPassword = try CryptoAESCommon.encrypt(password)
                    self.UserStorage.set(encryptPassword, forKey: KintoneConstants.PASSWORD_KEY)
                    self.UserStorage.set(isAuthenticated, forKey: KintoneConstants.AUTHENTICATE_KEY)
                    self.UserStorage.set(domainName, forKey: KintoneConstants.DOMAIN_KEY)
                    self.UserStorage.set(appId, forKey: KintoneConstants.APP_ID_KEY)
                    if certPassword != nil{
                        self.UserStorage.set(certPassword, forKey: KintoneConstants.CERT_PASSWORD)
                    }
                    if self.certData != nil{
                        self.UserStorage.set(self.certData, forKey: KintoneConstants.CERT_DATA)
                    }
                    
                    // Safe Present
                    if let listRecordView = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ListRecordController") as? ListRecordController {
                         DispatchQueue.main.async {
                              self.navigationController?.pushViewController(listRecordView, animated: true)
                         }
                    }
               }.catch {error in
                    if type(of: error) is KintoneAPIException.Type
                    {
                         let error = error as! KintoneAPIException
                         if error.getErrorResponse() != nil {
                              self.alert(message: error.toString()!, title: error.getErrorResponse()!.getCode()!)
                         } else {
                              self.alert(message: "Please input valid domain name")
                         }
                    } else {
                         self.alert(message: error.localizedDescription)
                    }
                    
               }.always {
                    UIViewController.removeSpinner(spinner: spinner)
               }
          }
     }
     
     @IBAction func handleDeleteCertificate(_ sender: Any) {
          certFileLabelField.text = ""
          certFileUIField.isHidden = true
          
          UserStorage.removeObject(forKey: KintoneConstants.CERT_DATA)
          UserStorage.removeObject(forKey: KintoneConstants.CERT_FIlE_NAME)
          UserStorage.removeObject(forKey: KintoneConstants.CERT_PASSWORD)
     }
     @IBAction func importCertFile(_ sender: Any) {
          let importMenu = UIDocumentPickerViewController(documentTypes: [String(kUTTypePKCS12), String(kUTTypePlainText)], in: .import)
          importMenu.delegate = self
          importMenu.modalPresentationStyle = .formSheet
          self.present(importMenu, animated: true, completion: nil)
     }
     
    @objc func editingChanged(_ textField: UITextField) {
        if textField.text?.count == 1 {
            if textField.text?.first == " " {
                textField.text = ""
                return
            }
        }
        guard
            let domainName = domainTextField.text, !domainName.isEmpty,
            let username = userNameTextField.text, !username.isEmpty,
            let password = passwordTextField.text, !password.isEmpty,
            let appId = appIdTextField.text, !appId.isEmpty
            else {
                buttonLogin.isEnabled = false
                return
        }
        buttonLogin.isEnabled = true
    }
    
     func autoFillRecentAccount()
     {
          if  let domainName = UserStorage.string(forKey: KintoneConstants.DOMAIN_KEY) {
               domainTextField.text = domainName
          }
          
          if let username = UserStorage.string(forKey: KintoneConstants.USERNAME_KEY) {
               userNameTextField.text = username
          }
          
          if let appId = UserStorage.string(forKey: KintoneConstants.APP_ID_KEY) {
               appIdTextField.text = appId
          }
          
          if UserStorage.data(forKey: KintoneConstants.CERT_DATA) != nil {
               certFileLabelField.text = UserStorage.string(forKey: KintoneConstants.CERT_FIlE_NAME)
          } else {
               certFileUIField.isHidden = true
          }
     }
     
    func validateFormFields() -> Bool
    {
        let domainName = domainTextField.text!
        let username = userNameTextField.text!
        let password = passwordTextField.text!
        let appId = appIdTextField.text!
        
        if domainName.isEmpty
        {
            self.alert(message: ValidationErrorMessages.msgEmptyDomain)
        }
        
        if username.isEmpty
        {
            self.alert(message: ValidationErrorMessages.msgEmptyName)
        }
        
        if password.isEmpty
        {
            self.alert(message: ValidationErrorMessages.msgEmptyPassword)
        }
        
        if appId.isEmpty
        {
            self.alert(message: "\(ValidationErrorMessages.msgEmptyText) for App Id")
        }
        if !appIdTextField.isNumberValid(text: appId)
        {
            self.alert(message: "\(ValidationErrorMessages.msgInvalidNumber) for App Id")
        }
        
        return true
    }
    func authenticationWithKintone() -> Promise<Bool> {
          let domainName = self.domainTextField.text!
          let username = self.userNameTextField.text!
          let password = self.passwordTextField.text!
          let appId = Int(self.appIdTextField.text!)!
          let certPassword = self.certPasswordField.text
          var auth = Auth()
               .setPasswordAuth(username, password)
          if certData != nil && certPassword != nil && certPassword != ""{
               auth = auth.setClientCert(certData!, certPassword!)
          }
          let connection = Connection( domainName, auth )
          let app = App(connection)
     
          return Promise<Bool> { fulfill, reject in
               app.getApp(appId).then{ appInfo in
                    AppCommon.shared.setAppId(appInfo.getAppId()!)
                    AppCommon.shared.setAppName(appInfo.getName()!)
                    AppCommon.shared.setConnection(connection)
                    fulfill(true)
               }.catch{error in
                    reject(error)
               }
          }
    }
     public func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentAt url: URL) {
          let myURL = url as URL
          do {
               certData = try Data(contentsOf: myURL)
               certFileLabelField.text = myURL.lastPathComponent
               certFileUIField.isHidden = false
               
               self.UserStorage.set(myURL.lastPathComponent, forKey: KintoneConstants.CERT_FIlE_NAME)
               
          } catch {
               print(error)
          }
     }
     func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
          dismiss(animated: true, completion: nil)
     }
}
