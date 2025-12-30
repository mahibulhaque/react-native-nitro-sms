import Foundation
import NitroModules
import MessageUI
import CoreServices
import MobileCoreServices
import UniformTypeIdentifiers

class HybridSMS:HybridSMSSpec{
    
    func isAvailable() throws -> Promise<Bool> {
        return Promise.async{
            return await MFMessageComposeViewController.canSendText()
        }
    }
    
    func sendSMS(numbers: [String], message: String, options: SMSOptions?) throws -> Promise<SMSResponse> {
        return Promise.async{
            return SMSResponse.sent
        }
    }
}
    
