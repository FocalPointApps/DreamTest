import UIKit
import Flutter
import Firebase
import flutter_local_notifications
import PushKit
import flutter_callkeep


@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate ,PKPushRegistryDelegate{
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    FirebaseApp.configure()
    if #available(iOS 10.0, *) {
      // For iOS 10 display notification (sent via APNS)
      UNUserNotificationCenter.current().delegate = self
        
        UNUserNotificationCenter.current().delegate = self as? UNUserNotificationCenterDelegate


      let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
      UNUserNotificationCenter.current().requestAuthorization(
        options: authOptions,
        completionHandler: {_, _ in })
    } else {
      let settings: UIUserNotificationSettings =
      UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
      application.registerUserNotificationSettings(settings)
    }
      FlutterLocalNotificationsPlugin.setPluginRegistrantCallback { (registry) in
         GeneratedPluginRegistrant.register(with: registry)
       }
    application.registerForRemoteNotifications()
      GeneratedPluginRegistrant.register(with: self)
      
      let mainQueue = DispatchQueue.main
             let voipRegistry: PKPushRegistry = PKPushRegistry(queue: mainQueue)
             voipRegistry.delegate = self
             voipRegistry.desiredPushTypes = [PKPushType.voIP]
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
    func pushRegistry(_ registry: PKPushRegistry, didUpdate credentials: PKPushCredentials, for type: PKPushType) {
            print(credentials.token)
            let deviceToken = credentials.token.map { String(format: "%02x", $0) }.joined()
            print(deviceToken)
            //Save deviceToken to your server
            SwiftCallKeepPlugin.sharedInstance?.setDevicePushTokenVoIP(deviceToken)
        }
    
    func pushRegistry(_ registry: PKPushRegistry, didInvalidatePushTokenFor type: PKPushType) {
        print("didInvalidatePushTokenFor")
        SwiftCallKeepPlugin.sharedInstance?.setDevicePushTokenVoIP("")
    }
    // Handle incoming pushes
       func pushRegistry(_ registry: PKPushRegistry, didReceiveIncomingPushWith payload: PKPushPayload, for type: PKPushType, completion: @escaping () -> Void) {
           print("didReceiveIncomingPushWith")
           guard type == .voIP else { return }
           
           let id = payload.dictionaryPayload["id"] as? String ?? ""
           let callerName = payload.dictionaryPayload["callerName"] as? String ?? ""
           let userId = payload.dictionaryPayload["callerId"] as? String ?? ""
           let handle = payload.dictionaryPayload["handle"] as? String ?? ""
           let isVideo = payload.dictionaryPayload["isVideo"] as? Bool ?? false
           
           let data = flutter_callkeep.Data(id: id, callerName: callerName, handle: handle, hasVideo: isVideo)
           //set more data
           data.extra = ["userId": userId, "platform": "ios"]
           data.appName = "Done"
           //data.iconName = ...
           //data.....
           SwiftCallKeepPlugin.sharedInstance?.displayIncomingCall(data, fromPushKit: true)
       }

}
