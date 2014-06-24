//
//  dictTraumaeWord.h
//  Dictionaeryredux
//
//  Created by Patrick Winchell on 6/24/14.
//  Copyright (c) 2014 Patrick Winchell. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface dictTraumaeWord : NSObject

@property NSDictionary* dictionary;
@property bool valid;
@property NSString* sortString;
@property NSString* qwertyString;
@property NSString* searchString;
@property NSString* englishSearchString;

@property NSInteger children;
@property NSInteger rank;

@property NSString* traumae;
@property NSString* english;
@property NSString* adultspeak;
@property NSString* type;
@property NSArray* alternatives;

-(id)initWithDictionary:(NSDictionary*)dictionary;

@end
