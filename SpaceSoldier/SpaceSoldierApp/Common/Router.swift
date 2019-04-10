//  Copyright © 2018 Cuc Kim. All rights reserved.

import UIKit
import kintone_ios_sdk
import CryptoSwift
import Promises

class Router {
    static let UserStorage = UserDefaults.standard
    static func updateRootViewController() -> Promise<Void>{
        var rootViewController : UIViewController?
        var status: Bool? = false
        status = UserStorage.bool(forKey: KintoneConstants.AUTHENTICATE_KEY)
        
        let sb = UIStoryboard(name: "Main", bundle: nil)
        return Promise { fulfill, reject in
            if(status == true) {
                autoSignInWithKintone().then{_ in
                    rootViewController = sb.instantiateViewController(withIdentifier: "ListRecordController") as! ListRecordController
                    setRootViewController(rootViewController: rootViewController!)
                    fulfill(())
                }.catch{error in
                    reject (error)
                    if type(of: error) is KintoneAPIException.Type
                    {
                        print((error as! KintoneAPIException).toString()!)
                    } else {
                        print(error.localizedDescription)
                    }
                }
            } else{
                DispatchQueue.main.async {
                    rootViewController = sb.instantiateViewController(withIdentifier: "LoginController") as! LoginController
                    setRootViewController(rootViewController: rootViewController!)
                }
                fulfill(())
            }
        }
        
    }
    
    static func setRootViewController(rootViewController: UIViewController) {
        let navigationController = UINavigationController(rootViewController: rootViewController)
        navigationController.navigationBar.barTintColor = UIColor(red: 81/255, green: 161/255, blue: 219/255, alpha: 1)
        navigationController.navigationBar.tintColor = UIColor.white
        navigationController.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor:UIColor.white]
        
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.window?.rootViewController = navigationController
    }
    
    static func autoSignInWithKintone() -> Promise<Void> {
        let domainName = UserStorage.string(forKey: KintoneConstants.DOMAIN_KEY)
        let username = UserStorage.string(forKey: KintoneConstants.USERNAME_KEY)
        let encryptedPassword = UserStorage.array(forKey: KintoneConstants.PASSWORD_KEY) as! [UInt8]
        let appId = UserStorage.integer(forKey: KintoneConstants.APP_ID_KEY)
        let rawPassword = try! CryptoAESCommon.decrypt(encryptedPassword)
        
        let certFile = UserDefaults.standard.data(forKey: KintoneConstants.CERT_DATA)
        let certPassword = UserDefaults.standard.string(forKey: KintoneConstants.CERT_PASSWORD)
        
        var auth = Auth().setPasswordAuth(username!, rawPassword)
        
        if certFile != nil && certPassword != nil {
            auth = auth.setClientCert(certFile!, certPassword!)
        }
        let connection = Connection(domainName!, auth)
        
        let app = App(connection)
        return Promise{fulfill, reject in
            app.getApp(appId).then{ appInfo in
                AppCommon.shared.setAppId(appInfo.getAppId()!)
                AppCommon.shared.setAppName(appInfo.getName()!)
                AppCommon.shared.setConnection(connection)
                fulfill(())
            }.catch { error in
                reject(error)
            }
        }
    }
}
