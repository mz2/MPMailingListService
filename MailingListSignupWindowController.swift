//
//  MailingListSignupWindowController.swift
//  MPMailingListService
//
//  Created by Matias Piipari on 10/09/2016.
//  Copyright © 2016 Matias Piipari & Co. All rights reserved.
//

import Foundation

@IBDesignable public class MailingListSignupWindowController: NSWindowController, NSWindowDelegate {
    
    @IBInspectable public var APIKey:String?
        { didSet { self.listSignupViewController?.APIKey = APIKey } }
    
    @IBInspectable public var listID:String?
        { didSet { self.listSignupViewController?.listID = listID } }
    
    @IBInspectable @objc public var appIcon:NSImage = NSApplication.sharedApplication().applicationIconImage
        { didSet { self.listSignupViewController?.appIcon = appIcon } }
    
    @IBInspectable @objc public var signupTitle:String? = "Sign up to our newsletter"
        { didSet { self.listSignupViewController?.signupTitle = signupTitle ?? "" } }
    
    @IBInspectable @objc public var signupPrompt:String? = "Sign up"
        { didSet { self.listSignupViewController?.signupPrompt = signupPrompt ?? "" } }
    
    @IBInspectable @objc public var dismissPrompt:String? = "No, Thanks"
        { didSet { self.listSignupViewController?.dismissPrompt = dismissPrompt ?? "" } }
    
    @IBInspectable @objc public var signupMessage:String? = "Sign up to receive news and updates on \(productName)!\n\nWe will email you with instructions to get started, and will update you on news and special deals."
        { didSet { self.listSignupViewController?.signupMessage = signupMessage ?? "" } }
    
    @IBInspectable @objc public var signupThankYou:String? = "Thanks for signing up!"
        { didSet { self.listSignupViewController?.signupThankYou = signupThankYou ?? "" } }
    
    private var listSignupViewController:MailingListSignupViewController?
    
    @objc public class var productName: String {
        return NSBundle.mainBundle().infoDictionary?["CFBundleName"] as? String
            ?? "<Your app whose bundle lacks Info.plist key 'CFBundleName'>"
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    public override init(window: NSWindow?) {
        super.init(window:window)
    }
    
    public override func loadWindow() {
        self.loadWindow()
    }
    
    public override func awakeFromNib() {
        super.awakeFromNib()
        let signupVC = MailingListSignupViewController(nibName: nil, bundle: self.bundleForSignupNib)
        signupVC?.delegate = self
        self.listSignupViewController = signupVC
        self.contentViewController = signupVC
    }
    
    public override func windowDidLoad() {
        super.windowDidLoad()
    }
    
    // override in subclass if you want to use a custom MailingListSignupViewController subclass
    var signupViewControllerClass: MailingListSignupViewController.Type {
        return MailingListSignupViewController.self
    }
    
    // override in subclass if you want to use a custom MailingListSignupViewController subclass…
    // but for instance the original Nib
    var bundleForSignupNib: NSBundle {
        return NSBundle(forClass: self.signupViewControllerClass)
    }
}

extension MailingListSignupWindowController: MailingListSignupViewControllerDelegate {
    public func shouldDismissSignupViewController(signupViewController: MailingListSignupViewController) {
        self.window?.close()
    }
}
