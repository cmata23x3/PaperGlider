/**
 *  Paper_GliderScene.m
 *  Paper Glider
 *
 *  Created by Christian M. Mata on 1/24/13.
 *  Copyright __MyCompanyName__ 2013. All rights reserved.
 */

#import "Paper_GliderScene.h"

#import "CC3PODResourceNode.h"
#import "CC3ActionInterval.h"
#import "CC3MeshNode.h"
#import "CC3Camera.h"
#import "CC3Light.h"
#import "CCSprite.h"
#import "CC3Billboard.h"
#import "ccTypes.h"
#import "CC3Fog.h"
#import "CC3Particles.h"
#import "CCParticleSystem.h"
#import "ParticleEffectSelfMade.h"
#import "CCLabelAtlas.h"
#import "CC3TargettingNode.h"
#import "ObjectGenerator.h"
#import "SimpleAudioEngine.h"

#define transFactor .5
#define rotUp 20
#define rotBank 20
#define diffFact 1.5
#define rightAngle 45

//Global variables
CC3Camera *cam;
CC3Node *sphere, *osphere, *background, *mainMenuBackground, *shopMenuBackground, *billI, *billTut;
CC3PODResourceNode* plane;
ObjectGenerator* objectGenerator;
CCLabelTTF* LblScore, *levels;
CCProgressTimer* progressTime;
CC3PODResourceNode* bonusBar;
CC3Billboard *levelBill;
NSMutableArray* generatorList, *sceneObjects;
GLfloat *preVeloc;
Boolean streak = false;
Boolean tutorial = false;
Boolean tutorialCharm = false;
Boolean gameOver = true;
Boolean charmHit = false;
Boolean bonusHit = false;
BOOL playing, mainMenu, shop, planeShowing;


double *rotationchge;
float bonusPercent = 0;
int score = 1;
int dist = 1;
int counter=0;
int visDiff = 0;
int levelSpeed;;
int bonusCount;
int planePicker = 0;
int level = 1;

@implementation Paper_GliderScene

-(void) dealloc {
	[super dealloc];
}

-(void) initializeScene {
    //Audio Engine
    [[SimpleAudioEngine sharedEngine] preloadEffect:@"DST-1990.mp3"];

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
    [self addMainMenuBackground];
}

