//
//  DynamicRunTime.h
//  DaynimicDemo
//
//  Created by jinren on 17/12/2016.
//  Copyright © 2016 jinren. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>

@interface DynamicRunTime : NSObject
{
    NSString *myName;
    NSArray *arrNames;
}
@property (strong) NSString *name;
@property (strong) NSArray *names;

-(NSString *)nameWithInstance:(id)instance;

- (void)copyPrivateMethod;

//dynamic add method
+ (void)learnClass:(NSString *) string;
- (void)goToSchool:(NSString *) name;

- (void)goToHome:(NSString *)home;

//swizzling
- (void)original;
//- (void)fakeOriginal;
@end
