//
//  MailingListSignupViewController.swift
//  MPMailingListService
//
//  Created by Matias Piipari on 09/09/2016.
//  Copyright © 2016 Matias Piipari & Co. All rights reserved.
//

import Cocoa

@objc public protocol MailingListSignupViewControllerDelegate {
    func shouldDismissSignupViewController(_ signupViewController:MailingListSignupViewController)
}

@IBDesignable
@objc(MailingListSignupViewController) open class MailingListSignupViewController: NSViewController, MailingListServiceDataSource {

    @IBInspectable @objc open var icon:NSImage? { didSet {
        self.signupTitleImageView?.image = icon ?? NSApplication.shared.applicationIconImage
        }
    }
    @IBOutlet open weak var signupTitleImageView:NSImageView?
    
    // these strings just such as to avoid Nib loading time crashes with bad error messages
    // there are more meaningful defaults in the signup window controller class, also with IBInspectable properties.
    
    @IBInspectable @objc open var signupTitle:String? { didSet {
        self.signupTitleField.stringValue = signupTitle ?? ""
        }
    }
    @IBOutlet weak var signupTitleField: NSTextField!
    
    @IBInspectable @objc open var signupPrompt:String? { didSet {
        self.signUpButton.title = signupPrompt ?? ""
        }
    }
    
    @IBInspectable @objc open var dismissPrompt:String? { didSet {
        self.noThanksButton.title = dismissPrompt ?? ""
        }
    }
    @IBOutlet weak var noThanksButton: NSButton!
    
    @IBInspectable @objc open var signupMessage:String? { didSet {
        self.signupMessageField.stringValue = signupMessage ?? ""
        }
    }
    @IBOutlet weak var signupMessageField: NSTextField!
    
    @IBInspectable @objc open var signupThankYou:String? { didSet {
            self.thankYouField.stringValue = signupThankYou ?? ""
        }
    }
    @IBOutlet weak var thankYouField: NSTextField!
    
    fileprivate var mailingListService:MailingListService?
    
    open var listType:MailingListType = .newsletter
    
    @IBOutlet open weak var dismissButton: NSButton!
    @IBOutlet open weak var signUpButton: NSButton!
    @IBOutlet open weak var emailAddressField: NSTextField!
    
    @IBOutlet weak open var delegate:MailingListSignupViewControllerDelegate?
    
    @objc open var APIKey:String?
    @objc open var listID:String?
    
    @objc(signUp:) @IBAction func signUp(_ sender:AnyObject?) {
        self.mailingListService?.signUp(emailAddress: self.emailAddressField.stringValue,
                                        listType: self.listType)
        { error in
            if let error = error {
                DispatchQueue.main.async {
                    self.presentError(error)
                }
                return
            }
            
            DispatchQueue.main.async {
                self.emailAddressField.isBordered = false
                self.emailAddressField.drawsBackground = false
                self.emailAddressField.animator().isHidden = true
                
                self.thankYouField.stringValue = self.signupThankYou ?? ""
                self.thankYouField.animator().isHidden = false
                
                self.dismissButton.isHidden = true
                
                self.signUpButton.title = "Close"
                self.signUpButton.action = #selector(MailingListSignupViewController.dismiss(_:))
            }
        }
    }
    
    @objc(dismiss:) @IBAction func dismiss(_ sender:AnyObject?) {
        self.delegate?.shouldDismissSignupViewController(self)
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        self.mailingListService = MailingListService(dataSource:self)
        self.emailAddressField.becomeFirstResponder()
    }
    
    @objc open var emailAddressIsValid:Bool {
        return self.emailAddressField.stringValue.isValidEmailAddress
    }
    
    // MARK: MailingListServiceDataSource
    
    open func APIKey(mailingListService service: MailingListService) -> String {
        guard let apiKey = self.APIKey else {
            preconditionFailure("self.APIKey is required")
        }
        
        return apiKey
    }
    
    open func listIdentifier(mailingListService service: MailingListService,
                                                  listType: MailingListType) -> String {
        guard let listIdentifier = self.listID else {
            preconditionFailure("self.listID is required")
        }
        
        return listIdentifier
    }

}


extension MailingListSignupViewController: NSTextFieldDelegate {
    
    open override func controlTextDidChange(_ obj: Notification) {
        self.signUpButton.isEnabled = self.emailAddressIsValid
    }
}
