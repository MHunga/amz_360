#import "Amz360Plugin.h"
#if __has_include(<amz_360/amz_360-Swift.h>)
#import <amz_360/amz_360-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "amz_360-Swift.h"
#endif

@implementation Amz360Plugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftAmz360Plugin registerWithRegistrar:registrar];
}
@end
