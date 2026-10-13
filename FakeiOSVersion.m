#import <Foundation/Foundation.h>  
#import <UIKit/UIKit.h>  
#import <objc/runtime.h>  
  
// ==========================================  
// 1. UIDevice Swizzling (systemVersion)  
// ==========================================  
@interface UIDevice (FakeVersion)  
- (NSString *)fake_systemVersion;  
@end  
  
@implementation UIDevice (FakeVersion)  
- (NSString *)fake_systemVersion {  
    // သတ်မှတ်လိုသော iOS Version စာသား (ဥပမာ: "26.0")  
    return @"26.0";  
}  
@end  
  
// ==========================================  
// 2. NSProcessInfo Swizzling (operatingSystemVersion)  
// ==========================================  
@interface NSProcessInfo (FakeVersion)  
- (NSOperatingSystemVersion)fake_operatingSystemVersion;  
@end  
  
@implementation NSProcessInfo (FakeVersion)  
- (NSOperatingSystemVersion)fake_operatingSystemVersion {  
    NSOperatingSystemVersion version;  
    version.majorVersion = 26;  
    version.minorVersion = 0;  
    version.patchVersion = 0;  
    return version;  
}  
@end  
  
// ==========================================  
// Method Swizzling Helper Function  
// ==========================================  
static void SwizzleInstanceMethod(Class cls, SEL originalSelector, SEL swizzledSelector) {  
    Method originalMethod = class_getInstanceMethod(cls, originalSelector);  
    Method swizzledMethod = class_getInstanceMethod(cls, swizzledSelector);  
  
    if (originalMethod && swizzledMethod) {  
        method_exchangeImplementations(originalMethod, swizzledMethod);  
    }  
}  
  
// ==========================================  
// Dylib Constructor (App စတင်ပွင့်ချိန်တွင် အလုပ်လုပ်မည်)  
// ==========================================  
__attribute__((constructor))  
static void InitFakeIOSDylib(void) {  
    @autoreleasepool {  
        NSLog(@"[FakeIOS] Initializing Fake iOS Version Dylib...");  
  
        // UIDevice systemVersion ကို လဲလှယ်ခြင်း  
        SwizzleInstanceMethod([UIDevice class],  
                              @selector(systemVersion),  
                              @selector(fake_systemVersion));  
  
        // NSProcessInfo operatingSystemVersion ကို လဲလှယ်ခြင်း  
        SwizzleInstanceMethod([NSProcessInfo class],  
                              @selector(operatingSystemVersion),  
                              @selector(fake_operatingSystemVersion));  
  
        NSLog(@"[FakeIOS] Successfully spoofed iOS version to 26.0!");  
    }  
}
