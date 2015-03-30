//
//  DataModel.m
//  Bubble up
//
//  Created by Kim Ahlberg on 12/11/14.
//  Copyright (c) 2014. All rights reserved.
//

#import "DataModel.h"
#import "KpiModel.h"

@implementation DataModel

+ (instancetype)sharedDataModel {
    static DataModel *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[DataModel alloc] init];
        [instance setup];
    });
    return instance;
}

- (void)setup {
    
    // Read the contents of the Data.plist file and parse the contents as KPIs.
    NSString *path = [[NSBundle mainBundle] pathForResource:@"Data" ofType:@"plist"];
    NSArray *array = [[NSArray alloc] initWithContentsOfFile:path];

    NSMutableArray *kpis = [NSMutableArray array];
    KpiModel *kpi;
    
    for (NSDictionary *kpiDictionary in array) {
        
        // We only handle dictionary items.
        if (![kpiDictionary isKindOfClass:[NSDictionary class]]) {
            continue;
        }
        
        // We expect the dictionary item to have some value for the "title" key.
        NSString *name = kpiDictionary[@"title"];
        if (!name) {
            continue;
        }
        
        // Let's just assume for now that the rest of the expected fields exist in the dictionary.
        NSString *status = kpiDictionary[@"status"];
        NSNumber *value = kpiDictionary[@"value"];
        NSString *valueDisplay = [NSString stringWithFormat:@"$%@K", value];
        NSNumber *difference = kpiDictionary[@"differencePercentage"];
        NSString *differenceDisplay = [NSString stringWithFormat:@"%@%%", difference];
        
        // Create the KPI object.
        kpi = [[KpiModel alloc] initWithName:name status:status actualValue:value actualDisplay:valueDisplay differenceDisplay:differenceDisplay];
        [kpis addObject:kpi];
        
        // Update the min and max values if needed.
        if (!_maxValue || value > _maxValue) {
            _maxValue = value;
        }
        
        if (!_minValue || value < _minValue) {
            _minValue = value;
        }
    }
    
    // Store the KPIs to our instance variable.
    // NOTE: We should really sort these first, but as this app is only for demo purposes we can
    // rely on the KPIs in the file being sorted.
    _kpisOrderedByWorstDescending = [kpis copy];
}

@end
