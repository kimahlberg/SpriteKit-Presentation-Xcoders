//
//  DataModel.h
//  Bubble up
//
//  Created by Kim Ahlberg on 12/11/14.
//  Copyright (c) 2014. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DataModel : NSObject
+ (instancetype)sharedDataModel;

/// The KPIs ("Key Performance Indicators") ordered from worst performing to best performing.
@property (readonly) NSArray *kpisOrderedByWorstDescending;
/// The maximum value of any KPI.
@property (readonly) NSNumber *maxValue;
/// The minimum value of any KPI.
@property (readonly) NSNumber *minValue;

@end
