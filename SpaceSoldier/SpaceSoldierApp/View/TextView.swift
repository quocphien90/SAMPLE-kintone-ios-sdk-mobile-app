//
//  TextView.swift
//  sampleAppUsingKintoneIOSSDK
//
//  Created by Cuc Kim on 10/12/18.
//  Copyright © 2018 Cuc Kim. All rights reserved.
//

import UIKit

class TextView: UITextView {
    
    var border: UIView
    var originalBorderFrame: CGRect
    var originalInsetBottom: CGFloat
    
    deinit {
        removeObserver(self, forKeyPath: "contentOffset")
    }
    
    override var frame: CGRect {
        didSet {
            border.frame = CGRectMake(0, frame.height+contentOffset.y-border.frame.height, frame.width, border.frame.height)
            originalBorderFrame  = CGRectMake(0, frame.height-border.frame.height, frame.width, border.frame.height);
        }
    }
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if keyPath == "contentOffset" {
            border.frame = CGRectOffset(originalBorderFrame, 0, contentOffset.y)
        }
    }
    
    func addBottomBorderWithColor(color: UIColor, width: CGFloat) {
        border.backgroundColor = color
        border.frame = CGRectMake(0, frame.height+contentOffset.y-width, self.frame.width, width)
        originalBorderFrame = CGRectMake(0, frame.height-width, self.frame.width, width)
        textContainerInset.bottom = originalInsetBottom+width
    }
}