-(void) addMainMenuBackground {
    [[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"DST-1990.mp3" loop:YES];
    CCSprite* new = [CCSprite spriteWithFile:@"MainPage-Empty.png"];
    mainMenuBackground = [CC3Billboard nodeWithBillboard:new];
    mainMenuBackground.location = cc3v(0.0, 0.0, -360.0);
    mainMenuBackground.isTouchEnabled = NO;
    [self addChild:mainMenuBackground];
    [self generateMenu];
}

-(void) generateMenu
{
    //Generate Buttons
    CCMenuItemImage *shopButton = [CCMenuItemImage itemFromNormalImage:@"ShopButton.png"
                                                         selectedImage:@"ShopButton_Sel.png"
                                                                target:self
                                                              selector:@selector(switchToShop:)];
    
    CCMenuItemImage *playButton = [CCMenuItemImage itemFromNormalImage:@"PlayButton.png"
                                                         selectedImage:@"PlayButton_Sel.png"
                                                                target:self
                                                              selector:@selector(switchToPlaying:)];
    
    CCMenuItemImage *tutButton = [CCMenuItemImage itemFromNormalImage:@"TutButton.png"
                                                        selectedImage:@"TutButton_Sel.png"
                                                               target:self
                                                             selector:@selector(switchToTutorial:)];
    tutButton.scale = 0.85;
    playButton.scale = 0.85;
    shopButton.scale =0.85;
    
    //Generate Menu
    CCMenu * mMenu = [CCMenu menuWithItems: shopButton, playButton, tutButton,  nil];
    [mMenu alignItemsHorizontallyWithPadding:100.0];
    
    //Add to billboard and add to scene
    CC3Billboard* bill = [CC3Billboard nodeWithName:@"Menu" withBillboard:mMenu];
    bill.isTouchEnabled =YES;
    bill.shouldDrawAs2DOverlay = YES;
    [bill setLocation:cc3v(-175.0, -160.0, 0.0)];
    bill.uniformScale = 100.50;
    [mainMenuBackground addChild:bill];
}

-(void) tearDownMainMenu{
    //Removes main menu background, leaves camera and light
    //Hides the plane from view while the game isn't at the mainmenu or playing
    [self removeChild:mainMenuBackground];
}

//create link methods
- (void) switchToPlaying: (CCMenuItem  *) menuItem
{
    //Remove old instances
    //Going from Main Menu to Playing
    [self tearDownMainMenu];
    //[self tearDownShop];
    [self initializeGameScene];
}

- (void) switchToTutorial: (CCMenuItem  *) menuItem
{
    //MainMenu to Tutorial
    [self tearDownMainMenu];
    [self initializeTutorial];
    //Need to add Amadu's method to switch to scene
}

- (void) switchToShop: (CCMenuItem  *) menuItem
{
    //Main Menu to Shop
    [self tearDownMainMenu];
    [self initializeShopScene];
}

///////This is the end of initializing the Main Menu scene! ////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////

#pragma mark "Scenes" because transitions would not work

-(void) initializeShopScene{
    //Use add same background from the playing scene
    [self addShopBackground];
    //Put in two menus for each row
    [self generateTopShipMenu];
    [self generateBottomShipMenu];
    [self generateBackFromShopButton];
}

-(void) addShopBackground {
    CCSprite* new = [CCSprite spriteWithFile:@"ShopBackground.png"];
    shopMenuBackground = [CC3Billboard nodeWithBillboard:new];
    shopMenuBackground.location = cc3v(0.0, 0.0, -360.0);
    shopMenuBackground.isTouchEnabled = NO;
    [self addChild:shopMenuBackground];
}

-(void) generateTopShipMenu
{   //Generate Buttons
    CCMenuItemImage *firstButton = [CCMenuItemImage itemFromNormalImage:@"SelectOp.png"
                                                         selectedImage:@"SelectOp_Sel.png"
                                                                target:self
                                                              selector:@selector(switchPlaneToPaperPlane:)];
    
    CCMenuItemImage *secondButton = [CCMenuItemImage itemFromNormalImage:@"SelectOp.png"
                                                         selectedImage:@"SelectOp_Sel.png"
                                                                target:self
                                                              selector:@selector(switchPlaneToBraun:)];
    
    CCMenuItemImage *thirdButton = [CCMenuItemImage itemFromNormalImage:@"Locked_500.png"
                                                        selectedImage:@"Locked_500.png"
                                                               target:self
                                                             selector:@selector(skipper:)];
 
    firstButton.scale = 1.5;
    secondButton.scale = 1.50;
    thirdButton.scale =1.50;
    
    //Generate Menu
    CCMenu * mMenu = [CCMenu menuWithItems: firstButton, secondButton,  thirdButton, nil];
    [mMenu alignItemsHorizontallyWithPadding:620.0];
    
    //Add to billboard and add to scene
    CC3Billboard* bill = [CC3Billboard nodeWithName:@"ShopItemTopMenu" withBillboard:mMenu];
    bill.isTouchEnabled =YES;
    bill.shouldDrawAs2DOverlay = YES;
    [bill setLocation:cc3v(-215.0, -135.0, 0.0)];
    bill.uniformScale = 50.50;
    [shopMenuBackground addChild:bill];
}

-(void) generateBottomShipMenu
{   //Generate Buttons
    CCMenuItemImage *firstButton = [CCMenuItemImage itemFromNormalImage:@"Locked_1500.png"
                                                          selectedImage:@"Locked_1500.png"
                                                                 target:self
                                                               selector:@selector(skipper:)];
    
    CCMenuItemImage *secondButton = [CCMenuItemImage itemFromNormalImage:@"Locked_3000.png"
                                                          selectedImage:@"Locked_3000.png"
                                                                 target:self
                                                                selector:@selector(skipper:)];
    
   /* CCMenuItemImage *thirdButton = [CCMenuItemImage itemFromNormalImage:@"LockedOp.png"
                                                          selectedImage:@"LockedOp.png"
                                                                 target:self
                                                               selector:@selector(skipper:)];
    */
    
    firstButton.scale = 1.750;
    secondButton.scale = 1.750;
   // thirdButton.scale =1.0;
    
    //Generate Menu
    CCMenu * bMenu = [CCMenu menuWithItems: firstButton, secondButton,  nil];
    [bMenu alignItemsHorizontallyWithPadding:400.0];
    
    //Add to billboard and add to scene
    CC3Billboard* bill = [CC3Billboard nodeWithName:@"ShopItemBottomMenu" withBillboard:bMenu];
    bill.isTouchEnabled =YES;
    bill.shouldDrawAs2DOverlay = YES;
    [bill setLocation:cc3v(-225.0, -255.0, 0.0)];
    bill.uniformScale = 50.50;
    [shopMenuBackground addChild:bill];
}

-(void) skipper: (CCMenuItem  *) menuItem
{
    //do nothing
    int c = 0;
    c++;
//    [plane show];
}
//Plane switchers
-(void) switchPlaneToPaperPlane: (CCMenuItem*) menuItem
{
    planePicker = 0;
    [self addPaperPlane];
}
-(void) switchPlaneToSpaceShip: (CCMenuItem*) menuItem
{
    planePicker = 0;
    [self addSpaceshipPlane];
}
-(void) switchPlaneToBraun: (CCMenuItem*) menuItem
{
    planePicker = 1;
    [self addBraunFoxCPlane];
    [self tearDownShop];
    [self addMainMenuBackground];
}

-(void) tearDownShop{
    [self removeChild: shopMenuBackground];
}

-(void) generateBackFromShopButton
{   //Generate Buttons
    CCMenuItemImage *firstButton = [CCMenuItemImage itemFromNormalImage:@"Back.png"
                                                          selectedImage:@"Back_Selected.png"
                                                                 target:self
                                                               selector:@selector(shopBackToMain:)];
    firstButton.scale = 1.5;
    
    //Generate Menu
    CCMenu * button = [CCMenu menuWithItems: firstButton, nil];
    
    //Add to billboard and add to scene
    CC3Billboard* bill = [CC3Billboard nodeWithName:@"BackButton" withBillboard:button];
    bill.isTouchEnabled =YES;
    bill.shouldDrawAs2DOverlay = YES;
    [bill setLocation:cc3v(-20.0, -255.0, 0.0)];
    bill.uniformScale = 50.50;
    [shopMenuBackground addChild:bill];
}
//back to main from shop
-(void) shopBackToMain: (CCMenuItem*) menuItem
{
    [self tearDownShop];
    [self addMainMenuBackground];
}

-(void) generateBackFromGameButton
{   //Generate Buttons
    CCMenuItemImage *firstButton = [CCMenuItemImage itemFromNormalImage:@"Back.png"
                                                          selectedImage:@"Back_Selected.png"
                                                                 target:self
                                                               selector:@selector(gameBackToMain:)];
    firstButton.scale = 1.5;
    
    //Generate Menu
    CCMenu * button = [CCMenu menuWithItems: firstButton, nil];
    
    //Add to billboard and add to scene
    CC3Billboard* bbar = [CC3Billboard nodeWithName:@"BackButton" withBillboard:button];
    bbar.isTouchEnabled =YES;
    bbar.shouldDrawAs2DOverlay = YES;
    [bbar setLocation:cc3v(-20.0, -255.0, 0.0)];
    bbar.uniformScale = 50.50;
    [background addChild:bbar];
}

-(void) gameBackToMain: (CCMenuItem*) menuItem{
    //[objectGenerator release];
    [generatorList removeAllObjects];
    for (NSMutableArray* tup in sceneObjects) {
        CC3Node *remObj = [tup objectAtIndex:0];
        [self removeChild:remObj];
    }
    [sceneObjects removeAllObjects];
    [self removeChild:background];
    [self addMainMenuBackground];
}

/////This is the end of the Shop Scene!/////////
//////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////

-(void) initializeGameScene {
    // SceneObjects and objectGenerator and List[ObjectGenerator]
    objectGenerator = [[ObjectGenerator alloc] init];
    [objectGenerator initialize];
    generatorList = [[NSMutableArray alloc] init];

    levelSpeed = 30;
    bonusCount = 0;
    level = 1;
    sceneObjects = [[NSMutableArray alloc] init];

	// Create OpenGL ES buffers for the vertex arrays to keep things fast and efficient,
	// and to save memory, release the vertex data in main memory because it is now redundant.
	[self createGLBuffers];
	[self releaseRedundantData];
    //Create things needed for game play
    //[self countDown];
    [self addBackground];
    [self addScoreKeeper];
    [self addBonusBar];
    [self addGenerators];
    
    //   [self runEffect];
    //   [self addFog];
    switch (planePicker) {
        case 1: // 
            [self addOtherPlane];
            break;
            
        default:
            [self addPaperPlane];
            break;
    }
    //[plane show];
    [self addChild:plane];
    gameOver = false;
    
}

-(void) addBackground {
    
    CCSprite* new = [CCSprite spriteWithFile:@"RealClouds.png"];
    background = [CC3Billboard nodeWithBillboard:new];
    background.location = cc3v(0.0, 0.0, -360.0);
    [self addChild:background];
}

-(void) addPaperPlane {
    // create plane
    plane = [CC3PODResourceNode nodeWithName:@"Plane"];
    plane.resource = [CC3PODResource resourceFromFile:@"plane_airplane_final.pod"];

    plane.uniformScale = 3.5;
    [plane setLocation:cc3v(0,-1, 2)];
    [plane enableAllAnimation];
    //[self addChild:plane];
}

-(void) addBraunFoxCPlane {
    // create plane
    plane = [CC3PODResourceNode nodeWithName:@"Plane"];
    plane.resource = [CC3PODResource resourceFromFile:@"BraunFoxC1.pod"];
    
    plane.uniformScale = .02;
    [plane setLocation:cc3v(0,-1, 2)];
    [plane enableAllAnimation];
}

-(void) addStarFighterPlane {
    // create plane
    plane = [CC3PODResourceNode nodeWithName:@"Plane"];
    plane.resource = [CC3PODResource resourceFromFile:@"star_fighter_plane.pod"];
    
    plane.uniformScale = .15;
    [plane setLocation:cc3v(0,-1, 2)];
    [plane enableAllAnimation];
}

-(void) addSpitfirePlane {
    // create plane
    plane = [CC3PODResourceNode nodeWithName:@"Plane"];
    plane.resource = [CC3PODResource resourceFromFile:@"spitfire_plane_final.pod"];
    plane.uniformScale = .15;

    [plane setLocation:cc3v(0,-1, 2)];
    [plane enableAllAnimation];
}

-(void) addSpaceshipPlane {
    // create plane
    plane = [CC3PODResourceNode nodeWithName:@"Plane"];
    plane.resource = [CC3PODResource resourceFromFile:@"spaceship_axe_ii.pod"];
    plane.uniformScale = .05;

    [plane setLocation:cc3v(0,-1, 2)];
    [plane enableAllAnimation];
}

-(void) addOtherPlane {
    // create plane
    plane = [CC3PODResourceNode nodeWithName:@"Plane"];
    plane.resource = [CC3PODResource resourceFromFile:@"plane_model4.pod"];
    plane.uniformScale = .75;
    [plane setLocation:cc3v(0,-1,2)];
    [plane enableAllAnimation];

}

-(void) checkCollisions: (NSMutableArray*) tuple
{
    CC3Node* obj = [tuple objectAtIndex:0];
    CC3Vector tpDir = CC3VectorDifference(plane.globalLocation, obj.globalLocation);
    float distance = CC3VectorLength(tpDir);
    if (distance < 0.40) {
        
        switch ([[tuple objectAtIndex:1] intValue]) {
            case 0:
                // bad object
                [self gameOver];
                [self removeChild:obj];
                streak = false;
                break;
            case 1:
                // lucky charms
                score+=20;
                [self ridLuckyCharm: obj];
                break;
            case 2:
                if (streak) {
                    bonusPercent += 0.001;
                    bonusCount += 1;
                    if (!tutorial) {
                        [self updateBonus];
                    }
                }
                streak = true;
                [self ridBonus: obj];
                break;
            default:
                if (!tutorial) {
                    [self updateBonus];
                }
                break;
        }
    }
}

#pragma mark Display changes
-(void) addFog {
	self.fog = [CC3Fog fog];
	fog.visible = YES;
	fog.color = ccc3(128, 128, 180);		// A slightly bluish fog.
    
	// Choose one of GL_LINEAR, GL_EXP and GL_EXP2
	fog.attenuationMode = GL_EXP2;
    
	// If using GL_EXP or GL_EXP2, the density property will have effect.
	fog.density = 0.002;//0.0017;
	
	// If using GL_LINEAR, the start and end distance properties will have effect.
	fog.startDistance = 200.0;
	fog.endDistance = 1500.0;
    
	// To make things a bit more interesting, set up a repeating up/down cycle to
	// change the color of the fog from the original bluish to reddish, and back again.
	GLfloat tintTime = 4.0f;
	ccColor3B startColor = fog.color;
	ccColor3B endColor = ccc3(180, 128, 128);		// A slightly redish fog.
	CCActionInterval* tintDown = [CCTintTo actionWithDuration: tintTime
														  red: endColor.r
														green: endColor.g
														 blue: endColor.b];
	CCActionInterval* tintUp = [CCTintTo actionWithDuration: tintTime
														red: startColor.r
													  green: startColor.g
													   blue: startColor.b];
	CCActionInterval* tintCycle = [CCSequence actionOne: tintDown two: tintUp];
	[fog runAction: [CCRepeatForever actionWithAction: tintCycle]];
}

/*
-(void) runEffect
{
	CCParticleSystem* system;
    system = [CCParticleSmoke node];
    system.visible = YES;
    system.duration = 1;
    
    system.totalParticles = NSUIntegerMax;
    //	CCParticleSystem* sys = [ CCParticleSnow node];
    
    CC3ParticleSystemBillboard* bill = [CC3ParticleSystemBillboard nodeWithBillboard:system];
    NSLog(@"Plane location: (%f, %f, %f)", plane.location.x, plane.location.y, plane.location.z);
    bill.location = cc3v(plane.location.x, plane.location.y, plane.location.z);
    bill.uniformScale = .05;
    bill.shouldDrawAs2DOverlay = NO;
    [self addChild:bill];
    [bill alignToCamera:cam];
}
*/

-(void) addScoreKeeper{
    //Score Label
    score = 0;
    LblScore = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"%im",score]
                                dimensions:CGSizeMake(20, 20)
                                alignment:UITextAlignmentCenter
                                fontName:@"Arial"
                                  fontSize:12.0];
    LblScore.color = ccBLACK;
    //Add to Billboard
    CC3Billboard* keeper = [CC3Billboard nodeWithName:@"ScoreBoard" withBillboard:LblScore];
