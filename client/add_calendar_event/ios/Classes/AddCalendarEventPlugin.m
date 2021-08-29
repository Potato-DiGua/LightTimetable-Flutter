#import "AddCalendarEventPlugin.h"
#if __has_include(<add_calendar_event/add_calendar_event-Swift.h>)
#import <add_calendar_event/add_calendar_event-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "add_calendar_event-Swift.h"
#endif

@implementation AddCalendarEventPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftAddCalendarEventPlugin registerWithRegistrar:registrar];
}
@end
