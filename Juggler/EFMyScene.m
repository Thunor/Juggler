//
//  EFMyScene.m
//  Juggler
//
//  Created by Eric Freitas on 4/24/14.
//  Copyright (c) 2014 Eric Freitas. All rights reserved.
//

#import "EFMyScene.h"

@interface EFMyScene()

@property (readwrite) CGFloat gforce;
@property (readwrite) NSInteger ballCount;
@property (readwrite) NSInteger score;
@property (readwrite, nonatomic, strong) SKLabelNode *scoreLabel;
@property (readwrite) CGRect sceneRect;
@property (readwrite, strong) NSDate *holdTime;

@end

static const CGFloat JUGSceneHeightOffset = 50.0;
static const CGFloat JUGScoreXOffset = 60.0;
static const CGFloat JUGWallThickness = 5.0;
static const CGFloat JUGFloorHeight = 22.0;
static const CGFloat JUGWallOffset = 3.0;

@implementation EFMyScene

-(id)initWithSize:(CGSize)size {    
    if (self = [super initWithSize:size]) {
        /* Setup the scene here */
        
        _sceneRect = [[UIScreen mainScreen] bounds];
        CGFloat sceneWidth = _sceneRect.size.width;
        CGFloat sceneHeight = _sceneRect.size.height;
    
        self.backgroundColor = [SKColor colorWithRed:0.15 green:0.15 blue:0.3 alpha:1.0];
        
        SKLabelNode *myLabel = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
        
        myLabel.text = @"Juggle!";
        myLabel.fontSize = 30;
        myLabel.position = CGPointMake(CGRectGetMidX(self.frame),
                                       CGRectGetMidY(self.frame));

        _ballCount = 0;
        _score = 0;
        _holdTime = [NSDate date];
        
        _scoreLabel = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
        _scoreLabel.text = [NSString stringWithFormat:@"Score: %ld", (long)_score];
        _scoreLabel.fontSize = 20;
        _scoreLabel.position = CGPointMake(CGRectGetMinX(self.frame) + JUGScoreXOffset, CGRectGetMinY(self.frame));
        
        SKSpriteNode *wallLeft = [SKSpriteNode spriteNodeWithColor:[UIColor blueColor] size:CGSizeMake(JUGWallThickness, sceneHeight - JUGSceneHeightOffset)];
        [wallLeft setPosition:CGPointMake(JUGWallOffset, sceneHeight/2)]; // sets the center
        [wallLeft setName:@"wall_left"];
        [wallLeft setPhysicsBody:[SKPhysicsBody bodyWithRectangleOfSize:CGSizeMake(JUGWallThickness, sceneHeight - JUGSceneHeightOffset)]];
        [[wallLeft physicsBody] setDynamic:NO];
        [[wallLeft physicsBody] setAffectedByGravity:NO];
        
        SKSpriteNode *wallRight = [SKSpriteNode spriteNodeWithColor:[UIColor blueColor] size:CGSizeMake(JUGWallThickness, sceneHeight - JUGSceneHeightOffset)];
        [wallRight setPosition:CGPointMake(sceneWidth - JUGWallOffset, sceneHeight/2)]; // sets the center
        [wallRight setName:@"wall_right"];
        [wallRight setPhysicsBody:[SKPhysicsBody bodyWithRectangleOfSize:CGSizeMake(JUGWallThickness, sceneHeight - JUGSceneHeightOffset)]];
        [[wallRight physicsBody] setDynamic:NO];
        [[wallRight physicsBody] setAffectedByGravity:NO];
        
        SKSpriteNode *wallFloor = [SKSpriteNode spriteNodeWithColor:[UIColor blueColor] size:CGSizeMake(sceneWidth, JUGWallThickness)];
        [wallFloor setPosition:CGPointMake(sceneWidth/2, JUGFloorHeight)]; // sets the center
        [wallFloor setName:@"floor"];
        [wallFloor setPhysicsBody:[SKPhysicsBody bodyWithRectangleOfSize:CGSizeMake(sceneWidth, JUGWallThickness)]];
        [[wallFloor physicsBody] setDynamic:NO];
        [[wallFloor physicsBody] setAffectedByGravity:NO];
         
        [self addChild:wallLeft];
        [self addChild:wallRight];
        [self addChild:wallFloor];
        
        [self addChild:myLabel];
        [self addChild:_scoreLabel];
    }
    return self;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self setHoldTime:[NSDate date]];
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    /* Called when a touch begins */
    
    for (UITouch *touch in touches) {
        CGPoint location = [touch locationInNode:self];
        
        if ([self currentBallCount] < 3)
        {
            if ([self ballIsHitAt:location])
            {
                [self hitABallAt:location];
            }
            else
            {
                if ([self ballCount] < 3)
                {
                    NSLog(@"new ball");
                    SKSpriteNode *sprite = [SKSpriteNode spriteNodeWithImageNamed:@"ball"];
                    
                    sprite.position = location;
                    [sprite setSize:CGSizeMake(25, 25)];
                    [sprite setName:@"ball"];
                    
                    sprite.physicsBody=[SKPhysicsBody bodyWithCircleOfRadius:12];
                    sprite.physicsBody.mass=1;
                    sprite.physicsBody.restitution=1;
                    sprite.physicsBody.linearDamping=0.2;
                    sprite.physicsBody.angularDamping=0.1;
                    sprite.physicsBody.allowsRotation=YES;
                    
                    // initial velocity of the ball
                    sprite.physicsBody.velocity = CGVectorMake(0, 200);
                    
                    //M_PI/4.0 is 45 degrees, you can make duration different from 0 if you want to show the rotation, if it is 0 it will rotate instantly
                    SKAction *rotation = [SKAction rotateByAngle: M_PI/4.0 duration:1];
                    //and just run the action
                    [sprite runAction: rotation];
                    
                    [self addChild:sprite];
                    
                    [self setBallCount:[self ballCount]+1];
                }
            }
        }
        else
        {
            NSLog(@"no ball");
            // did we hit a ball that is already in the air?
            if ([self ballIsHitAt:location])
                [self hitABallAt:location];
        }
    }
}