//    keeper.location = cc3v(-185.0, 100.0, 10.01);
    keeper.location = cc3v(-150.0, 100.0, 50.0);
    [keeper alignToCamera:cam];
    //[background hide];
    [background addChild: keeper];
}

-(void) updateScoreKeeper{
    counter++;
    if (counter%30 == 0) {
        score = score + bonusCount*5 + 1;
        [LblScore setString: [NSString stringWithFormat:@"%im",score]];
    }
}

-(void) addBonusBar
{
    // "Bonus" text
    CCLabelTTF* bonusText = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"Bonus"]
                                             dimensions:CGSizeMake(50, 50)
                                              alignment:UITextAlignmentCenter
                                               fontName:@"Arial"
                                               fontSize:10.0];
    bonusText.color = ccBLACK;
    CC3Billboard* bonusBill = [CC3Billboard nodeWithName:@"ScoreBoard" withBillboard:bonusText];
    bonusBill.location = cc3v(160.0, 90.0, 50.0);
    
    // bonusBar back and front
    CC3PODResourceNode* bonusBack = [CC3PODResourceNode nodeWithName:@"bonusBack"];
    bonusBack.resource = [CC3PODResource resourceFromFile:@"barBack.pod"];
    bonusBar = [CC3PODResourceNode nodeWithName:@"bonusBar"];
    bonusBar.resource = [CC3PODResource resourceFromFile:@"bonusBar.pod"];
    
    bonusBar.location = cc3v(185,120,0);
    bonusBack.location = cc3v(185,120,0);
    
    // initialize bonusBar as small
    bonusBack.uniformScale = 10;
    bonusBack.rotation = cc3v(90, 0, 0);
    [background addChild:bonusBack];
    [background addChild:bonusBill];
    [background addChild:bonusBar];
}

