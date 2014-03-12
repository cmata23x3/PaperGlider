/**
 *  _DTestingLayer.m
 *  3DTesting
 *
 *  Created by amadu on 1/17/13.
 *  Copyright __MyCompanyName__ 2013. All rights reserved.
 */

#import "_DTestingLayer.h"
#import "_DTestingScene.h"
#import "CC3ActionInterval.h"
#import "CC3CC2Extensions.h"
#import "CC3IOSExtensions.h"
#import "ccMacros.h"


@interface CC3Layer (TemplateMethods)
-(BOOL) handleTouch: (UITouch*) touch ofType: (uint) touchType;
@end

@interface _DTestingLayer (TemplateMethods)
@property(nonatomic, readonly) _DTestingScene* testingScene;
@end

@implementation _DTestingLayer

- (void)dealloc {
    [super dealloc];
}

-(_DTestingScene*) testingScene { return (_DTestingScene*) cc3Scene; }

/**
 * Override to set up your 2D controls and other initial state.
 *
 * For more info, read the notes of this method on CC3Layer.
 */
-(void) initializeControls {
}

#pragma mark Touch handling

/**
 * The ccTouchMoved:withEvent: method is optional for the <CCTouchDelegateProtocol>.
 * The event dispatcher will not dispatch events for which there is no method
 * implementation. Since the touch-move events are both voluminous and seldom used,
 * the implementation of ccTouchMoved:withEvent: has been left out of the default
 * CC3Layer implementation. To receive and handle touch-move events for object
 * picking, it must be implemented here.
 *
 * This method will not be invoked if gestures have been enabled.
 */
-(void) ccTouchMoved: (UITouch *)touch withEvent: (UIEvent *)event {
	[self handleTouch: touch ofType: kCCTouchMoved];
}

#pragma mark Updating layer

/**
 * Override to perform set-up activity prior to the scene being opened
 * on the view, such as adding gesture recognizers.
 *
 * For more info, read the notes of this method on CC3Layer.
 */
-(void) onOpenCC3Layer {
    
    // Register for single-finger dragging gestures used to spin the two cubes.
	UIPanGestureRecognizer* dragPanner = [[UIPanGestureRecognizer alloc]
										  initWithTarget: self action: @selector(handleDrag:)];
	dragPanner.minimumNumberOfTouches = 1;
	dragPanner.maximumNumberOfTouches = 1;
	[self cc3AddGestureRecognizer: dragPanner];
    [dragPanner release];
}

/**
 * This handler is invoked when a single-finger drag gesture is recognized.
 *
 * If the drag starts within a descendant CCNode that wants to capture the touch,
 * such as a menu or button, the gesture is cancelled.
 *
 * The CC3Scene marks where dragging begins to determine the node that is underneath
 * the touch point at that time, and is further notified as dragging proceeds.
 * It uses the velocity of the drag to spin the cube nodes. Finally, the scene is
 * notified when the dragging gesture finishes.
 *
 * The dragging movement is normalized to be specified relative to the size of the
 * layer, making it independant of the size of the layer.
 */
-(void) handleDrag: (UIPanGestureRecognizer*) gesture {
	switch (gesture.state) {
		case UIGestureRecognizerStateBegan:
//			if ( [self cc3ValidateGesture: gesture] ) {
//				[self.testingScene handleGesture:[self cc3NormalizeUIMovement: gesture.velocity]];
//			}
			break;
		case UIGestureRecognizerStateChanged:
//			[self.testingScene dragBy: [self cc3NormalizeUIMovement: gesture.translation]
//						  atVelocity:[self cc3NormalizeUIMovement: gesture.velocity]];
            [self.testingScene handleGesture:[self cc3NormalizeUIMovement: gesture.velocity]];
			break;
		case UIGestureRecognizerStateEnded:
			//[self.testingScene stopDragging];
			break;
		default:
			break;
	}
}

/**
 * Override to perform tear-down activity prior to the scene disappearing.
 *
 * For more info, read the notes of this method on CC3Layer.
 */
-(void) onCloseCC3Layer {}

/**
 * The ccTouchMoved:withEvent: method is optional for the <CCTouchDelegateProtocol>.
 * The event dispatcher will not dispatch events for which there is no method
 * implementation. Since the touch-move events are both voluminous and seldom used,
 * the implementation of ccTouchMoved:withEvent: has been left out of the default
 * CC3Layer implementation. To receive and handle touch-move events for object
 * picking, uncomment the following method implementation.
 */
/*
-(void) ccTouchMoved: (UITouch *)touch withEvent: (UIEvent *)event {
	[self handleTouch: touch ofType: kCCTouchMoved];
}
 */

@end
