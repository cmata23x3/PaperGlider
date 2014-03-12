//
//  ObjectGenerator.h
//  Paper Glider
//
//  Created by amadu on 1/30/13.
//
//

#import <Foundation/Foundation.h>

@interface ObjectGenerator : NSObject {}

-(NSMutableArray*) generateObject: (float) maxX: (float) maxY: (int) lights;

-(CC3Node*) generateCloud: (float) x: (float) y;
-(void) initialize;
@end