-(void) updateBonus
{
    [background removeChild:bonusBar];
    if (bonusPercent < 10) {
        bonusBar.uniformScale = bonusPercent;
    }
    bonusBar.rotation = cc3v(90, 0, 0);
    [background addChild:bonusBar];
}

/*
 * Generating new objects, either good or bad, in accordance to the ratio value.
 */

#pragma mark Updating custom activity
-(void) updateBeforeTransform: (CC3NodeUpdatingVisitor*) visitor {
    
    if (score == 20 && counter%30 == 0) {
        [self levelUp];
        levelSpeed -= 5;
    }
    else if (score == 50 && counter%30 == 0) {
        [self levelUp];
        levelSpeed -= 10;
    }
    else if (score > 50 && score % 10 == 0 && counter % 30 == 0) {
        [self levelUp];
        levelSpeed -= 1;
    }
    
    if (counter % 150 == 0 && !gameOver) {

        for (NSMutableArray* generators in generatorList) {
            
            int rspeed = ((rand() / 2147483647.0) * levelSpeed) + 10;
            float x = [[generators objectAtIndex:0] floatValue];
            float y = [[generators objectAtIndex:1] floatValue];
            NSMutableArray* objectPair = [objectGenerator generateObject: x: y: [[self lights] count]];
            NSNumber* numObj = [objectPair objectAtIndex:1];
            [sceneObjects addObject:objectPair];
            CC3Node* randomObject = [objectPair objectAtIndex:0];
            
            switch ([numObj intValue]) {
                case 1:
                    rspeed -= 15;
                    break;
                case 2:
                    rspeed -= 15;
                    break;
                default:
                    break;
            }
            
            CCActionInterval* moveUp = [CC3MoveForwardBy actionWithDuration:rspeed
                                                                     moveBy:60.0];
            [self addChild:randomObject];
            [randomObject runAction:moveUp];
        }
    }
}

