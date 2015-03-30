//
//  GameViewController.m
//  Bubble up
//
//  Created by Kim Ahlberg on 12/10/14.
//  Copyright (c) 2014. All rights reserved.
//

#import "GameViewController.h"
#import "KpiDetailViewController.h"

@implementation SKScene (Unarchive)

+ (instancetype)unarchiveFromFile:(NSString *)file {
    
    // Retrieve scene file path from the application bundle.
    NSString *nodePath = [[NSBundle mainBundle] pathForResource:file ofType:@"sks"];
    
    // Unarchive the file to an SKScene object.
    NSData *data = [NSData dataWithContentsOfFile:nodePath
                                          options:NSDataReadingMappedIfSafe
                                            error:nil];
    NSKeyedUnarchiver *arch = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    [arch setClass:self forClassName:@"SKScene"];
    SKScene *scene = [arch decodeObjectForKey:NSKeyedArchiveRootObjectKey];
    [arch finishDecoding];
    
    return scene;
}

@end

@interface GameViewController () {
    GameScene *_gameScene;
    KpiDetailViewController *_kpiDetailViewController;
    __weak IBOutlet UIView *_detailContainerView;
}

@end

@implementation GameViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Configure the view.
    SKView * skView = (SKView *)self.view;
    skView.ignoresSiblingOrder = YES; // Let Sprite Kit apply optimizations to improve rendering performance
    
    // Create and configure the scene.
    _gameScene = [GameScene unarchiveFromFile:@"GameScene"];
    _gameScene.scaleMode = SKSceneScaleModeAspectFill;
    _gameScene.kpiDelegate = self;
    
    // Present the scene.
    [skView presentScene:_gameScene];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self becomeFirstResponder]; // Added so that a shake gesture triggers a motion event.
    
    [_gameScene startDetectingGravity];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [_gameScene stopDetectingGravity];
}

- (BOOL)canBecomeFirstResponder {
    return YES; // Needed for shake gesture to triggers motion event.
}

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event {
    if (motion == UIEventSubtypeMotionShake)
    {
        NSLog(@"Shaking!");
        [_gameScene reloadKpis];
    }
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"KpiDetailSegue"]) {
        // Hold on to the KPI detail view controller for later use.
        _kpiDetailViewController = segue.destinationViewController;
    }
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

#pragma mark - GameSceneKpiDelegate

- (void)gameScene:(GameScene *)sender didSelectKpi:(KpiModel *)kpi
{
    [self showDetailsForKpi:kpi];
}

- (void)gameSceneDidDeselectKpi:(GameScene *)sender;
{
    [self hideDetails];
}

#pragma mark - Helper methods

- (void)showDetailsForKpi:(KpiModel *)kpi
{
    [_kpiDetailViewController updateWithKpi:kpi];
    _detailContainerView.alpha = 0.0;
    [UIView animateWithDuration:0.25 animations:^{
        _detailContainerView.alpha = 1.0;
    }];
}

- (void)hideDetails
{
    _detailContainerView.alpha = 0.0;
}

@end
