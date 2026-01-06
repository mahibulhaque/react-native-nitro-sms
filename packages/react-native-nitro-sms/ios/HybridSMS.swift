import Foundation
import NitroModules
import MessageUI
import CoreServices
import MobileCoreServices
import UniformTypeIdentifiers

class HybridSMS:HybridSMSSpec{
    
    private var smsContext: SMSContext?
    
    func isAvailable() throws -> Promise<Bool> {
        return Promise.async{
            return await MFMessageComposeViewController.canSendText()
        }
    }
    
    func sendSMS(numbers: [String], message: String, options: SMSOptions?) throws -> Promise<SMSResponse> {
        return Promise.async {
            // Check if SMS is available
            guard MFMessageComposeViewController.canSendText() else {
                throw NSError(
                    domain: "SMSError",
                    code: 1,
                    userInfo: [NSLocalizedDescriptionKey: "SMS service is not available"]
                )
            }
            
            // Check if there's already a pending SMS
            if self.smsContext != nil {
                throw NSError(
                    domain: "SMSError",
                    code: 2,
                    userInfo: [NSLocalizedDescriptionKey: "SMS sending in progress, await the old request and then try again"]
                )
            }
            
            return try await withCheckedThrowingContinuation { continuation in
                DispatchQueue.main.async {
                    do {
                        let smsDelegate = SMSDelegate { result in
                            self.smsContext = nil
                            continuation.resume(returning: result)
                        } onFailure: { error in
                            self.smsContext = nil
                            continuation.resume(throwing: NSError(
                                domain: "SMSError",
                                code: 3,
                                userInfo: [NSLocalizedDescriptionKey: error]
                            ))
                        }
                        
                        let context = SMSContext(smsDelegate: smsDelegate)
                        
                        let messageComposeViewController = MFMessageComposeViewController()
                        messageComposeViewController.messageComposeDelegate = context.smsDelegate
                        messageComposeViewController.recipients = numbers
                        messageComposeViewController.body = message
                        
                        // Handle attachments if provided
                        if let options = options {
                            for attachment in options.attachments {
                                guard let utiRef = UTTypeCreatePreferredIdentifierForTag(
                                    kUTTagClassMIMEType,
                                    attachment.mimeType as CFString,
                                    nil
                                ) else {
                                    throw NSError(
                                        domain: "SMSError",
                                        code: 4,
                                        userInfo: [NSLocalizedDescriptionKey: "Failed to find UTI for mimeType: \(attachment.mimeType)"]
                                    )
                                }
                                
                                guard let url = URL(string: attachment.uri) else {
                                    throw NSError(
                                        domain: "SMSError",
                                        code: 5,
                                        userInfo: [NSLocalizedDescriptionKey: "Invalid file uri: \(attachment.uri)"]
                                    )
                                }
                                
                                let data = try Data(contentsOf: url, options: .mappedIfSafe)
                                let attached = messageComposeViewController.addAttachmentData(
                                    data,
                                    typeIdentifier: attachment.mimeType,
                                    filename: attachment.filename
                                )
                                
                                if !attached {
                                    throw NSError(
                                        domain: "SMSError",
                                        code: 6,
                                        userInfo: [NSLocalizedDescriptionKey: "Failed to attach file: \(attachment.uri)"]
                                    )
                                }
                            }
                        }
                        
                        self.smsContext = context
                        
                        // Present the SMS compose view controller
                        if let currentViewController = self.getCurrentViewController() {
                            currentViewController.present(messageComposeViewController, animated: true, completion: nil)
                        } else {
                            throw NSError(
                                domain: "SMSError",
                                code: 7,
                                userInfo: [NSLocalizedDescriptionKey: "Could not find current view controller"]
                            )
                        }
                    } catch {
                        self.smsContext = nil
                        continuation.resume(throwing: error)
                    }
                }
            }
        }
    }
    
    private func getCurrentViewController() -> UIViewController? {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootViewController = windowScene.windows.first?.rootViewController else {
            return nil
        }
        
        var currentViewController = rootViewController
        while let presentedViewController = currentViewController.presentedViewController {
            currentViewController = presentedViewController
        }
        
        return currentViewController
    }
}

struct SMSContext {
    let smsDelegate: SMSDelegate
}