-(void) updateAfterTransform: (CC3NodeUpdatingVisitor*) visitor {
    //NSLog(@"Lights array: %i and lightObj: %i", [[self lights] count]);
    if (!gameOver) {
     
        [self updateScoreKeeper];
        
        NSMutableIndexSet *discardedItems = [NSMutableIndexSet indexSet];
        NSInteger index = 0;
        
        for (NSMutableArray* tuple in sceneObjects) {
            if (!gameOver) {
                [self checkCollisions:tuple];                
            }
            if (bonusHit || charmHit) {
                [discardedItems addIndex:index];
                bonusHit = false;
                charmHit = false;
            }
            index++;
        }
        [sceneObjects removeObjectsAtIndexes:discardedItems];
    }
    
    if (!tutorial) {
        NSMutableIndexSet *discardedItems = [NSMutableIndexSet indexSet];
        NSInteger index = 0;
        
        for (NSMutableArray *tup in sceneObjects) {
            CC3Node *remObj = [tup objectAtIndex:0];
            if (remObj.location.z > 20.0) {
                [self removeChild:remObj];
                [discardedItems addIndex:index];
            }
            index++;
        }
        
        [sceneObjects removeObjectsAtIndexes:discardedItems];
        
        if (gameOver) {
            // Final destruction of objects
            NSMutableIndexSet *discardedItems = [NSMutableIndexSet indexSet];
            NSInteger index = 0;
            
            for (NSMutableArray *tup in sceneObjects) {
                CC3Node *remObj = [tup objectAtIndex:0];
                if (remObj.location.z < -10.0) {
                    [self removeChild:remObj];
                    [discardedItems addIndex:index];
                }
                index++;
            }
            [sceneObjects removeObjectsAtIndexes:discardedItems];
        }

    }
    
    if (tutorial) {

        NSMutableIndexSet *discardedItems = [NSMutableIndexSet indexSet];
        NSInteger index = 0;
        
        for (NSMutableArray* tuple in sceneObjects) {
            if (tutorial) {
                [self checkCollisions:tuple];
            }
            if (bonusHit || charmHit) {
                [discardedItems addIndex:index];
                bonusHit = false;
                charmHit = false;
            }
            index++;
        }
        
        [sceneObjects removeObjectsAtIndexes:discardedItems];
        
        discardedItems = [NSMutableIndexSet indexSet];
        index = 0;
        
        for (NSMutableArray *tup in sceneObjects) {
            CC3Node *remObj = [tup objectAtIndex:0];
            if (remObj.location.z > 2.0) {
                [self removeChild:remObj];
                [discardedItems addIndex:index];
            }
            index++;
        }
        
        [sceneObjects removeObjectsAtIndexes:discardedItems];

        if ([sceneObjects count] == 0) {
            [self gameOver]; // finished regularly without getting the last item
        }
    }
}


#pragma mark Scene opening and closing

-(void) onOpen {}

-(void) onClose {}


#pragma mark Handling touch events 

/**
 * This method is invoked from the CC3Layer whenever a touch event occurs, if that layer
 * has indicated that it is interested in receiving touch events, and is handling them.
 *
 * Override this method to handle touch events, or remove this method to make use of
 * the superclass behaviour of selecting 3D nodes on each touch-down event.
 *
 * This method is not invoked when gestures are used for user interaction. Your custom
 * CC3Layer processes gestures and invokes higher-level application-defined behaviour
 * on this customized CC3Scene subclass.
 *
 * For more info, read the notes of this method on CC3Scene.
 */
-(void) touchEvent: (uint) touchType at: (CGPoint) touchPoint {

}

-(void) nodeSelected: (CC3Node*) aNode byTouchEvent: (uint) touchType at: (CGPoint) touchPoint {}


