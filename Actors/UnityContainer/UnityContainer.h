//
//  UnityContainer.h
//  ShowUnity
//
//  Created by 林祐正 on 2021/10/5.
//

#ifndef UnityContainer_h
#define UnityContainer_h


#endif /* UnityContainer_h */
#import <UIKit/UIKit.h>
#include <UnityFramework/UnityFramework.h>
#include <UnityFramework/NativeCallProxy.h>

@interface UnityContainer : UIResponder<UIApplicationDelegate, UnityFrameworkListener, NativeCallsProtocol>
+ (instancetype) shared;
-(void) setLaunchConfigs:(UIWindow *)utWindow launchOptions:(NSDictionary *)options;
-(void) prepareUnity:(void(^)(BOOL completed))completion;
-(void) pauseUnity:(BOOL)paused;
-(void) hideUnity;
-(void) quitUnity:(void(^)())completion;
-(void) unloadUnity;
-(void) sendMessage:(NSString *)clsName Method:(NSString *)method Message:(NSString *)message;
-(UIViewController *) getUnityRootViewController;
-(UIView *) getUnityView;
@end