- (void)hitABallAt:(CGPoint)location
{
    for (SKNode *node in [self children])
    {
        if ([[node name] isEqualToString:@"ball"] && [self isNode:node closeTo:location])
        {
            // calculate the angle to throw the ball and the velocity to throw it.
            if ([node isKindOfClass:[SKSpriteNode class]])
            {
                NSTimeInterval timeInterval = [[NSDate date] timeIntervalSinceDate:[self holdTime]];

                NSLog(@"___ time interval = %f", timeInterval);
                
                CGPoint positionInScene = [node.scene convertPoint:node.position fromNode:node.parent];
                CGFloat xVel = (positionInScene.x - location.x) * 2.0;
                [[node physicsBody] setVelocity:CGVectorMake(xVel, 20 * 1 / timeInterval)];
                
                [self setScore:[self score]+1];
                
                [[self scoreLabel] setText:[NSString stringWithFormat:@"Score: %ld", (long)[self score]]];
            }
        }
    }
}

- (BOOL)isNode:(SKNode*)sNode closeTo:(CGPoint)location
{
    CGPoint positionInScene = [sNode.scene convertPoint:sNode.position fromNode:sNode.parent];
 
    if (fabs(positionInScene.x - location.x) < 40 && fabs(positionInScene.y - location.y) < 40)
        return YES;
    else
        return NO;
}

- (BOOL)ballIsHitAt:(CGPoint)location
{
    for (SKNode *node in [self children]) //[self childNodeWithName:@"ball"])
    {
        if ([[node name] isEqualToString:@"ball"] && [node containsPoint:location])
            return YES;
    }
    return NO;
}

- (NSInteger)currentBallCount
{
    NSInteger count = 0;
    for (SKNode *node in [self children])
    {
        if ([[node name] isEqualToString:@"ball"])
            count++;
    }
    return count;
}

-(void)update:(CFTimeInterval)currentTime
{
    /* Called before each frame is rendered */
    
    for (SKNode *node in [self children])
    {
        if ([[node name] isEqualToString:@"ball"])
        {
            if (fabs([node physicsBody].velocity.dy) < 3 && node.position.y < 40)
                [[node physicsBody] setVelocity:CGVectorMake([node physicsBody].velocity.dy, 0)];
        }
    }
}

@end
