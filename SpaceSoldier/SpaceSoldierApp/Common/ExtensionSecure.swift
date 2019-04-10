//
//  ExtensionCommon.swift
//  SpaceSoldierApp
//
//  Created by Ho Kim Cuc on 1/8/19.
//  Copyright © 2019 Cuc Kim. All rights reserved.
//

import UIKit

extension Bundle {
    
    func certificate(named name: String) -> SecCertificate {
        let cerURL = self.url(forResource: name, withExtension: "cer")!
        let cerData = try! Data(contentsOf: cerURL)
        let cer = SecCertificateCreateWithData(nil, cerData as CFData)!
        return cer
    }
    
    func identityData(certData: Data, password: String) -> SecIdentity {
        var importedCF: CFArray? = nil
        let options = [kSecImportExportPassphrase as String: password]
        let err = SecPKCS12Import(certData as CFData, options as CFDictionary, &importedCF)
        print(err)
        precondition(err == errSecSuccess)
        let imported = importedCF! as Array as! [[String:AnyObject]]
        precondition(imported.count == 1)
        return (imported[0][kSecImportItemIdentity as String]!) as! SecIdentity
    }
}
extension SecTrust {
    
    func evaluate() -> Bool {
        var trustResult: SecTrustResultType = .invalid
        let err = SecTrustEvaluate(self, &trustResult)
        guard err == errSecSuccess else { return false }
        return [.proceed, .unspecified].contains(trustResult)
    }
    
    func evaluateAllowing(rootCertificates: [SecCertificate]) -> Bool {
        // Apply our custom root to the trust object.
        var err = SecTrustSetAnchorCertificates(self, rootCertificates as CFArray)
        guard err == errSecSuccess else { return false }
        
        // Re-enable the system's built-in root certificates.
        err = SecTrustSetAnchorCertificatesOnly(self, false)
        guard err == errSecSuccess else { return false }
        
        // Run a trust evaluation and only allow the connection if it succeeds.
        return self.evaluate()
    }
}
