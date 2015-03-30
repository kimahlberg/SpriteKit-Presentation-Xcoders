//
//  KpiDetailViewController.m
//  Bubble up
//
//  Created by Kim Ahlberg on 12/11/14.
//  Copyright (c) 2014. All rights reserved.
//

#import "KpiDetailViewController.h"

@interface KpiDetailViewController () {
    __weak IBOutlet UILabel *_kpiNameLabel;
    __weak IBOutlet UILabel *_actualValueLabel;
    __weak IBOutlet UILabel *_differenceValueLabel;
    __weak IBOutlet UILabel *_xAxisMinLabel;
    __weak IBOutlet UILabel *_xAxisMaxLabel;
}

@end

@implementation KpiDetailViewController

- (void)updateWithKpi:(KpiModel *)kpi
{
    _kpiNameLabel.text = kpi.name;
    _actualValueLabel.text = kpi.actualDisplay;
    _actualValueLabel.textColor = kpi.statusColor;
    _differenceValueLabel.text = kpi.differenceDisplay;
}

@end
