//
//  URLSessionPinningDelegate.swift
//  SpaceSoldierApp
//
//  Created by Ho Kim Cuc on 1/8/19.
//  Copyright © 2019 Cuc Kim. All rights reserved.
//

import UIKit
import Security

class URLSessionPinningDelegate: NSObject, URLSessionDelegate
{
    private var domain: String?
    private var password: String?
    private var certData: Data?
    private var usePath: Bool?
    
    public init(_ domain: String?) {
        self.domain = domain
    }
    
    public func setCertByData( _ certData: Data?, _ password: String?) {
        self.password = password
        self.certData = certData!
        self.usePath = false
    }
    
    func didReceive(serverTrustChallenge challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        let customRoot = Bundle.main.certificate(named: "MouseCA")
        let trust = challenge.protectionSpace.serverTrust!
        if trust.evaluateAllowing(rootCertificates: [customRoot]) {
            completionHandler(.useCredential, URLCredential(trust: trust))
        } else {
            completionHandler(.cancelAuthenticationChallenge, nil)
        }
    }
    
    func didReceive(clientIdentityChallenge challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        var identity: SecIdentity
        identity = Bundle.main.identityData(certData: self.certData!, password: self.password!)
        completionHandler(.useCredential, URLCredential(identity: identity, certificates: nil, persistence: .forSession))
    }
    
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        var domainString = self.domain!
        if !domainString.hasPrefix("https://") {
            domainString = "https://" + domainString
        }
        switch (challenge.protectionSpace.authenticationMethod, "https://" + challenge.protectionSpace.host) {
        case (NSURLAuthenticationMethodClientCertificate, domainString):
            self.didReceive(clientIdentityChallenge: challenge, completionHandler: completionHandler)
        default:
            completionHandler(.performDefaultHandling, nil)
        }
    }
}
