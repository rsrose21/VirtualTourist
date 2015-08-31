//
//  VCConvenience.swift
//  VirtualTourist
//
//  Created by Ryan Rose on 8/30/15.
//  Copyright (c) 2015 GE. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    
    func displayError(errorString: String?) {
        dispatch_async(dispatch_get_main_queue(), {
            if let errorString = errorString {
                let alert = UIAlertController(title: nil, message: errorString, preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
            }
        })
    }
    
}