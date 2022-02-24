//
//  UnityContainer.m
//  ShowUnity
//
//  Created by 林祐正 on 2021/10/5.
//

#import <Foundation/Foundation.h>
#import "UnityContainer.h"
#include <mach/mach.h>

@interface UnityContainer()

@property(nonatomic,strong) UIWindow *hostWindow;
@property(nonatomic,strong) NSDictionary *launchOpts;
@property UnityFramework *unityFwk;

@end

@implementation UnityContainer

+ (instancetype) shared {
    static UnityContainer *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[UnityContainer alloc] init];
    });
    return instance;
}
-(void)setLaunchConfigs:(UIWindow *)utWindow launchOptions:(NSDictionary *)options {
    self.hostWindow = utWindow;
    self.launchOpts = options;
}

- (bool) unityIsInitialized {
	// 判斷是否已經初始化過Unity執行環境
	return self.unityFwk && [self.unityFwk appController];
}

- (void) initUnity:(void(^)(BOOL completed))completion {
	// 初始化Unity執行環境
    if([self unityIsInitialized]) {
        completion(true);
        return;
    }
    
    self.unityFwk = [self loadUnityFramework];
    [self.unityFwk setDataBundleId:"com.unity3d.framework"];
    [self.unityFwk registerFrameworkListener:self];
    [NSClassFromString(@"FrameworkLibAPI") registerAPIforNativeCalls:self];
	
	// 取得APP執行參數
    NSArray *arguments = [[NSProcessInfo processInfo] arguments];
    int argc = (int)arguments.count;
    
	// Call this method when you need to run Unity when other Views exist.
	/**
	 argc means "argument count". It signifies how many arguments are being passed into the executable. argv means "argument values". It is a pointer to an array of characters. Or to think about it in another way, it is an array of C strings (since C strings are just arrays of characters).
	 **/
    [self.unityFwk runEmbeddedWithArgc:argc argv:[self getChar:arguments] appLaunchOpts: self.launchOpts];
//    [NSTimer scheduledTimerWithTimeInterval:5 repeats:NO block:^(NSTimer * _Nonnull timer) {
//        // call back finish
//        completion(true);
//    }];
	
	completion(true);
}

-(UIViewController *) getUnityRootViewController {
    return [[self.unityFwk appController] rootViewController];
}

-(UIView *) getUnityView {
	return [self getUnityRootViewController].view;
}

-(void) prepareUnity:(void(^)(BOOL))completion {
	// 準備Unity執行環境並執行
    if (![self unityIsInitialized]) {
        [self initUnity:^(BOOL completed) {
            if (completed) {
                [self.unityFwk showUnityWindow];
                dispatch_async(dispatch_get_main_queue(), ^{
                    completion(true);
                });
            }
        }];
    } else {
        [self.unityFwk showUnityWindow];
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(true);
        });
    }
}

-(void) sendMessage:(NSString *)clsName Method:(NSString *)method Message:(NSString *)message {
    [self.unityFwk sendMessageToGOWithName:clsName.UTF8String functionName:method.UTF8String message:message.UTF8String];
}

-(void) hideUnity {
    if (self.hostWindow != nil) {
        [self.hostWindow makeKeyAndVisible];
    }
}

-(void) pauseUnity:(BOOL)paused {
    if (self.unityFwk != nil) {
        [self.unityFwk pause:paused];
    }
}

-(void) quitUnity:(void(^)())completion {
	if ([self unityIsInitialized]) {
		[self.unityFwk appController].quitHandler = ^{
			NSLog(@"AppController.quitHandler called");
			dispatch_async(dispatch_get_main_queue(), ^{
				completion();
			});
		};
		[self.unityFwk quitApplication:0];
	}
}

- (void) unloadUnity {
    if ([self unityIsInitialized]) {
        [self.unityFwk unloadApplication];
    }
}

#pragma mark - 清掉Listener
- (void)unityDidUnload:(NSNotification*)notification
{
    NSLog(@"unityDidUnloaded called");
    [self.unityFwk unregisterFrameworkListener:self];
    self.unityFwk = nil;
}

- (UnityFramework *) loadUnityFramework {
	// 載入UnityFramework
	
    NSString* bundlePath = nil;
    bundlePath = [[NSBundle mainBundle] bundlePath];
    bundlePath = [bundlePath stringByAppendingString:@"/Frameworks/UnityFramework.framework"];
    
    NSBundle* bundle = [NSBundle bundleWithPath: bundlePath];
    if ([bundle isLoaded] == false) [bundle load];
    
    UnityFramework* ufw = [bundle.principalClass getInstance];
    if (![ufw appController])
    {
        // unity is not initialized
        [ufw setExecuteHeader: &_mh_execute_header];
    }
    return ufw;
}

- (char**)getChar:(NSArray *) a_array{
    NSUInteger count = [a_array count];
    char **array = (char **)malloc((count + 1) * sizeof(char*));
    
    for (unsigned i = 0; i < count; i++)
    {
        array[i] = strdup([[a_array objectAtIndex:i] UTF8String]);
    }
    array[count] = NULL;
    return array;
}


#pragma mark - NativeCallsProtocol
- (void)showHostMainWindow:(NSString *)color {
}

@end