- (void) handleMotion: (UIAcceleration *)acceleration {
    
    CCActionInterval* partialTransRight = [CC3MoveRightBy actionWithDuration:.09 moveBy:(-acceleration.y * transFactor)];
    CCActionInterval* partialTransUp = [CC3MoveUpBy actionWithDuration:.09 moveBy:(acceleration.x * transFactor)];
    
    if (!gameOver || tutorial) {
        
        float destX, destY;
        BOOL shouldMove = NO;
        
        float currentX = plane.location.x;
        float currentY = plane.location.y;
        
        if(acceleration.x > 0.25) {  // tilting the device downwards
            if (acceleration.y < -0.25) {  // tilting the device to the right
            }
            else if (acceleration.y > 0.25) {  // tilting the device to the left
            }
            else {  // tilting the device upwards only
            }
            shouldMove = YES;
        } else if (acceleration.x < -0.25) {  // tilting the device downwards
            if (acceleration.y < -0.25) {  // tilting the device to the right
            }
            else if (acceleration.y > 0.25) {  // tilting the device to the left
            }
            else {
            }
            shouldMove = YES;
        } else if(acceleration.y < -0.25) {  // tilting the device to the right
            if (acceleration.x > 0.25) {    // tilting the device downwards
            }
            else if (acceleration.x < -0.25) {
            }
            else {
            }
            shouldMove = YES;
        } else if (acceleration.y > 0.25) {  // tilting the device to the left
            if (acceleration.x > 0.25) {    // tilting the device downwards
            }
            else if (acceleration.x < -0.25) {
            }
            else {
            }
            shouldMove = YES;
        } else {    //  stay still
            destX = currentX;
            destY = currentY;
        }
        
        currentX = currentX - acceleration.y*transFactor;
        currentY = currentY + acceleration.x*transFactor;
        
        if(shouldMove) {
            // ensure we aren't moving out of bounds
            // x bounds = (-1.65,1.92)  (-1,.092)
            if(currentX > 1.92 || currentX < -1.65) {
                if (currentY > 0.092 || currentY < -1.0) {
                    // do nothing
                }
                else {
                    [plane runAction:partialTransUp];
                }
            }else if (currentY > 0.092 || currentY < -1.0) {
                if (currentX > 1.92 || currentX < -1.65) {
                    
                }
                else {
                    [plane runAction:partialTransRight];
                }
            }
            else {
                [plane runAction:partialTransRight];
                [plane runAction:partialTransUp];
            }
        }

    }
}

/*
 * Add all of the generators that need to produce the objects
 */
-(void) addGenerators
{
    
    NSMutableArray* newGen1 = [[NSMutableArray alloc] initWithObjects:[NSNumber numberWithFloat:-.5],[NSNumber numberWithFloat:-1],nil];
    [generatorList addObject:newGen1];
    
    NSMutableArray* newGen2 = [[NSMutableArray alloc] initWithObjects:[NSNumber numberWithFloat:-.9],[NSNumber numberWithFloat:-.7],nil];
    [generatorList addObject:newGen2];

    NSMutableArray* newGen3 = [[NSMutableArray alloc] initWithObjects:[NSNumber numberWithFloat:-.7],[NSNumber numberWithFloat:-.5],nil];
    [generatorList addObject:newGen3];

    NSMutableArray* newGen4 = [[NSMutableArray alloc] initWithObjects:[NSNumber numberWithFloat:0],[NSNumber numberWithFloat:-.3],nil];
    [generatorList addObject:newGen4];
    
    NSMutableArray* newGen5 = [[NSMutableArray alloc] initWithObjects:[NSNumber numberWithFloat:.1],[NSNumber numberWithFloat:-.1],nil];
    [generatorList addObject:newGen5];
    
    NSMutableArray* newGen6 = [[NSMutableArray alloc] initWithObjects:[NSNumber numberWithFloat:.3],[NSNumber numberWithFloat:.1],nil];
    [generatorList addObject:newGen6];
    
    NSMutableArray* newGen7 = [[NSMutableArray alloc] initWithObjects:[NSNumber numberWithFloat:.5],[NSNumber numberWithFloat:.3],nil];
    [generatorList addObject:newGen7];
    
    NSMutableArray* newGen8 = [[NSMutableArray alloc] initWithObjects:[NSNumber numberWithFloat:.6],[NSNumber numberWithFloat:.5],nil];
    [generatorList addObject:newGen8];
}

-(void) gameOver
{
    gameOver = true;
    
    // remove all of the objects on the scene besides the background
    [self removeChild:plane];
    
    if (tutorial) {
        [background removeChild:billI];
        [background removeChild:billTut];
        tutorial = false;
    }
    
    CCSprite* new = [CCSprite spriteWithFile:@"GameOver.png"];
    CC3Billboard* bill0 = [CC3Billboard nodeWithBillboard:new];
    bill0.location = cc3v(0.0, 0.0, 0.0);
    bill0.uniformScale = .25;
    [background addChild:bill0];
    
    CCActionInterval* moveUp = [CC3MoveForwardBy actionWithDuration:5 moveBy:60.0];
    [bill0 runAction:moveUp];


    CCLabelTTF* EndScore = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"Score: %im",score]
                     dimensions:CGSizeMake(100, 75)
                      alignment:UITextAlignmentLeft
                       fontName:@"Arial"
                       fontSize:15.0];
    EndScore.color = ccBLACK;
    
    //Add to Billboard
    CC3Billboard* gameO = [CC3Billboard nodeWithName:@"EndScoreBoard" withBillboard:EndScore];
    gameO.location = cc3v(0.0, -105.0, 50.0);
    [gameO alignToCamera:cam];
    [background addChild: gameO];
    
    if (tutorial) {
        [self generateBackFromTutorialButton];
    }else {
        [self generateBackFromGameButton];
    }
}

