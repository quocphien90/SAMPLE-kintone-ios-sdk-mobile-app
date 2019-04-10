//  Copyright © 2018 Cybozu. All rights reserved.

import UIKit
import kintone_ios_sdk
import Promises

extension UIImageView {
    func loadImage(fileKey: String, imageCache: NSCache<NSString, UIImage>) -> Promise<Void>{
        return Promise { fullfil, reject in
            if let cachedImage = imageCache.object(forKey: fileKey as NSString) {
                DispatchQueue.main.async {
                    self.image = cachedImage
                }
                fullfil(())
            } else {
                self.dowLoadFile(fileKey: fileKey).then{ fileData in
                    let imageData = UIImage(data: fileData)
                    DispatchQueue.main.async {
                        if imageData != nil {
                            imageCache.setObject(self.resizeImage(image: imageData!, targetSize: CGSize(width: 100.0, height: 100.0)), forKey: fileKey as NSString)
                            self.image  = imageData!
                        }
                    }
                    fullfil(())
                }
            }
    
            
    }
    
    }
    
    func dowLoadFile(fileKey: String) -> Promise<Data> {
        let jsonBody = "{\"fileKey\": \"\(fileKey)\"}"
        return Promise{fulfill, reject in
            AppCommon.shared.getConnection()!.downloadFile(jsonBody)
            .then{ fileModule in
                fulfill(fileModule)
            }.catch { error in
                if type(of: error) is KintoneAPIException.Type
                {
                    print((error as! KintoneAPIException).toString()!)
                } else {
                    print(error.localizedDescription)
                }
            }
        }
    }
    
    func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size
        
        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height
        
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
        }
        
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
}
