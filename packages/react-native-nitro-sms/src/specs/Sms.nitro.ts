import type { HybridObject } from 'react-native-nitro-modules'

type SMSResponse = 'unknown' | 'sent' | 'cancelled'

interface SMSAttachment {
  filename: string
  mimeType: string
  uri: string
}

interface SMSOptions {
  attachments?: SMSAttachment | SMSAttachment[]
}

export interface SMS extends HybridObject<{ ios: 'swift'; android: 'kotlin' }> {
  isAvailable(): Promise<boolean>
  sendSMS(
    numbers: string[],
    message: string,
    options?: SMSOptions
  ): Promise<SMSResponse>
}
