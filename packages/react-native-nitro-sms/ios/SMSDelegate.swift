import Foundation
import MessageUI


class SMSDelegate: NSObject, MFMessageComposeViewControllerDelegate{
    private let onSuccess: (SMSResponse) -> Void
    private let onFailure: (String) -> Void
    
    init(onSuccess: @escaping (SMSResponse) -> Void, onFailure: @escaping (String) -> Void) {
        self.onSuccess = onSuccess
        self.onFailure = onFailure
    }
    
    func messageComposeViewController(
        _ controller: MFMessageComposeViewController,
        didFinishWith result: MessageComposeResult
    ) {
        controller.dismiss(animated: true) {
            switch result {
            case .sent:
                self.onSuccess(.sent)
            case .cancelled:
                self.onSuccess(.cancelled)
            case .failed:
                self.onFailure(
                        """
                        User's attempt to save or send an SMS was unsuccessful.
                        This can occur when the device loses connection to WiFi or Cellular
                        """
                )
            @unknown default:
                self.onFailure("SMS message sending failed with unknown error")
            }
        }
    }
}
