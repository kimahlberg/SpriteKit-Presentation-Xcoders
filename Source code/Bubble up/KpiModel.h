//
//  KpiModel.h
//  Bubble up
//
//  Created by Kim Ahlberg on 12/11/14.
//  Copyright (c) 2014. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#define KPI_STATUS_COLOR_RED [UIColor colorWithRed:231.0 / 255 green:63.0 / 255 blue:70.0 / 255 alpha:1.0]
#define KPI_STATUS_COLOR_YELLOW [UIColor colorWithRed:242.0 / 255 green:141.0 / 255 blue:29.0 / 255 alpha:1.0]
#define KPI_STATUS_COLOR_GREEN [UIColor colorWithRed:63.0 / 255 green:189.0 / 255 blue:100.0 / 255 alpha:1.0]
#define BACKGROUND_COLOR [UIColor colorWithRed:45.0 / 255 green:45.0 / 255 blue:45.0 / 255 alpha:1.0]

@interface KpiModel : NSObject
@property NSString *name;
@property NSString *status;
@property NSNumber *actualValue;
@property NSString *actualDisplay;
@property NSString *differenceDisplay;

- (instancetype)initWithName:(NSString *)name
                      status:(NSString *)status
                 actualValue:(NSNumber *)actualValue
               actualDisplay:(NSString *)actualDisplay
           differenceDisplay:(NSString *)differenceDisplay;

- (UIColor *)statusColor;

@end
