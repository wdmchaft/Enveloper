//
//  MidiEvent.h
//  Enveloper
//
//  Created by Christopher Latina on 4/26/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface Event : NSManagedObject

@property (nonatomic, retain) NSNumber * lsb;
@property (nonatomic, retain) NSNumber * msb;
@property (nonatomic, retain) NSDate * timestamp;
@end
