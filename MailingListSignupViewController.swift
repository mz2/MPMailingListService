//
//  MailingListSignupViewController.swift
//  MPMailingListService
//
//  Created by Matias Piipari on 09/09/2016.
//  Copyright © 2016 Matias Piipari & Co. All rights reserved.
//

import Cocoa

public class MailingListSignupViewController: NSViewController, MailingListServiceDataSource {

    @objc public var appIcon:NSImage = NSApplication.sharedApplication().applicationIconImage
    @objc public var signupWindowTitle:String = "Newsletter"
    @objc public var signupTitle:String = "Sign up to our newsletter"
    @objc public var signupPrompt:String = "Sign up"
    @objc public var dismissPrompt:String = "No, Thanks"
    @objc public var signupMessage:String = "Sign up to receive news and updates on \(productName)!\n\nWe will email you with instructions to get started, and will update you on news and special deals."
    @objc public var signupThankYou:String = "Thanks for signing up!"
    
    private var mailingListService:MailingListService?
    
    public var listType:MailingListType = .Newsletter
    
    @IBOutlet weak var dismissButton: NSButton!
    @IBOutlet weak var signUpButton: NSButton!
    @IBOutlet weak var emailAddressField: NSTextField!
    @IBOutlet weak var thankYouField: NSTextField!
    
    @objc public class var productName: String {
        return NSBundle.mainBundle().infoDictionary?["CFBundleName"] as? String
                ?? "<Your app whose bundle lacks Info.plist key 'CFBundleName'>"
    }
    
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
                self.emailAddressField.stringValue = self.signupThankYou
                self.emailAddressField.animator().hidden = true
                
                self.thankYouField.stringValue = self.signupThankYou
                self.thankYouField.animator().hidden = false
                
                self.dismissButton.hidden = true
                
                self.signUpButton.title = "Close"
                self.signUpButton.action = #selector(MailingListSignupViewController.dismiss(_:))
            }
        }
    }
    
    @objc(dismiss:) @IBAction func dismiss(sender:AnyObject?) {
        self.view.window?.close()
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        self.mailingListService = MailingListService(dataSource:self)
        self.emailAddressField.becomeFirstResponder()
    }
    
    public override func viewWillAppear() {
        self.view.window?.title = self.signupWindowTitle
    }
    
    @objc public var emailAddressIsValid:Bool {
        return self.emailAddressField.stringValue.isValidEmailAddress
    }
    
    // MARK: MailingListServiceDataSource
    
    @objc public func APIKey(mailingListService service: MailingListService) -> String {
        preconditionFailure("Return your Mailchimp API key here.")
    }
    
    @objc public func listIdentifier(mailingListService service: MailingListService,
                                                  listType: MailingListType) -> String {
        preconditionFailure("Return your Mailchimp list identifier here.")
    }

}


extension MailingListSignupViewController: NSTextFieldDelegate {
    
    public override func controlTextDidChange(obj: NSNotification) {
        self.signUpButton.enabled = self.emailAddressIsValid
    }
}
