/**
 *  Paper_GliderScene.h
 *  Paper Glider
 *
 *  Created by Christian M. Mata on 1/24/13.
 *  Copyright __MyCompanyName__ 2013. All rights reserved.
 */


#import "CC3Scene.h"

/** A sample application-specific CC3Scene subclass.*/
@interface Paper_GliderScene : CC3Scene {
}

- (void)handleGesture: (CGPoint) aVelocity;
- (void)fixPlane;
- (void) handleMotion: (UIAcceleration *)acceleration;

@end
