/**
 *  Paper_GliderAppDelegate.m
 *  Paper Glider
 *
 *  Created by Christian M. Mata on 1/24/13.
 *  Copyright __MyCompanyName__ 2013. All rights reserved.
 */

#import "Paper_GliderAppDelegate.h"
#import "Paper_GliderLayer.h"
#import "Paper_GliderScene.h"
#import "MainMenu.h"
#import "CC3EAGLView.h"

#define kAnimationFrameRate		60		// Animation frame rate


@implementation Paper_GliderAppDelegate {
	UIWindow *window;
	CC3DeviceCameraOverlayUIViewController *viewController;
}

-(void) dealloc {
	[window release];
	[viewController release];
	[super dealloc];
}

-(void) applicationDidFinishLaunching: (UIApplication*) application {

	// Establish the type of CCDirector to use.
	// Try to use CADisplayLink director and if it fails (SDK < 3.1) use the default director.
	// This must be the first thing we do and must be done before establishing view controller.
	if( ! [CCDirector setDirectorType: kCCDirectorTypeDisplayLink] )
		[CCDirector setDirectorType: kCCDirectorTypeDefault];
	
	// Default texture format for PNG/BMP/TIFF/JPEG/GIF images.
	// It can be RGBA8888, RGBA4444, RGB5_A1, RGB565. You can change anytime.
	CCTexture2D.defaultAlphaPixelFormat = kCCTexture2DPixelFormat_RGBA8888;
	
	// Create the view controller for the 3D view.
	viewController = [CC3DeviceCameraOverlayUIViewController new];
   // viewController.supportedInterfaceOrientations = UIInterfaceOrientationMaskLandscapeRight;
    viewController.supportedInterfaceOrientations = UIInterfaceOrientationMaskAll;
    
	// Create the CCDirector, set the frame rate, and attach the view.
	CCDirector *director = CCDirector.sharedDirector;
	director.animationInterval = (1.0f / kAnimationFrameRate);
	director.displayFPS = YES;
	director.openGLView = viewController.view;
	
	// Enables High Res mode on Retina Displays and maintains low res on all other devices
	// This must be done after the GL view is assigned to the director!
	[director enableRetinaDisplay: NO];
	
	// Create the window, make the controller (and its view) the root of the window, and present the window
	window = [[UIWindow alloc] initWithFrame: [[UIScreen mainScreen] bounds]];
	[window addSubview: viewController.view];
	window.rootViewController = viewController;
	[window makeKeyAndVisible];
	
	// Set to YES for Augmented Reality 3D overlay on device camera.
	// This must be done after the window is made visible!
//	viewController.isOverlayingDeviceCamera = YES;

	
	// ******** START OF COCOS3D SETUP CODE... ********
	
	// Create the customized CC3Layer that supports 3D rendering and schedule it for automatic updates.
	CC3Layer* cc3Layer = [Paper_GliderLayer node];
	[cc3Layer scheduleUpdate];
	
	// Create the customized 3D scene and attach it to the layer.
	// Could also just create this inside the customer layer.
	cc3Layer.cc3Scene = [Paper_GliderScene scene];
	// Assign to a generic variable so we can uncomment options below to play with the capabilities
	CC3ControllableLayer* mainLayer = cc3Layer;
	
	// Attach the layer to the controller and run a scene with it.
	[viewController runSceneOnNode: mainLayer];
    
    [[UIAccelerometer sharedAccelerometer] setUpdateInterval:1/60];

    
    
}

/** Resume the cocos3d/cocos2d action. */
-(void) resumeApp { [CCDirector.sharedDirector resume]; }

-(void) applicationDidBecomeActive: (UIApplication*) application {
	
	// Workaround to fix the issue of drop to 40fps on iOS4.X on app resume.
	// Adds short delay before resuming the app.
	[NSTimer scheduledTimerWithTimeInterval: 0.5f
									 target: self
								   selector: @selector(resumeApp)
								   userInfo: nil
									repeats: NO];
	
	// If dropping to 40fps is not an issue, remove above, and uncomment the following to avoid delay.
//	[self resumeApp];
}

-(void) applicationDidReceiveMemoryWarning: (UIApplication*) application {
	[CCDirector.sharedDirector purgeCachedData];
}

-(void) applicationDidEnterBackground: (UIApplication*) application {
	[CCDirector.sharedDirector stopAnimation];
}

-(void) applicationWillEnterForeground: (UIApplication*) application {
	[CCDirector.sharedDirector startAnimation];
}

-(void)applicationWillTerminate: (UIApplication*) application {
	[CCDirector.sharedDirector.openGLView removeFromSuperview];
	[CCDirector.sharedDirector end];
}

-(void) applicationSignificantTimeChange: (UIApplication*) application {
	[CCDirector.sharedDirector setNextDeltaTimeZero: YES];
}

@end