-(void) ridBonus: obj
{
    [self removeChild:obj];
    bonusHit = true;
    //[sceneObjects removeObject:obj];
    
    // show "x2"
    CCLabelTTF* bonus = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"Score: x2"]
                                            dimensions:CGSizeMake(100, 75)
                                             alignment:UITextAlignmentLeft
                                              fontName:@"Arial"
                                              fontSize:10.0];
    bonus.color = ccc3(224, 27, 217);
    
    //Add to Billboard
    CC3Billboard* bill = [CC3Billboard nodeWithName:@"EndScoreBoard" withBillboard:bonus];
    bill.location = cc3v(0.0, -50.0, -250);
    [bill alignToCamera:cam];
    [self addChild: bill];
    
    CCActionInterval* moveUp = [CC3MoveForwardBy actionWithDuration:1 moveBy:260.0];
    [bill runAction:moveUp];
}

-(void) ridLuckyCharm: obj
{
    [self removeChild:obj];
    charmHit = true;
    //[sceneObjects removeObject:obj];
    
    // show "+20"
    CCLabelTTF* charm = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"Score: +20"]
                                            dimensions:CGSizeMake(100, 75)
                                             alignment:UITextAlignmentLeft
                                              fontName:@"Arial"
                                              fontSize:10.0];
    charm.color = ccYELLOW;
    
    //Add to Billboard
    CC3Billboard* bill = [CC3Billboard nodeWithName:@"EndScoreBoard" withBillboard:charm];
    bill.location = cc3v(0.0, -50.0, -250);
    [bill alignToCamera:cam];
    [self addChild: bill];
    
    CCActionInterval* moveUp = [CC3MoveForwardBy actionWithDuration:1 moveBy:260.0];
    [bill runAction:moveUp];
}

/////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////// Tutorial Layout /////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////

-(void) initializeTutorial {
    // tutorial will only last 20 points of time
    [self addBackground];
    tutorial = true;
    
    // initialize the scene with 3, 2, 1 countdown; plane; and background
    [self addPaperPlane];
    [self addChild:plane];
    [self countDown];
    [self rotateiPhone];
    
    sceneObjects = [[NSMutableArray alloc] init];
    NSNumber* sphere = [NSNumber numberWithInt: 0];
    NSNumber* charm = [NSNumber numberWithInt:1];
    NSNumber* bonusObj = [NSNumber numberWithInt:2];
    
    
    // shoot one charm
    // shoot one bonus    
    // shoot one bad ball
    CC3PODResourceNode* badObject = [CC3PODResourceNode nodeWithName:@"BAD"];
    badObject.resource = [CC3PODResource resourceFromFile:@"bad_cube.pod"];
    badObject.location = cc3v(0,-1,-1000);
    badObject.uniformScale = 0.1;
    badObject.shouldCastShadowsWhenInvisible = NO;
    badObject.shouldUseSmoothShading =YES;
    
    CCActionInterval* moveUp = [CC3MoveForwardBy actionWithDuration:25 moveBy:1100.0];
    NSMutableArray* badObjectArray = [[NSMutableArray alloc] initWithObjects: badObject, sphere, nil];
    [self addChild:badObject];
    [sceneObjects addObject:badObjectArray];
    [badObject runAction:moveUp];
    
    // shoot charm
    CC3PODResourceNode* charmObject = [CC3PODResourceNode nodeWithName:@"Charm"];
    charmObject.resource = [CC3PODResource resourceFromFile:@"charm_cube.pod"];
    charmObject.location = cc3v(.2, -1, -1000);
    charmObject.uniformScale = 0.1;
    charmObject.shouldCastShadowsWhenInvisible = NO;
    charmObject.shouldUseSmoothShading =YES;
    
    NSMutableArray* charmObjectArray = [[NSMutableArray alloc] initWithObjects: charmObject, charm, nil];
    moveUp = [CC3MoveForwardBy actionWithDuration:28 moveBy:1100.0];
    [self addChild:charmObject];
    [sceneObjects addObject:charmObjectArray];
    [charmObject runAction:moveUp];
    
    // shoot bonus
    CC3PODResourceNode* bonusObject = [CC3PODResourceNode nodeWithName:@"Bonus"];
    bonusObject.resource = [CC3PODResource resourceFromFile:@"bonus_box.pod"];
    bonusObject.location = cc3v(-.1,-1,-1000);
    bonusObject.uniformScale = 0.1;
    bonusObject.shouldCastShadowsWhenInvisible = NO;
    bonusObject.shouldUseSmoothShading =YES;
    
    NSMutableArray* bonusObjectArray = [[NSMutableArray alloc] initWithObjects: bonusObject, bonusObj, nil];
    moveUp = [CC3MoveForwardBy actionWithDuration:31 moveBy:1100.0];
    [self addChild:bonusObject];
    [sceneObjects addObject:bonusObjectArray];
    [bonusObject runAction:moveUp];
    
    
}

