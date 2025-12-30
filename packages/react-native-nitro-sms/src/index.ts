import { NitroModules } from 'react-native-nitro-modules'
import type { SMS } from './specs/Sms.nitro'

export const HybridSMS = NitroModules.createHybridObject<SMS>('SMS')
