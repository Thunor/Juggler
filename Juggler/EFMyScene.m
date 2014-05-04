//
//  EFMyScene.m
//  Juggler
//
//  Created by Eric Freitas on 4/24/14.
//  Copyright (c) 2014 ___FULLUSERNAME___. All rights reserved.
//

#import "EFMyScene.h"

@interface EFMyScene()

@property (readwrite) CGFloat gforce;
@property (readwrite) NSInteger ballCount;

@end

@implementation EFMyScene

-(id)initWithSize:(CGSize)size {    
    if (self = [super initWithSize:size]) {
        /* Setup your scene here */
        
        self.backgroundColor = [SKColor colorWithRed:0.15 green:0.15 blue:0.3 alpha:1.0];
        
        SKLabelNode *myLabel = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
        
        myLabel.text = @"Juggle!";
        myLabel.fontSize = 30;
        myLabel.position = CGPointMake(CGRectGetMidX(self.frame),
                                       CGRectGetMidY(self.frame));

        _ballCount = 0;
        
        [self addChild:myLabel];
    }
    return self;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
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
                NSLog(@"new ball");
                SKSpriteNode *sprite = [SKSpriteNode spriteNodeWithImageNamed:@"ball"];
                
                sprite.position = location;
                [sprite setSize:CGSizeMake(20, 20)];
                [sprite setName:@"ball"];
                
                sprite.physicsBody=[SKPhysicsBody bodyWithCircleOfRadius:10];
                sprite.physicsBody.mass=1;
                sprite.physicsBody.restitution=1;
                sprite.physicsBody.linearDamping=0;
                sprite.physicsBody.angularDamping=0;
                
                sprite.physicsBody.velocity = CGVectorMake(0, 200);
                
                
                SKAction *action = [SKAction rotateByAngle:M_PI duration:1];
                
                [sprite runAction:[SKAction repeatActionForever:action]];
                
                [self addChild:sprite];
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
    for (SKNode *node in [self children]) //[self childNodeWithName:@"ball"])
    {
        if ([[node name] isEqualToString:@"ball"] && [node containsPoint:location])
            [[node physicsBody] setVelocity:CGVectorMake(node.physicsBody.velocity.dx, -node.physicsBody.velocity.dy)];
    }
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

-(void)update:(CFTimeInterval)currentTime {

    /* Called before each frame is rendered */
    
    for (SKNode *node in [self children])
    {
        if ([[node name] isEqualToString:@"ball"])
        {
            if (node.position.y < -40)
                [node removeFromParent];
        }
    }
}

@end
