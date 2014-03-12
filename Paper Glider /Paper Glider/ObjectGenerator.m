//
//  ObjectGenerator.m
//  Paper Glider
//
//  Created by amadu on 1/30/13.
//
//

#import "CC3Node.h"
#import "ObjectGenerator.h"
#import "CC3PODResourceNode.h"
#import "CC3ActionInterval.h"
#include <stdlib.h>

#define numOfObjects 5
#define ratio 7
#define z -20

// define all object numbers
// #define sphere 0

NSMutableArray* badObjects;
NSMutableArray* goodObjects;
NSMutableArray* sphereArray;
NSMutableArray* charmArray;
NSMutableArray* bonusObjArray;
NSNumber* sphere;
NSNumber* charm;
NSNumber* bonusObj;
int badCounter = 0;
int xrange = 170;
int yrange = 100;

@implementation ObjectGenerator

-(void) initialize {
    
    // initialize all NSNumbers
    sphere = [NSNumber numberWithInt: 0];
    charm = [NSNumber numberWithInt:1];
    bonusObj = [NSNumber numberWithInt:2];
    
    // initialize all objectArrays
    sphereArray = [[NSMutableArray alloc] initWithObjects:@"bad_cube.pod", sphere, nil];
    charmArray = [[NSMutableArray alloc] initWithObjects:@"charm_cube.pod", charm, nil];
    bonusObjArray = [[NSMutableArray alloc] initWithObjects:@"bonus_box.pod", bonusObj, nil];
    
    // construct the list of lists of [.pod, number]files
    badObjects = [[NSMutableArray alloc] initWithObjects:sphereArray, nil];
    goodObjects = [[NSMutableArray alloc] initWithObjects:charmArray, bonusObjArray, nil];
    
}

-(NSMutableArray*) generateObject: (float) maxX: (float) maxY: (int) lights {
    
    float x = (rand() / 2147483647.0) * maxX;
    float y = (rand() / 2147483647.0) * maxY;
    
    if (badCounter % 7 == 0 && badCounter != 0 && lights < 6) {
        
        // generate goodObject
        int random = (rand() / 2147483647.0) * [goodObjects count];
        
        CC3PODResourceNode* goodObject = [CC3PODResourceNode nodeWithName:@"BAD"];
        
        NSString* file = [[goodObjects objectAtIndex: random] objectAtIndex:0];
        
        goodObject.resource = [CC3PODResource resourceFromFile:file];
        
        goodObject.location = cc3v(x, y, z);
        
        //goodObject.isOpaque = YES;//Delete later
        goodObject.uniformScale = 0.07;
        goodObject.shouldCastShadowsWhenInvisible = NO;
        goodObject.shouldUseSmoothShading =YES;
        
        NSMutableArray* goodObjectArray = [NSMutableArray arrayWithObjects:goodObject,[[goodObjects objectAtIndex: random] objectAtIndex:1], nil];
        
        badCounter++;
        return goodObjectArray;
    }
    else {
        
        // generate badObject
        int random = (rand() / 2147483647.0) *  [badObjects count];
        
        CC3PODResourceNode* badObject = [CC3PODResourceNode nodeWithName:@"BAD"];
        
        NSString* file = [[badObjects objectAtIndex: random] objectAtIndex:0];
        NSLog(@"File Names%@", sphereArray);
        
        badObject.resource = [CC3PODResource resourceFromFile:file];
        
        badObject.location = cc3v(x, y, z);
        
        badObject.isOpaque = YES;//Delete later
        badObject.uniformScale = 0.07;
        badObject.shouldCastShadowsWhenInvisible = NO;
        badObject.shouldUseSmoothShading =YES;
        
        NSMutableArray* badObjectArray = [NSMutableArray arrayWithObjects:badObject,[[badObjects objectAtIndex: random] objectAtIndex:1], nil];
        
        badCounter++;
        return badObjectArray;
    }
}

-(CC3Node*) generateCloud: (float) x: (float) y {
    
    CC3PODResourceNode* cloud = [CC3PODResourceNode nodeWithName:@"Cloud"];
    cloud.resource = [CC3PODResource resourceFromFile:@"volume_clouds.pod"];
    cloud.shouldUseLighting = NO;
    cloud.location = cc3v(x, y, z);
    CCActionInterval* moveUp = [CC3MoveForwardBy actionWithDuration:10.0
                                                             moveBy:50.0];
    [cloud runAction:moveUp];
    return cloud;
    
    
}

@end
