//
//  MailingListService.swift
//  MPMailingListService
//
//  Created by Matias Piipari on 09/09/2016.
//  Copyright © 2016 Matias Piipari & Co. All rights reserved.
//

import Foundation
import ChimpKit

public enum MailingListType:UInt {
    case Newsletter = 1 // TODO: model this as a freeform value if requested.
}

public protocol MailingListServiceDataSource {
    func APIKey(mailingListService service: MailingListService) -> String
    func listIdentifier(mailingListService service: MailingListService, listType:MailingListType) -> String
}

public typealias MailingListServiceSignupCompletionBlock = (Swift.Error?) -> Void

public struct MailingListService {
    
    public static let ErrorDomain = "MailingListServiceErrorDomain"
    
    public init(dataSource:MailingListServiceDataSource) {
        self.dataSource = dataSource
    }
    
    public enum Error:Swift.Error {
        case unexpectedResponse
        case alreadySignedUp
        case emptyResponse
        case responseDataNotJSON(NSData?)
        case errorCodeNotNumber([String:AnyObject])
        
        public var code:Code {
            switch self {
            case .alreadySignedUp: return 1
            case .emptyResponse: return 2
            case .errorCodeNotNumber(_): return 3
            case .responseDataNotJSON(_): return 5
            case .unexpectedResponse: return 6
            }
        }
        
        public var presentableDescription: String {
            switch self {
            
            case .alreadySignedUp:
                return "Email address is already signed up."
            
            case .emptyResponse:
                return "Empty response from server. Please contact customer support if this persists."
            
            case .unexpectedResponse,
                 .responseDataNotJSON(_),
                 .errorCodeNotNumber(_):
                return "Unexpected response from server. Please contact customer support if this persists."
            }
        }
        
        public var presentableRecoverySuggestion: String {
            switch self {
                
            case .alreadySignedUp:
                return "Email address looks to be already signed up.\nPlease contact support if you believe this is an error."
                
            case .emptyResponse:
                return "Empty response from server.\nPlease contact support if this persists."
                
            case .unexpectedResponse,
                 .responseDataNotJSON(_),
                 .errorCodeNotNumber(_):
                return "Unexpected response from server.\nPlease contact support if this persists."
            }
        }
        
        public var presentableRepresentation:NSError {
            return NSError(domain: ErrorDomain,
                           code: self.code.rawValue,
                           userInfo: [ NSLocalizedDescriptionKey: self.presentableDescription,
                            NSLocalizedRecoverySuggestionErrorKey: self.presentableRecoverySuggestion ])
        }
    }
    
    private(set) public var dataSource:MailingListServiceDataSource?
    private let chimpKit = ChimpKit()
        
    public func signUp(emailAddress address:String,
                                    listType:MailingListType,
                                    completionHandler: MailingListServiceSignupCompletionBlock) {
        
        guard let listID = self.dataSource?.listIdentifier(mailingListService: self, listType: listType) else {
            preconditionFailure("Missing data source")
        }
        
        let params:[String:Any] = ["id": listID, "email": ["email":address]]
        
        self.chimpKit.apiKey = self.dataSource?.APIKey(mailingListService: self)
        self.chimpKit.callApiMethod("lists/subscribe", withParams: params) { response, data, error in
            if let error = error {
                DispatchQueue.main.async {
                    completionHandler(error:error)
                }
                return
            }
            
            guard let HTTPResponse = response as? NSHTTPURLResponse else {
                preconditionFailure("Response ought to be a HTTP response: \(response)")
            }
            
            let statusCode = HTTPResponse.statusCode
            if (200...299).contains(statusCode) {
                completionHandler(error:nil)
                return
            }
            
            do {
                guard let respData = data,
                      let dict = try JSONSerialization.JSONObjectWithData(respData,
                                                                            options: []) as? [String:AnyObject]
                    else {
                        completionHandler(error:Error.EmptyResponse.presentableRepresentation)
                        return
                }
                
                guard let codeNum = dict["code"] as? NSNumber else {
                    completionHandler(error:Error.ErrorCodeNotNumber(dict).presentableRepresentation)
                    return
                }
                
                if codeNum.integerValue == 214 {
                    completionHandler(error: Error.AlreadySignedUp.presentableRepresentation)
                }
            }
            catch {
                completionHandler(error:Error.ResponseDataNotJSON(data).presentableRepresentation)
            }
        }
    }
}

