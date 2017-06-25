//
//  NSObject+OutletBinding.h
//  ThreadDemo
//
//  Created by Juwencheng on 24/06/2017.
//  Copyright © 2017 Owen Ju. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@interface UIView (OutletBinding)

- (void)outletPropertyName:(NSString *)name toTag:(NSInteger)tag;
- (void)connectPropertyName:(NSString *)name tag:(NSInteger)tag to:(UIView *)target;

@end
