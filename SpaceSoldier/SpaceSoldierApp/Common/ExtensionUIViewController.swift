//  Copyright © 2018 Cybozu. All rights reserved.

import UIKit
extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func alert(message: String, title: String = "Error") {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let OKAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(OKAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    class func displaySpinner(onView : UIView) -> UIView {
        let spinnerView = UIView.init(frame: onView.bounds)
        spinnerView.backgroundColor = UIColor.init(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.5)
        let ai = UIActivityIndicatorView.init(style: .whiteLarge)
        ai.startAnimating()
        ai.center = spinnerView.center
        
        DispatchQueue.main.async {
            spinnerView.addSubview(ai)
            onView.addSubview(spinnerView)
        }
        
        return spinnerView
    }
    
    class func removeSpinner(spinner :UIView) {
        DispatchQueue.main.async {
            spinner.removeFromSuperview()
        }
    }
    class func EmptyMessage(message: String?, icon: String?, tableView: UITableView) {
        DispatchQueue.main.async {
            let view = UIView(frame: CGRect(origin: CGPoint(x: 0,y :0), size: CGSize(width: tableView.bounds.size.width, height: tableView.bounds.size.height)))
            let topSubView = UIView(frame: CGRect(origin: CGPoint(x: 0,y :0), size: CGSize(width: tableView.frame.width,height: 100)))
            view.addSubview(topSubView)
            
            let leftSubView = UIView(frame: CGRect(origin: CGPoint(x: 0,y :topSubView.frame.maxY), size: CGSize(width: (tableView.frame.width - 90)/2, height: 90)))
            view.addSubview(leftSubView)
            
            var labelY = topSubView.frame.maxY
            
            if (icon != nil) {
                let image = UIImage(named: icon!)
                let imageView = UIImageView(image: image!)
                imageView.frame = CGRect(x: leftSubView.frame.maxX, y: topSubView.frame.maxY, width: 90, height: 90)
                view.addSubview(imageView)
                labelY = imageView.frame.maxY
            }
            
            if (message != nil) {
                let rect = CGRect(origin: CGPoint(x: tableView.bounds.minX, y : labelY + 5), size: CGSize(width: tableView.bounds.size.width, height: 30))
                let messageLabel = UILabel(frame: rect)
                messageLabel.text = message
                messageLabel.textColor = UIColor.black
                messageLabel.numberOfLines = 0;
                messageLabel.textAlignment = .center;
                messageLabel.font = UIFont(name: "TrebuchetMS", size: 15)
                view.addSubview(messageLabel)
            }
            
            tableView.backgroundView = view;
        }
    }
    
    class func noComments(tableView: UITableView) {
        let noCommentsView = UIImageView()
        var image = UIImage(named: "no-comments")
        image = noCommentsView.resizeImage(image: image!, targetSize: CGSize(width: 120.0, height: 120.0))
        noCommentsView.image = image!
        noCommentsView.contentMode = .scaleToFill
        tableView.backgroundView = noCommentsView;
        tableView.backgroundView?.contentMode = .center
    }
}

extension UIView {
    func round(corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        self.layer.mask = mask
    }
    
    enum ViewSide {
        case Left, Right, Top, Bottom
    }
    
    func addBorder(toSide side: ViewSide, withColor color: CGColor, andThickness thickness: CGFloat, offsetX: CGFloat?) {
        let border = CALayer()
        border.backgroundColor = color
        let offsetXVal = offsetX != nil ? offsetX! : 0
        switch side {
        case .Left: border.frame = CGRect(x: frame.minX, y: frame.minY, width: thickness, height: frame.height); break
        case .Right: border.frame = CGRect(x: frame.maxX, y: frame.minY, width: thickness, height: frame.height); break
        case .Top: border.frame = CGRect(x: 0, y: 0, width: frame.width, height: thickness); break
        case .Bottom: border.frame = CGRect(x: 0 - offsetXVal, y: frame.height - thickness, width: (frame.width + offsetXVal * 2), height: thickness); break
        }
        layer.addSublayer(border)
    }
}
