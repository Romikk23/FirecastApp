import UIKit
import CoreBluetooth

protocol uuid {
    
}

class Uuid: NSObject {
    
    /// MARK: - Particle LED services and charcteristics Identifiers
    
    public static let UUID     = CBUUID.init(string: "ffe0")
    
    public static let batteryServiceUUID         = CBUUID.init(string: "180f")
    public static let batteryCharacteristicUUID  = CBUUID.init(string: "2a19")
    
}
