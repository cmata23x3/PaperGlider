//
//  MainMenu.m
//  Paper Glider
//
//  Created by Christian M. Mata on 1/27/13.
//
//

#import "CC3Scene.h"
#import "MainMenu.h"
#import "Paper_GliderScene.h"
#import "CCMenu.h"
#import "CCMenuItem.h"
#import "CC3Billboard.h"
#import "CC3Light.h"
#import "CC3Camera.h"
#import "CCSprite.h"
#import "CC3PODResourceNode.h"

CC3Camera* cam;
CC3Node* plane;

@implementation MainMenu

-(void) dealloc {
	[super dealloc];
}

-(void) initializeScene {
    
    // Create the camera, place it back a bit, and add it to the scene
	cam = [CC3Camera nodeWithName: @"Camera"];
	cam.location = cc3v( 0.0, 0.20, 6.0 );
	[self addChild: cam];
    
	// Create a light, place it back and to the left at a specific
	// position (not just directional lighting), and add it to the scene
	CC3Light* lamp = [CC3Light nodeWithName: @"Lamp"];
	lamp.location = cc3v( -2.0, 0.0, 0.0 );
	lamp.isDirectionalOnly = NO;
	[cam addChild: lamp];
    
	// Create OpenGL ES buffers for the vertex arrays to keep things fast and efficient,
	// and to save memory, release the vertex data in main memory because it is now redundant.
    //	[self createGLBuffers];
    //	[self releaseRedundantData];
    
     [self generateMenu];
  //  mainBack = [self addMainMenuBackground];
   // plane = [self addPaperPlane];
    [self generateMenu];
    
    NSLog(@"Scene!");
}

-(void) addMainMenuBackground {
    
    CCSprite* new = [CCSprite spriteWithFile:@"MainPage-Empty.png"];
    CC3Billboard* bill = [CC3Billboard nodeWithBillboard:new];
    bill.location = cc3v(0.0, 0.0, -360.0);
    bill.isTouchEnabled = NO;
    [self addChild:bill];
}

-(void) generateMenu
{
    //Generate Buttons
    
    CCMenuItemImage *playButton = [CCMenuItemImage itemFromNormalImage:@"PlayButton_New.png"
                                                         selectedImage:@"PlayButton_Selected.png"
                                                                target:self
                                                              selector:@selector(doSomething:)];
    
    CCMenuItemImage *tutButton = [CCMenuItemImage itemFromNormalImage:@"TutButton-New.png"
                                                        selectedImage:@"TutButton_Selected.png"
                                                               target:self
                                                             selector:@selector(doSomething2:)];
    
    CCMenuItemImage *shopButton = [CCMenuItemImage itemFromNormalImage:@"ShopButton.png" selectedImage:@"PlayButton_selected" target:self selector:@selector(doSomething:)];
    
    tutButton.scale = 1.25;
    playButton.scale = 1.25;
    
    //Generate Menu
    CCMenu * mMenu = [CCMenu menuWithItems: playButton, tutButton, nil];
    [mMenu alignItemsHorizontallyWithPadding:80.0];
    
    //Add to billboard and add to scene
    
    CC3Billboard* bill = [CC3Billboard nodeWithBillboard:mMenu];
    bill.isTouchEnabled =YES;
    [bill setLocation:cc3v(-125.0, -120.0, -300.0)];
    bill.uniformScale = 0.50;
    [self addChild:bill];
    NSLog(@"Menu should be added");
}

//create link methods
- (void) doSomething: (CCMenuItem  *) menuItem
{
	NSLog(@"The first menu was called");
    [[CCDirector sharedDirector] replaceScene:[Paper_GliderScene scene]];
    
   // [self initializeGameScene];
}
- (void) doSomething2: (CCMenuItem  *) menuItem
{
	NSLog(@"The second menu was called");
}
- (void) doSomething3: (CCMenuItem  *) menuItem
{
	NSLog(@"The third menu was called");
}
-(void) touchEvent: (uint) touchType at: (CGPoint) touchPoint {
    NSLog(@"Touch at X: %f at Y: %f", touchPoint.x, touchPoint.y);
    
}


/**
 * This callback template method is invoked automatically when a node has been picked
 * by the invocation of the pickNodeFromTapAt: or pickNodeFromTouchEvent:at: methods,
 * as a result of a touch event or tap gesture.
 *
 * Override this method to perform activities on 3D nodes that have been picked by the user.
 *
 * For more info, read the notes of this method on CC3Scene.
 */
-(void) nodeSelected: (CC3Node*) aNode byTouchEvent: (uint) touchType at: (CGPoint) touchPoint {}

- (void) handleMotion: (UIAcceleration *)acceleration {
    nil;
}

@end
