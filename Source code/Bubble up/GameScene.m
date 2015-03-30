//
//  GameScene.m
//  Bubble up
//
//  Created by Kim Ahlberg on 12/10/14.
//  Copyright (c) 2014. All rights reserved.
//

#import "GameScene.h"
#import "DataModel.h"
#import "KpiModel.h"
#import <CoreMotion/CoreMotion.h>

@interface GameScene () {
    NSMutableDictionary *_nodeNameToKpiDictionary;
    SKNode *_highlightedNode; // The node currently selected, or nil if none selected.
    
    CMMotionManager *_motionManager; // Used to detect gravity.
    CGVector _gravity;
    
    BOOL _showStats;
}

@end

@implementation GameScene

-(void)didMoveToView:(SKView *)view {
    // Setup your scene here.
    self.size = self.view.bounds.size; // Change our size to match the presenting view.
    _showStats = NO;
    [self displayStats:_showStats];
    
    // Set a border around the scene, this stops bubbles from going behind the status bar and off
    // the sides, but add plenty of extra space beneath the screen for bubbles to bubble up from.
    CGFloat statusBarHeight = 20.0;
    CGFloat sidePadding = 10.0;
    CGFloat additionalBottomSpace = 10000.0;
    CGRect frameBelowStatusBar = CGRectMake(self.frame.origin.x + sidePadding, self.frame.origin.y - additionalBottomSpace, self.frame.size.width - 2 * sidePadding, self.frame.size.height - statusBarHeight + additionalBottomSpace);
    self.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:frameBelowStatusBar];

    // Store the initial gravity.
    _gravity = self.physicsWorld.gravity;
    
    // Add a gesture recognizer for toggling stats display when user taps with two fingers.
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(twoFingerTap:)];
    [tapRecognizer setNumberOfTouchesRequired:2];
    [tapRecognizer setDelegate:self];
    [view addGestureRecognizer:tapRecognizer];

    // Load the data.
    [self reloadKpis];
}

-(void)twoFingerTap:(id)sender {
    _showStats = !_showStats;
    [self displayStats:_showStats];
}

- (void)displayStats:(BOOL)statsVisible
{
    self.view.showsFPS = statsVisible;
    self.view.showsNodeCount = statsVisible;
    self.view.showsPhysics = statsVisible;
    self.view.showsFields = statsVisible;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    // Called when a touch begins.
    
    UITouch *touch = [touches anyObject];
    
    if (_highlightedNode) { // Already highlighting a node, we deselect it.
        
        // Tell the kpiDelegate that a node was deselected.
        if (self.kpiDelegate) {
            [self.kpiDelegate gameSceneDidDeselectKpi:self];
        }
        
        // Scale down the highlighted node to its original size.
        [_highlightedNode runAction:[SKAction scaleTo:1.0 duration:0.2]];
        _highlightedNode = nil;
        
        // Fade all other nodes back to full opacity.
        SKAction *fade = [SKAction fadeAlphaTo:1.0 duration:0.2];
        [_nodeNameToKpiDictionary enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            SKNode *node = [self childNodeWithName:[NSString stringWithFormat:@"/%@", key]];
            [node runAction:fade];
        }];
        
    } else {
        
        CGPoint touchLocation = [touch locationInNode:self];
        SKNode *touchedNode = [self nodeAtPoint:touchLocation];
        
        // If the touched node isn't the Scene we know we touched a bubble, not the background.
        if (![touchedNode isEqual:self]) {

            NSLog(@"Touched node %@", touchedNode);
            _highlightedNode = touchedNode;
            
            // Scale up the highlighted node.
            [_highlightedNode runAction:[SKAction scaleTo:1.15 duration:0.2]];

            // Fade down the alpha on all nodes except our highlighted node.
            SKAction *fade = [SKAction fadeAlphaTo:0.5 duration:0.2];
            [_nodeNameToKpiDictionary enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
                
                SKNode *node = [self childNodeWithName:[NSString stringWithFormat:@"/%@", key]];
                if (![node isEqual:_highlightedNode]) {
                    [node runAction:fade];
                }
            }];
            
            // Tell the kpiDelegate that a node was selected.
            if (self.kpiDelegate) {
                KpiModel *kpi = _nodeNameToKpiDictionary[_highlightedNode.name];
                [self.kpiDelegate gameScene:self didSelectKpi:kpi];
            }
        }
    }
}

-(void)update:(CFTimeInterval)currentTime {
    // Called before each frame is rendered.
    
    // Update world's gravity setting based on the latest motion updates.
    // It is safe to do this here as physics simulation doesn't start until this method returns.
    self.physicsWorld.gravity = _gravity;
}

