//
//  KpiDetailViewController.h
//  Bubble up
//
//  Created by Kim Ahlberg on 12/11/14.
//  Copyright (c) 2014. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KpiModel.h"

@interface KpiDetailViewController : UIViewController

- (void)updateWithKpi:(KpiModel *)kpi;

@end
