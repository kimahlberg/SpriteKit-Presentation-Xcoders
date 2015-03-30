//
//  GameScene.h
//  Bubble up
//
//  Created by Kim Ahlberg on 12/10/14.
//  Copyright (c) 2014. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
@class KpiModel;
@protocol GameSceneKpiDelegate;

@interface GameScene : SKScene <UIGestureRecognizerDelegate>

/// The delegate object which should be informed of selection events.
@property (nonatomic, weak) id<GameSceneKpiDelegate> kpiDelegate;

- (void)reloadKpis;

#pragma mark - Gravity detection

- (void)startDetectingGravity;
- (void)stopDetectingGravity;

@end

/// The delate protocol to be implemented by the object which should be informed of KPI selections
/// in the scene.
@protocol GameSceneKpiDelegate <NSObject>

@required
- (void)gameScene:(GameScene *)sender didSelectKpi:(KpiModel *)kpi;
- (void)gameSceneDidDeselectKpi:(GameScene *)sender;

@end
