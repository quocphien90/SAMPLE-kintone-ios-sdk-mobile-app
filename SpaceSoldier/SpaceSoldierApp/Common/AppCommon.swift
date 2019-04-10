//  Copyright © 2018 Cybozu. All rights reserved.

import kintone_ios_sdk

public class AppCommon {
    private var appId: Int?
    private var appName: String?
    private var connection: Connection?
    
    public static let shared = AppCommon()
    
    private init(){}
    
    init(_ appId: Int?, _ appName: String?, _ connection: Connection?)
    {
        self.appId = appId
        self.appName = appName
        self.connection = connection
    }
    
    
    public func setConnection(_ connection: Connection?)
    {
        self.connection = connection
    }
    
    public func setAppId(_ appId: Int?)
    {
        self.appId = appId
    }
    
    public func setAppName(_ appName: String?)
    {
        self.appName = appName
    }
    
    public func getConnection() -> Connection?
    {
        return self.connection
    }
    
    public func getAppId() -> Int?
    {
        return self.appId
    }
    
    public func getAppName() -> String?
    {
        return self.appName
    }
    
    public func getUserTimezone() -> String {
        let domainName = UserDefaults.standard.string(forKey: KintoneConstants.DOMAIN_KEY)
        let username = UserDefaults.standard.string(forKey: KintoneConstants.USERNAME_KEY)
        let encryptedPassword = UserDefaults.standard.array(forKey: KintoneConstants.PASSWORD_KEY) as! [UInt8]
        
        let certFile = UserDefaults.standard.data(forKey: KintoneConstants.CERT_DATA)
        let certPassword = UserDefaults.standard.string(forKey: KintoneConstants.CERT_PASSWORD)
        
        let rawPassword = try! CryptoAESCommon.decrypt(encryptedPassword)
        var session = URLSession(configuration: URLSessionConfiguration.default)
        
        if certFile != nil && certPassword != nil {
            let delegateForCert = URLSessionPinningDelegate(domainName)
            delegateForCert.setCertByData(certFile, certPassword)
            session = URLSession(configuration: URLSessionConfiguration.default,delegate: delegateForCert, delegateQueue: OperationQueue.current)
        }
        
        var timezoneString = ""
        let urlString = "https://\(domainName!)/v1/users.json?codes[0]=" + username!
        let url = URL(string: urlString)!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        let authString = "\(username!):\(rawPassword)".data(using: String.Encoding.utf8)
        let base64Auth = authString?.base64EncodedString()
        request.setValue(base64Auth!, forHTTPHeaderField: "X-Cybozu-Authorization")
        _ = session.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                return
            }
            
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
            }
            let responseString = String(data: data, encoding: .utf8)
            
            let decoder: JSONDecoder = JSONDecoder()
            let respData = responseString!.data(using: .utf8)
            let resp = try! decoder.decode(UserList.self, from: respData!)
            timezoneString = resp.getUsers()[0].getTimezone()!
        }.resume()
        return timezoneString
    }
}

