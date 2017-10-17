//
//  MailingListSignupWindowController.swift
//  MPMailingListService
//
//  Created by Matias Piipari on 10/09/2016.
//  Copyright © 2016 Matias Piipari & Co. All rights reserved.
//

import Foundation

@objc public protocol MailingListSignupWindowControllerDelegate {
    @objc (didDismissMailingListSignupWindowController:) func didDismiss(mailingListSignupWindowController controller:MailingListSignupWindowController)
}

@IBDesignable @objc open class MailingListSignupWindowController: NSWindowController, NSWindowDelegate {
    
    @IBOutlet weak open var delegate:MailingListSignupWindowControllerDelegate?
    
    @IBInspectable open var APIKey:String?
        { didSet { self.listSignupViewController?.APIKey = APIKey } }
    
    @IBInspectable open var listID:String?
        { didSet { self.listSignupViewController?.listID = listID } }
    
    @IBInspectable @objc open var icon:NSImage?
        { didSet { self.listSignupViewController?.icon = icon ?? NSApplication.shared.applicationIconImage } }
    
    @IBInspectable @objc open var signupTitle:String?
        { didSet { self.listSignupViewController?.signupTitle = signupTitle } }
    
    @IBInspectable @objc open var signupPrompt:String?
        { didSet { self.listSignupViewController?.signupPrompt = signupPrompt } }
    
    @IBInspectable @objc open var dismissPrompt:String?
        { didSet { self.listSignupViewController?.dismissPrompt = dismissPrompt } }
    
    @IBInspectable @objc open var signupMessage:String?
        { didSet { self.listSignupViewController?.signupMessage = signupMessage } }
    
    @IBInspectable @objc open var signupThankYou:String?
        { didSet {
            self.listSignupViewController?.signupThankYou = signupThankYou ?? ""
        }
    }
    
    @objc fileprivate(set) open var listSignupViewController:MailingListSignupViewController?
    
    @objc open class var productName: String {
        return Bundle.main.infoDictionary?["CFBundleName"] as? String
            ?? "<Your app whose bundle lacks Info.plist key 'CFBundleName'>"
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    public override init(window: NSWindow?) {
        super.init(window:window)
    }
    
    open override func awakeFromNib() {
        super.awakeFromNib()
        let signupVC = MailingListSignupViewController(nibName: nil, bundle: self.bundleForSignupNib)
        signupVC.delegate = self
        self.listSignupViewController = signupVC
        self.contentViewController = signupVC
        
        self.signupTitle = "Sign up to our newsletter"
        self.signupPrompt = "Sign up"
        self.dismissPrompt = "No, Thanks"
        self.signupMessage = "Sign up to receive news and updates on \(type(of: self).productName)!\n\nWe will email you with instructions to get started, and will update you on news and special deals."
        self.signupThankYou = "Thanks for signing up!"
    }
    
    open override func windowDidLoad() {
        super.windowDidLoad()
    }
    
    // override in subclass if you want to use a custom MailingListSignupViewController subclass
    var signupViewControllerClass: MailingListSignupViewController.Type {
        return MailingListSignupViewController.self
    }
    
    // override in subclass if you want to use a custom MailingListSignupViewController subclass…
    // but for instance the original Nib
    var bundleForSignupNib: Bundle {
        return Bundle(for: self.signupViewControllerClass)
    }
}

extension MailingListSignupWindowController: MailingListSignupViewControllerDelegate {
    public func shouldDismissSignupViewController(_ signupViewController: MailingListSignupViewController) {
        self.delegate?.didDismiss(mailingListSignupWindowController: self)
        self.window?.close()
    }
}
