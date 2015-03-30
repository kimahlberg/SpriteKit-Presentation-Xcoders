//
//  KpiModel.m
//  Bubble up
//
//  Created by Kim Ahlberg on 12/11/14.
//  Copyright (c) 2014. All rights reserved.
//

#import "KpiModel.h"

@implementation KpiModel

- (instancetype)initWithName:(NSString *)name status:(NSString *)status actualValue:(NSNumber *)actualValue actualDisplay:(NSString *)actualDisplay differenceDisplay:(NSString *)differenceDisplay
{
    self = [super init];
    if (self) {
        _name = name;
        _status = status;
        _actualValue = actualValue;
        _actualDisplay = actualDisplay;
        _differenceDisplay = differenceDisplay;
    }
    return self;
}

- (UIColor *)statusColor;
{
    if ([self.status isEqualToString:@"KpiStatusGreen"]) {
        return KPI_STATUS_COLOR_GREEN;
    } else if ([self.status isEqualToString:@"KpiStatusYellow"]) {
        return KPI_STATUS_COLOR_YELLOW;
    } else if ([self.status isEqualToString:@"KpiStatusRed"]) {
        return KPI_STATUS_COLOR_RED;
    }
    return [UIColor grayColor];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"KPI %@ (%@ %@)", _name, _actualDisplay, _status];
}

@end