-(void) countDown
{
    
    CCLabelTTF* three = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"3"]
                                         dimensions:CGSizeMake(100, 75)
                                          alignment:UITextAlignmentLeft
                                           fontName:@"Arial"
                                           fontSize:30.0];
    three.color = ccBLACK;
    
    //Add to Billboard
    CC3Billboard* bill3 = [CC3Billboard nodeWithName:@"EndScoreBoard" withBillboard:three];
    bill3.location = cc3v(40.0, -20.0, -250);
    [bill3 alignToCamera:cam];
    [self addChild: bill3];
    
    CCActionInterval* moveUp3 = [CC3MoveForwardBy actionWithDuration:1 moveBy:260.0];
    [bill3 runAction:moveUp3];
    
    CCLabelTTF* two = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"2"]
                                       dimensions:CGSizeMake(100, 75)
                                        alignment:UITextAlignmentLeft
                                         fontName:@"Arial"
                                         fontSize:30.0];
    two.color = ccBLACK;
    
    //Add to Billboard
    CC3Billboard* bill2 = [CC3Billboard nodeWithName:@"EndScoreBoard" withBillboard:two];
    bill2.location = cc3v(40.0, -20.0, -500);
    [bill2 alignToCamera:cam];
    [self addChild: bill2];
    
    CCActionInterval* moveUp2 = [CC3MoveForwardBy actionWithDuration:2 moveBy:510.0];
    [bill2 runAction:moveUp2];
    
    CCLabelTTF* one = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"1"]
                                       dimensions:CGSizeMake(100, 75)
                                        alignment:UITextAlignmentLeft
                                         fontName:@"Arial"
                                         fontSize:30.0];
    one.color = ccBLACK;
    
    //Add to Billboard
    CC3Billboard* bill1 = [CC3Billboard nodeWithName:@"EndScoreBoard" withBillboard:one];
    bill1.location = cc3v(40.0, -20.0, -750);
    [bill1 alignToCamera:cam];
    [self addChild: bill1];
    
    CCActionInterval* moveUp1 = [CC3MoveForwardBy actionWithDuration:3 moveBy:760.0];
    [bill1 runAction:moveUp1];
}

-(void) rotateiPhone
{
    CCSprite* new = [CCSprite spriteWithFile:@"iPhone.png"];
    billI = [CC3Billboard nodeWithBillboard:new];
    billI.location = cc3v(40.0, 15.0, -500.0);
    billI.uniformScale = .05;
    billI.rotation = cc3v(0,0,90);
    
    
    CCActionInterval* moveUpI = [CC3MoveForwardBy actionWithDuration:5 moveBy:800.0];
    CCActionInterval* rotR = [CC3RotateBy actionWithDuration:.3 rotateBy:cc3v(0,0,40)];
    CCActionInterval* rotL = [CC3RotateBy actionWithDuration:.6 rotateBy:cc3v(0,0,-80)];
    CCActionInterval* rotRa = [CC3RotateBy actionWithDuration:.3 rotateBy:cc3v(0,0,40)];
    CCActionInterval* rotF = [CC3RotateBy actionWithDuration:.3 rotateBy:cc3v(40,0,0)];
    CCActionInterval* rotB = [CC3RotateBy actionWithDuration:.6 rotateBy:cc3v(-80,0,0)];
    CCActionInterval* rotBa = [CC3RotateBy actionWithDuration:.3 rotateBy:cc3v(40,0,0)];
    
    CCActionInterval* seq = [CCSequence actions:rotR,rotL,rotRa,rotF,rotB,rotBa, nil];
    CCActionInterval* seqForever = [CCRepeatForever actionWithAction:seq];
    [billI runAction:moveUpI];
    [billI runAction: seqForever];
    [background addChild:billI];
    
    CCLabelTTF* tutorial = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"Rotate to avoid objects and collect bonuses (purple) and charms (yellow)."]
                                            dimensions:CGSizeMake(100, 75)
                                             alignment:UITextAlignmentLeft
                                              fontName:@"Arial"
                                              fontSize:8.0];
    tutorial.color = ccBLACK;
    
    //Add to Billboard
    billTut = [CC3Billboard nodeWithName:@"Tutorial_Words" withBillboard:tutorial];
    billTut.location = cc3v(-40.0, 0.0, -500);
    [billTut alignToCamera:cam];
    [background addChild: billTut];
    
    CCActionInterval* moveUpTut = [CC3MoveForwardBy actionWithDuration:5 moveBy:400.0];
    CCActionInterval* moveUpTutD = [CC3MoveForwardBy actionWithDuration:2 moveBy:300.0];
    [billTut runAction:[CCSequence actions:moveUpTut, moveUpTutD, nil]];
}

-(void) generateBackFromTutorialButton
{   //Generate Buttons
    CCMenuItemImage *firstButton = [CCMenuItemImage itemFromNormalImage:@"Back.png"
                                                          selectedImage:@"Back_Selected.png"
                                                                 target:self
                                                               selector:@selector(tutorialBackToMain:)];
    firstButton.scale = 1.5;
    
    //Generate Menu
    CCMenu * button = [CCMenu menuWithItems: firstButton, nil];
    
    //Add to billboard and add to scene
    CC3Billboard* bbar = [CC3Billboard nodeWithName:@"BackButton" withBillboard:button];
    bbar.isTouchEnabled =YES;
    bbar.shouldDrawAs2DOverlay = YES;
    [bbar setLocation:cc3v(-20.0, -255.0, 0.0)];
    bbar.uniformScale = 50.50;
    [background addChild:bbar];
}

-(void) tutorialBackToMain: (CCMenuItem*) menuItem{
    [self removeChild:background];
    [self addMainMenuBackground];
}

-(void) levelUp
{
    [self removeChild:levelBill];
    CCActionInterval* moveUp3 = [CC3MoveForwardBy actionWithDuration:1 moveBy:260.0];
    level++;
    levels = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"Level %i", level]
                              dimensions:CGSizeMake(100, 75)
                               alignment:UITextAlignmentLeft
                                fontName:@"Arial"
                                fontSize:20.0];
    levels.color = ccGREEN;
    
    //Add to Billboard
    levelBill = [CC3Billboard nodeWithName:@"EndScoreBoard" withBillboard:levels];
    levelBill.location = cc3v(20.0, -20.0, -250);
    [levelBill alignToCamera:cam];
    [self addChild: levelBill];
    
    [levelBill runAction:moveUp3];
}
@end

