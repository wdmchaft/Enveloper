//
//  MidiControl.h
//  Enveloper
//
//  Created by Chris Latina on 4/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface MidiControl : NSObject
@property (nonatomic, retain) NSNumber * startNode;
@property (nonatomic, retain) NSDate * timeStamp;

@end
