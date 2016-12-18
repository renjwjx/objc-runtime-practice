//
//  AppDelegate.m
//  DaynimicDemo
//
//  Created by jinren on 17/12/2016.
//  Copyright © 2016 jinren. All rights reserved.
//

#import "AppDelegate.h"
#import <objc/runtime.h>

#import "DynamicRunTime.h"

@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application

//1.  get the class with the class name
    id dyClass = objc_getClass("DynamicRunTime");
    id dy = [[dyClass alloc] init];
    {
        unsigned int outCount, i;
        objc_property_t *properties = class_copyPropertyList(dyClass, &outCount);
        for (i = 0; i < outCount; i++) {
            objc_property_t property = properties[i];
            NSLog(@"%s %s\n", property_getName(property), property_getAttributes(property));
        }
    }
    
//2. direct call IMP funtion. it's faster call the method directly than send message
    void (*privateMethod)(id, SEL);
    int ii;
    //get class method
    privateMethod = (void (*)(id, SEL))[dy
                                       methodForSelector:@selector(privateMethod)];
    NSLog(@"start ");
    for ( ii = 0 ; ii < 10000 ; ii++ )
    {
        privateMethod(dy, @selector(privateMethod));
    }
    NSLog(@"end ");
    
    NSLog(@"Start send message");
    for ( ii = 0 ; ii < 10000 ; ii++ )
    {
        [(DynamicRunTime*)dy copyPrivateMethod];
    }
    NSLog(@"Stop send message");
//end

//dynamic add method
    [dy goToSchool:@"goto School"];
    [[dy class] learnClass:@"learn Class"];
    [dyClass learnClass:@"learn Class"];
//end
//forward message
    [dy goToHome:@"goto home"];
//end
    
//add instance for class
    NSString* newKey = @"newMyKey";
    objc_setAssociatedObject(dy, (__bridge const void *)(newKey), @"I am new add key", OBJC_ASSOCIATION_ASSIGN);
    
    NSString *newValue = objc_getAssociatedObject(dy, (__bridge const void *)(newKey));
    NSLog(@"new add key:%@ Value: %@", newKey,newValue);
    
//method Swizzling
    NSLog(@"call original Method");
    [dy original];
    
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}
//forward method
- (void)goToHome:(NSString*)str
{
    NSLog(@"Delegate---goToHome:%@",str);
}

@end
