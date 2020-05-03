#import "Dp3tPlugin.h"
#if __has_include(<dp3t/dp3t-Swift.h>)
#import <dp3t/dp3t-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "dp3t-Swift.h"
#endif

@implementation Dp3tPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftDp3tPlugin registerWithRegistrar:registrar];
}
@end
