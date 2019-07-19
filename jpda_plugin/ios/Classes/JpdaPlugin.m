#import "JpdaPlugin.h"
#import <jpda_plugin/jpda_plugin-Swift.h>

@implementation JpdaPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftJpdaPlugin registerWithRegistrar:registrar];
}
@end
