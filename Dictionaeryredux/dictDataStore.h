//
//  dictDataStore.h
//  Dictionaeryredux
//
//  Created by Patrick Winchell on 6/10/14.
//  Copyright (c) 2014 Patrick Winchell. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface dictDataStore : NSObject
{
    NSMutableData *receivedData;
    NSMutableData *responseData;
    
    NSDictionary *nodeDict;
    
    NSURLConnection* apiConnection;
}
+ (id)sharedDataStore;

- (NSArray*) DataforFilter:(NSString*)filter maxLength:(int)length;
- (NSArray*) DataForSearch:(NSString*)searchString;
@end
