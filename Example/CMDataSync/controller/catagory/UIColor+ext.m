//
//  UIColor+ext.m
//  CMDataSync_Example
//
//  Created by HeQingliang on 2021/11/4.
//  Copyright © 2021 panshaosen. All rights reserved.
//

#import "UIColor+ext.h"

@implementation UIColor (ext)
+ (UIColor *)colorWithRGB:(uint32_t)rgbValue {
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16) / 255.0f
                           green:((rgbValue & 0xFF00) >> 8) / 255.0f
                            blue:(rgbValue & 0xFF) / 255.0f
                           alpha:1];
}
@end
