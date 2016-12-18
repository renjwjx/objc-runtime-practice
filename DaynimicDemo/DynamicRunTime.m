//
//  DynamicRunTime.m
//  DaynimicDemo
//
//  Created by jinren on 17/12/2016.
//  Copyright © 2016 jinren. All rights reserved.
//

#import "DynamicRunTime.h"
#import <objc/runtime.h>

@implementation DynamicRunTime

- (instancetype)init
{
    self = [super init];
    if (self) {
        myName = @"aaaaaaa";
        _names = @[@"ddd", @"bbb"];
    }
    return self;
}



-(NSString *)nameWithInstance:(id)instance {
    unsigned int numIvars = 0;
    NSString *key=nil;
    Ivar * ivars = class_copyIvarList([self class], &numIvars);
    for(int i = 0; i < numIvars; i++) {
        Ivar thisIvar = ivars[i];
        const char *type = ivar_getTypeEncoding(thisIvar);
        NSString *stringType =  [NSString stringWithCString:type encoding:NSUTF8StringEncoding];
        if (![stringType hasPrefix:@"@"]) {
            continue;
        }
        if ((object_getIvar(self, thisIvar) == instance)) {//此处若 crash 不要慌！
            key = [NSString stringWithUTF8String:ivar_getName(thisIvar)];
            break;
        }
    }
    free(ivars);
    return key;
}
#pragma mark direct call VS send msg
- (void)privateMethod
{
//    NSLog(@"privateMethod");
    int i, j;
    i = 1;
    j = 2;
    i = i + j;
}

- (void)copyPrivateMethod
{
    //    NSLog(@"privateMethod");
    int i, j;
    i = 1;
    j = 2;
    i = i + j;
}


#pragma mark  Daynamic add method to class
+ (BOOL)resolveClassMethod:(SEL)sel {
    //object_getClass(self) is meta class,
    if (sel == @selector(learnClass:)) {
        class_addMethod(object_getClass(self), sel, class_getMethodImplementation(object_getClass(self), @selector(myClassMethod:)), "v@:");
        return YES;
    }
    return [class_getSuperclass(self) resolveClassMethod:sel];
}

+ (BOOL)resolveInstanceMethod:(SEL)aSEL
{
    NSLog(@"no method");
    //[self class] is DynamicRunTime class, is the same as self
    if (aSEL == @selector(goToSchool:)) {
        class_addMethod(self, aSEL, class_getMethodImplementation([self class], @selector(myInstanceMethod:)), "v@:");
        return YES;
    }
    return [super resolveInstanceMethod:aSEL];
}

+ (void)myClassMethod:(NSString *)string {
    NSLog(@"myClassMethod = %@", string);
}

- (void)myInstanceMethod:(NSString *)string {
    NSLog(@"myInstanceMethod = %@", string);
}
//end

#pragma mark forwardingTargetForSelector
- (id)forwardingTargetForSelector:(SEL)aSelector
{
    if (aSelector == @selector(goToHome:)) {
        NSLog(@"someone call goToHome, return nil");
        return nil;
    }
    return [super forwardingTargetForSelector:aSelector];
}

- (void)forwardInvocation:(NSInvocation *)anInvocation
{
    NSLog(@"forwardInvocation anInvocation: %@", anInvocation);
    [anInvocation invokeWithTarget:NSApp.delegate];
}
//forward to appdelegate object goToHome:, signature can not change the method name
- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector
{
    NSLog(@"need a Invocation:");
    if (aSelector == @selector(goToHome:)) {
        return [[NSApp.delegate class] instanceMethodSignatureForSelector:@selector(goToHome:)];
    }
    return [super methodSignatureForSelector:aSelector];
}
#pragma mark method swizzling
//called when class initial
+ (void)load
{
    Class aClass = [self class];
    
    SEL originalSel = @selector(original);
    SEL fakeOriginalSel = @selector(fakeOriginal);
    
    Method originalMethod = class_getInstanceMethod(aClass, originalSel);
    Method fakeOriginalMethod = class_getInstanceMethod(aClass, fakeOriginalSel);
    
    BOOL didAddMethod = class_addMethod(aClass, originalSel, method_getImplementation(fakeOriginalMethod), method_getTypeEncoding(fakeOriginalMethod));
    if (didAddMethod) {
        //if method added.
        class_replaceMethod(aClass, fakeOriginalSel, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
        NSLog(@"class replaceMethod");
    } else {
        method_exchangeImplementations(originalMethod, fakeOriginalMethod);
        NSLog(@"class exchangeMethod");
    }
}

- (void)fakeOriginal
{
    NSLog(@"I am fakeOriginalMethod");
}

@end
