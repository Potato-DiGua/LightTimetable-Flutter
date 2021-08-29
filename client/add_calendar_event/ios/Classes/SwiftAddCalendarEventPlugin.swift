import Flutter
import UIKit
import EventKit

public class SwiftAddCalendarEventPlugin: NSObject, FlutterPlugin {
    
    let queue = DispatchQueue(label: "com.potato.timetalbe.reminderutil", attributes: .concurrent)
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "add_calendar_event", binaryMessenger: registrar.messenger())
        let instance = SwiftAddCalendarEventPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "addToCal":
            queue.async {
                let args = call.arguments as! [String:Any]
                
                self.addEventToCalendar(from: args,completion:{ (success) -> Void in
                    DispatchQueue.main.async {
                        result(success)
                    }
                })
            }
            
        case "addEventListToCal":
            queue.async {
                let list = call.arguments as! Array<Any>
                self.addEventListToCal(list:list , completion: {(count) -> Void in
                    DispatchQueue.main.async {
                        result(count)
                    }
                })
            }
            
        case "deleteCalEventByDesc":
            queue.async {
                let args = call.arguments as! [String:Any]
                
                self.deleteCalEventByDesc(desc: args["desc"] as! String, completion: {(count)->Void in
                    DispatchQueue.main.async {
                        result(count)
                    }
                })
            }
        default:
            result(FlutterMethodNotImplemented)
            break
        }
        
        //        result("iOS " + UIDevice.current.systemVersion)
    }
    
    private func addEventListToCal(list:[Any],completion: @escaping ((Int) -> Void)){
        let eventStore = EKEventStore()
        requestPermission(eventStore, completion: {(success) ->Void in
            if(success){
                var count:Int = 0
                
                for item in list{
                    let args = item as! [String:Any]
                    
                    let title = args["title"] as! String
                    let description = args["desc"] as! String
                    let location = args["location"] as! String
                    //        let timeZone = args["timeZone"] == nil ? nil: TimeZone(identifier: args["timeZone"] as! String)
                    let startDate = Date(milliseconds: (args["startDate"] as! Double))
                    let endDate = Date(milliseconds: (args["endDate"] as! Double))
                    let alarmInterval = args["alarmInterval"] as? Double
                    
                    let event = EKEvent(eventStore: eventStore)
                    
                    if let alarm = alarmInterval{
                        event.addAlarm(EKAlarm(relativeOffset: alarm*(-1)))
                    }
                    event.title = title
                    event.startDate = startDate
                    event.endDate = endDate
                    event.location = location
                    event.notes = description
                    event.calendar = eventStore.defaultCalendarForNewEvents
                    do{
                        try eventStore.save(event, span: .thisEvent)
                        count+=1
                    }catch let error as NSError{
                        print(error)
                    }
                }
                
                completion(count)
            }else{
                completion(0)
            }
        })
    }
    
    
    private func addEventToCalendar(from args: [String:Any], completion: @escaping ((Bool) -> Void)) {
        let title = args["title"] as! String
        let description = args["desc"] as! String
        let location = args["location"] as! String
        //        let timeZone = args["timeZone"] == nil ? nil: TimeZone(identifier: args["timeZone"] as! String)
        let startDate = Date(milliseconds: (args["startDate"] as! Double))
        let endDate = Date(milliseconds: (args["endDate"] as! Double))
        let alarmInterval = args["alarmInterval"] as? Double
        
        let eventStore = EKEventStore()
        
        requestPermission(eventStore, completion: {(success) ->Void in
            if(success){
                let event = EKEvent(eventStore: eventStore)
                if let alarm = alarmInterval{
                    event.addAlarm(EKAlarm(relativeOffset: alarm*(-1)))
                }
                event.title = title
                event.startDate = startDate
                event.endDate = endDate
                //                if (timeZone != nil) {
                //                    event.timeZone = timeZone
                //                }
                event.location = location
                event.notes = description
                event.calendar = eventStore.defaultCalendarForNewEvents
                //                event.isAllDay = allDay
                do{
                    try eventStore.save(event, span: .thisEvent)
                }catch let error as NSError{
                    print(error)
                    completion(false)
                }
                completion(true)
            }else{
                completion(false)
            }
        })
        
    }
    
    
    /**
     * 删除日历事件
     */
    private func deleteCalEventByDesc(desc:String,completion: @escaping ((Int) -> Void)) {
        let store = EKEventStore()
        requestPermission(store,completion: { (sucess)->Void in
            if(sucess){
                do{
                    let now = Date()
                    let halfYear = 60*60*24*365/2.0
                    let macher = store.predicateForEvents(withStart: now.addingTimeInterval(-halfYear), end: now.addingTimeInterval(halfYear), calendars: nil)
                    var count = 0
                    let events = store.events(matching: macher)
                    for event in events {
                        if(event.notes == desc){
                            try store.remove(event, span: .thisEvent)
                            count+=1
                        }
                    }
                    completion(count)
                }catch {
                    completion(0)
                }
            }else{
                completion(0)
            }
            
            
        })
    }
    private func getAuthorizationStatus() -> EKAuthorizationStatus {
        return EKEventStore.authorizationStatus(for: EKEntityType.event)
    }
    
    func requestPermission(_ eventStore: EKEventStore, completion: @escaping (( Bool) -> Void)) {
        let authStatus = getAuthorizationStatus()
        switch authStatus {
        case .authorized:
            completion(true)
        case .notDetermined:
            //Auth is not determined
            //We should request access to the calendar
            eventStore.requestAccess(to: .event, completion: {(granted, error) in
                if granted {
                    completion(true)
                } else {
                    // Auth denied
                    completion(false)
                }
            })
        case .denied, .restricted:
            // Auth denied or restricted
            completion(false)
        default:
            completion(false)
        }
    }
    
}

extension Date {
    init(milliseconds:Double) {
        self = Date(timeIntervalSince1970: TimeInterval(milliseconds) / 1000)
    }
}
