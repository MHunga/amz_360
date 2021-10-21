import Flutter
import UIKit
import AudioToolbox
import CoreMotion

public class SwiftAmz360Plugin: NSObject, FlutterPlugin {
  public static  let METHOD_CHANEL_VIBRATE : String = "amz_vibrate"
  public static  let METHOD_CHANEL_SENSOR : String = "amz_sensors/method"
    let ORIENTATION_CHANEL_SENSOR : String = "amz_sensors/orientation"
    
   
    private let orientationStreamHandler = AttitudeStreamHandler(CMAttitudeReferenceFrame.xMagneticNorthZVertical)
    
    
  public static func register(with registrar: FlutterPluginRegistrar) {
    let instance = SwiftAmz360Plugin(registrar: registrar)
    let channelVibrate = FlutterMethodChannel(name: METHOD_CHANEL_VIBRATE, binaryMessenger: registrar.messenger())
    let channelSensor = FlutterMethodChannel(name: METHOD_CHANEL_SENSOR, binaryMessenger: registrar.messenger())
   
    
    registrar.addMethodCallDelegate(instance, channel: channelVibrate)
    registrar.addMethodCallDelegate(instance, channel: channelSensor)
  }
    
     init( registrar: FlutterPluginRegistrar){
        let orientationChannel = FlutterEventChannel(name: ORIENTATION_CHANEL_SENSOR, binaryMessenger: registrar.messenger())
                orientationChannel.setStreamHandler(orientationStreamHandler)
     }
   

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    
    switch call.method {
    case "vibrate":
        if #available(iOS 10.0, *) {
                      let impact = UIImpactFeedbackGenerator()
                      impact.prepare()
                      impact.impactOccurred()
                    } else {
                      // Fallback on earlier versions
                      AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
                    }
        
    case "setSensorUpdateInterval":
    let arguments = call.arguments as! NSDictionary
        let timeInterval = TimeInterval(Double(arguments["interval"] as! Int) / 1000000.0)
        orientationStreamHandler.setUpdateInterval(timeInterval)
    default:
        result("iOS " + UIDevice.current.systemVersion)
    }
    
    result("iOS " + UIDevice.current.systemVersion)
  }
}



class AttitudeStreamHandler: NSObject, FlutterStreamHandler {
    private var attitudeReferenceFrame:  CMAttitudeReferenceFrame
    private let motionManager = CMMotionManager()
    private let queue = OperationQueue()

    init(_ referenceFrame: CMAttitudeReferenceFrame) {
        attitudeReferenceFrame = referenceFrame
    }

    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        if motionManager.isDeviceMotionAvailable {
            motionManager.showsDeviceMovementDisplay = true
            motionManager.startDeviceMotionUpdates(using: attitudeReferenceFrame, to: queue) { (data, error) in
                if data != nil {
                    // Let the y-axis point to magnetic north instead of the x-axis
                    if self.attitudeReferenceFrame == CMAttitudeReferenceFrame.xMagneticNorthZVertical {
                        let yaw = (data!.attitude.yaw + Double.pi + Double.pi / 2).truncatingRemainder(dividingBy: Double.pi * 2) - Double.pi
                        events([yaw, data!.attitude.pitch, data!.attitude.roll])
                    } else {
                        events([data!.attitude.yaw, data!.attitude.pitch, data!.attitude.roll])
                    }
                }
            }
        }
        return nil
    }
    
    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        motionManager.stopDeviceMotionUpdates()
        return nil
    }
    
    func setUpdateInterval(_ interval: TimeInterval) {
        motionManager.deviceMotionUpdateInterval = interval
    }
}
