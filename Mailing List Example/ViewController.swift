//
//  ViewController.swift
//  Mailing List Example
//
//  Created by Matias Piipari on 09/09/2016.
//  Copyright © 2016 Matias Piipari & Co. All rights reserved.
//

import Cocoa
import MPMailingListService


extension NSView {
    
    public func mp_addSubviewConstrainedToSuperViewEdges(aView:NSView,
                                                         topOffset:CGFloat = 0,
                                                         rightOffset:CGFloat = 0,
                                                         bottomOffset:CGFloat = 0,
                                                         leftOffset:CGFloat = 0) {
        
        aView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(aView)
        
        self.mp_addEdgeConstraint(.Left, constantOffset: leftOffset, subview: aView)
        self.mp_addEdgeConstraint(.Right, constantOffset: rightOffset, subview: aView)
        self.mp_addEdgeConstraint(.Top, constantOffset: topOffset, subview: aView)
        self.mp_addEdgeConstraint(.Bottom, constantOffset: bottomOffset, subview: aView)
    }
    
    public func mp_addEdgeConstraint(edge:NSLayoutAttribute,
                                     constantOffset:CGFloat = 0,
                                     subview:NSView) -> NSLayoutConstraint {
        let constraint:NSLayoutConstraint
            = NSLayoutConstraint(item:subview,
                                 attribute:edge,
                                 relatedBy:.Equal,
                                 toItem:self,
                                 attribute:edge,
                                 multiplier:1,
                                 constant:constantOffset)
        
        self.addConstraint(constraint)
        
        return constraint;
    }
}

class ViewController: NSViewController {

    private var signupViewController:MailingListSignupViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let bundle = NSBundle(forClass: MailingListSignupViewController.self)
        self.signupViewController = MailingListSignupViewController(nibName: nil, bundle:bundle)
        
        self.view.mp_addSubviewConstrainedToSuperViewEdges(signupViewController!.view)
    }

    override var representedObject: AnyObject? {
        didSet {
        // Update the view, if already loaded.
        }
    }


}

