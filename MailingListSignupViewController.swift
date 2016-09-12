//
//  MailingListSignupViewController.swift
//  MPMailingListService
//
//  Created by Matias Piipari on 09/09/2016.
//  Copyright © 2016 Matias Piipari & Co. All rights reserved.
//

import Cocoa

@objc public protocol MailingListSignupViewControllerDelegate {
    func shouldDismissSignupViewController(signupViewController:MailingListSignupViewController)
}

@IBDesignable
public class MailingListSignupViewController: NSViewController, MailingListServiceDataSource {

    @IBInspectable @objc public var icon:NSImage? { didSet {
        self.signupTitleImageView?.image = icon ?? NSApplication.sharedApplication().applicationIconImage
        }
    }
    @IBOutlet public weak var signupTitleImageView:NSImageView?
    
    // these strings just such as to avoid Nib loading time crashes with bad error messages
    // there are more meaningful defaults in the signup window controller class, also with IBInspectable properties.
    
    @IBInspectable @objc public var signupTitle:String? { didSet {
        self.signupTitleField.stringValue = signupTitle ?? ""
        }
    }
    @IBOutlet weak var signupTitleField: NSTextField!
    
    @IBInspectable @objc public var signupPrompt:String? { didSet {
        self.signUpButton.title = signupPrompt ?? ""
        }
    }
    
    @IBInspectable @objc public var dismissPrompt:String? { didSet {
        self.noThanksButton.title = dismissPrompt ?? ""
        }
    }
    @IBOutlet weak var noThanksButton: NSButton!
    
    @IBInspectable @objc public var signupMessage:String? { didSet {
        self.signupMessageField.stringValue = signupMessage ?? ""
        }
    }
    @IBOutlet weak var signupMessageField: NSTextField!
    
    @IBInspectable @objc public var signupThankYou:String? { didSet {
            self.thankYouField.stringValue = signupThankYou ?? ""
        }
    }
    @IBOutlet weak var thankYouField: NSTextField!
    
    private var mailingListService:MailingListService?
    
    public var listType:MailingListType = .Newsletter
    
    @IBOutlet public weak var dismissButton: NSButton!
    @IBOutlet public weak var signUpButton: NSButton!
    @IBOutlet public weak var emailAddressField: NSTextField!
    
    @IBOutlet weak var delegate:MailingListSignupViewControllerDelegate?
    
    public var APIKey:String?
    public var listID:String?
    
    @objc(signUp:) @IBAction func signUp(sender:AnyObject?) {
        self.mailingListService?.signUp(emailAddress: self.emailAddressField.stringValue,
                                        listType: self.listType)
        { error in
            if let error = error as? NSError {
                dispatch_async(dispatch_get_main_queue()) {
                    self.presentError(error)
                }
                return
            }
            
            dispatch_async(dispatch_get_main_queue()) {
                self.emailAddressField.bordered = false
                self.emailAddressField.drawsBackground = false
                self.emailAddressField.animator().hidden = true
                
                self.thankYouField.stringValue = self.signupThankYou ?? ""
                self.thankYouField.animator().hidden = false
                
                self.dismissButton.hidden = true
                
                self.signUpButton.title = "Close"
                self.signUpButton.action = #selector(MailingListSignupViewController.dismiss(_:))
            }
        }
    }
    
    @objc(dismiss:) @IBAction func dismiss(sender:AnyObject?) {
        self.delegate?.shouldDismissSignupViewController(self)
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        self.mailingListService = MailingListService(dataSource:self)
        self.emailAddressField.becomeFirstResponder()
    }
    
    @objc public var emailAddressIsValid:Bool {
        return self.emailAddressField.stringValue.isValidEmailAddress
    }
    
    // MARK: MailingListServiceDataSource
    
    public func APIKey(mailingListService service: MailingListService) -> String {
        guard let apiKey = self.APIKey else {
            preconditionFailure("self.APIKey is required")
        }
        
        return apiKey
    }
    
    public func listIdentifier(mailingListService service: MailingListService,
                                                  listType: MailingListType) -> String {
        guard let listIdentifier = self.listID else {
            preconditionFailure("self.listID is required")
        }
        
        return listIdentifier
    }

}


extension MailingListSignupViewController: NSTextFieldDelegate {
    
    public override func controlTextDidChange(obj: NSNotification) {
        self.signUpButton.enabled = self.emailAddressIsValid
    }
}