- (SKNode *)addKpiBubbleWithName:(NSString *)name radius:(CGFloat)radius color:(UIColor *)color
{
    // We create a circular shape node to represent the KPI.
    SKShapeNode *shape = [SKShapeNode shapeNodeWithCircleOfRadius:radius];
    shape.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:radius + 6];
    shape.fillColor = color;
    shape.strokeColor = BACKGROUND_COLOR;
    
    // Set the initial x position to somewhere near the center of the space, to make sure the bubbles
    // don't fall outside the surrounding physics rectangle's walls.
    NSInteger xPosition = arc4random_uniform(floor(self.frame.size.width/2.0)) + self.frame.size.width/4.0;
    
    // Set the initial y position below the screen edge, and further down the more bubbles are already added.
    NSInteger yPosition = -200 - 40 * _nodeNameToKpiDictionary.count;

    shape.position = CGPointMake(xPosition, yPosition);
    shape.name = name;
    [self addChild:shape];
    
    // Apply a random horizontal impulse to spread the nodes sideways.
    NSInteger xImpulse = ((NSInteger)arc4random_uniform(100)) - 50; // Random number between -50 and 50.
    [shape.physicsBody applyImpulse: CGVectorMake(xImpulse, 0.0)];
    
    return shape;
}

- (void)reloadKpis
{
    NSLog(@"GameScene: Reload KPIs called");
    if (!_nodeNameToKpiDictionary) {
        _nodeNameToKpiDictionary = [NSMutableDictionary dictionary];
    }
    
    if (_highlightedNode) {
        // Tell the kpiDelegate that a node was deselected.
        if (self.kpiDelegate) {
            [self.kpiDelegate gameSceneDidDeselectKpi:self];
        }

        _highlightedNode = nil;
    }
    
    // Animate away existing nodes and drop them from the dictionary.
    SKAction *delay = [SKAction waitForDuration:0.25 withRange:0.5]; // An action that idles for a randomized period of time.
    SKAction *scaleAndFade = [SKAction group:@[[SKAction fadeOutWithDuration:0.25],
                                               [SKAction scaleTo:0.25 duration:0.25]]];
    [_nodeNameToKpiDictionary enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        SKNode *node = [self childNodeWithName:[NSString stringWithFormat:@"/%@", key]];
        [node runAction:[SKAction sequence:@[delay, scaleAndFade, [SKAction removeFromParent]]]];
    }];
    [_nodeNameToKpiDictionary removeAllObjects];
    
    // Add the new nodes.
    NSArray *kpis = [[DataModel sharedDataModel] kpisOrderedByWorstDescending];
    for (KpiModel *kpi in kpis) {
        CGFloat radius = [self radiusForKpi:kpi];
        SKNode *node = [self addKpiBubbleWithName:kpi.name radius:radius color:kpi.statusColor];
        [_nodeNameToKpiDictionary setObject:kpi forKey:node.name];
        NSLog(@"Added node: %@", node.name);
    }
}

/// Calculates a radius based on the KPI's value.
- (CGFloat)radiusForKpi:(KpiModel *)kpi
{
    CGFloat minRadius = 30.0;
    CGFloat maxRadius = 60.0;
    CGFloat radiusRange = maxRadius - minRadius;
    
    NSNumber *minValue = [[DataModel sharedDataModel] minValue];
    NSNumber *maxValue = [[DataModel sharedDataModel] maxValue];
    CGFloat valueRange = [maxValue doubleValue] - [minValue doubleValue];
    CGFloat valuePercentile = ([kpi.actualValue doubleValue] - [minValue doubleValue])/valueRange;
    
    CGFloat radius = minRadius + radiusRange * valuePercentile;
    return radius;
}

#pragma mark - Gravity detection

- (void)startDetectingGravity
{
    // Create the CMMotionManager
    if (!_motionManager) {
        _motionManager = [[CMMotionManager alloc] init];
        _motionManager.deviceMotionUpdateInterval = 1.0/30.0; // 30 Hz should be plenty.
    }

    [_motionManager startDeviceMotionUpdatesToQueue:[[NSOperationQueue alloc] init] withHandler:^(CMDeviceMotion *motion, NSError *error) {
        if (!error) {
            [self updateGravityWithAcceleration:motion.gravity];
        }
    }];
}

- (void)stopDetectingGravity
{
    [_motionManager stopDeviceMotionUpdates];
}

- (void)updateGravityWithAcceleration:(CMAcceleration)acceleration
{
    CGFloat multiplier = 5.0;
    CGFloat xGravity = -acceleration.x * multiplier;
    CGFloat yGravity = -acceleration.y * multiplier;
    
    yGravity = MAX(1.5, yGravity); // Make sure to always have a little bit of positive gravity in Y axis.
    
    // Store the new gravity, but don't apply it to the physicsWorld here since SpriteKit may be in
    // the middle of calculating the physics simulation, in which case we will crash.
    _gravity = CGVectorMake(xGravity, yGravity);
}

@end
