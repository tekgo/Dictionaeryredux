//
//  dictDataStore.h
//  Dictionaeryredux
//
//  Created by Patrick Winchell on 6/10/14.
//  Copyright (c) 2014 Patrick Winchell. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "dictTraumaeWord.h"

@interface dictDataStore : NSObject
{
    NSMutableData *receivedData;
    NSMutableData *responseData;
    
    NSDictionary *nodeDict;
    
    NSArray* words;
    
    NSURLConnection* apiConnection;
    
    
}
+ (id)sharedDataStore;

- (NSArray*) DataforFilterWithParents:(NSString*)filter maxLength:(int)length;
- (NSArray*) DataforFilter:(NSString*)filter maxLength:(int)length;
- (NSArray*) DataForSearch:(NSString*)searchString;
-(dictTraumaeWord*)getWord:(NSString*)word;
@end
