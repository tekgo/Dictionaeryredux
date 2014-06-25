//
//  dictTraumaeWord.m
//  Dictionaeryredux
//
//  Created by Patrick Winchell on 6/24/14.
//  Copyright (c) 2014 Patrick Winchell. All rights reserved.
//

#import "dictTraumaeWord.h"

@implementation dictTraumaeWord

- (id)init {
    if (self = [super init]) {
        _valid = false;
    }
    return self;
}

-(id)initWithDictionary:(NSDictionary*)dictionary {
    self = [self init];
    
    NSMutableDictionary *tempDict = [NSMutableDictionary dictionaryWithDictionary:dictionary];
    
    if(!tempDict || !tempDict[@"traumae"] || [tempDict[@"traumae"] length]<=0) {
        _valid=false;
        return self;
    }
    
    if(!tempDict[@"traumae"] || ![tempDict[@"traumae"] isKindOfClass:[NSString class]] || !tempDict[@"english"]) {
        _valid=false;
        return self;
    }
    if(![tempDict[@"english"] isKindOfClass:[NSString class]]) {
        if([tempDict[@"english"] isKindOfClass:[NSNumber class]]) {
            tempDict[@"english"] = [NSString stringWithFormat:@"%ld",(long)[(NSNumber*)tempDict[@"english"] integerValue]];
        }
    }
    
    _traumae =tempDict[@"traumae"];
    _adultspeak = tempDict[@"adultspeak"];
    _type  = tempDict[@"type"];
    
    _rank = [(NSNumber*)tempDict[@"rank"] integerValue];
    _children = [(NSNumber*)tempDict[@"children"] integerValue];
    
    NSString *englishval = @"";
    NSMutableArray *tempStringArray = [NSMutableArray new];
    NSMutableArray *tempEngArray = [NSMutableArray new];
    NSMutableArray *englishWords = [NSMutableArray new];
    [tempStringArray addObject:_traumae];
    [tempStringArray addObject:_adultspeak];
    
    if(tempDict[@"english"] && [tempDict[@"english"] isKindOfClass:[NSString class]]) {
        [tempStringArray addObject:tempDict[@"english"]];
        [tempEngArray addObject:tempDict[@"english"]];
        [englishWords addObject:tempDict[@"english"]];
        englishval = tempDict[@"english"];
    }
    if(tempDict[@"alternatives"] &&  [tempDict[@"alternatives"] isKindOfClass:[NSDictionary class]]) {
        for (NSString* key in tempDict[@"alternatives"]) {
            [tempStringArray addObject:key];
            [tempEngArray addObject:key];
            if(![englishval isEqualToString:key])
                [englishWords addObject:key];
        }
    }
    
    
    _english = englishval;
    
    
    
    _searchString = [tempStringArray componentsJoinedByString:@","];
    _englishSearchString =[tempEngArray componentsJoinedByString:@","];
    _alternatives =  englishWords;
    _sortString =[self toNumeric:(NSString*)tempDict[@"traumae"]];
    _qwertyString = [self toQwerty:(NSString*)tempDict[@"traumae"]];
    
    _dictionary = tempDict;
    _valid = true;
    return self;
}

// ------------------------
#  pragma mark Traumae Functions
// ------------------------

- (NSString*) toNumeric :(NSString*)traumae //Changes traumae to a numeric form for sorting.
{
	NSString *fixed = traumae;
	
	fixed = [fixed stringByReplacingOccurrencesOfString:@"xi" withString:@"01"];
	fixed = [fixed stringByReplacingOccurrencesOfString:@"di" withString:@"02"];
	fixed = [fixed stringByReplacingOccurrencesOfString:@"bi" withString:@"03"];
    fixed = [fixed stringByReplacingOccurrencesOfString:@"ki" withString:@"04"];
	fixed = [fixed stringByReplacingOccurrencesOfString:@"ti" withString:@"05"];
	fixed = [fixed stringByReplacingOccurrencesOfString:@"pi" withString:@"06"];
    fixed = [fixed stringByReplacingOccurrencesOfString:@"si" withString:@"07"];
	fixed = [fixed stringByReplacingOccurrencesOfString:@"li" withString:@"08"];
	fixed = [fixed stringByReplacingOccurrencesOfString:@"vi" withString:@"09"];
    
	fixed = [fixed stringByReplacingOccurrencesOfString:@"xa" withString:@"10"];
	fixed = [fixed stringByReplacingOccurrencesOfString:@"da" withString:@"11"];
	fixed = [fixed stringByReplacingOccurrencesOfString:@"ba" withString:@"12"];
    fixed = [fixed stringByReplacingOccurrencesOfString:@"ka" withString:@"13"];
	fixed = [fixed stringByReplacingOccurrencesOfString:@"ta" withString:@"14"];
	fixed = [fixed stringByReplacingOccurrencesOfString:@"pa" withString:@"15"];
    fixed = [fixed stringByReplacingOccurrencesOfString:@"sa" withString:@"16"];
	fixed = [fixed stringByReplacingOccurrencesOfString:@"la" withString:@"17"];
	fixed = [fixed stringByReplacingOccurrencesOfString:@"va" withString:@"18"];
    
	fixed = [fixed stringByReplacingOccurrencesOfString:@"xo" withString:@"19"];
	fixed = [fixed stringByReplacingOccurrencesOfString:@"do" withString:@"20"];
	fixed = [fixed stringByReplacingOccurrencesOfString:@"bo" withString:@"21"];
	fixed = [fixed stringByReplacingOccurrencesOfString:@"ko" withString:@"22"];
	fixed = [fixed stringByReplacingOccurrencesOfString:@"to" withString:@"23"];
	fixed = [fixed stringByReplacingOccurrencesOfString:@"po" withString:@"24"];
	fixed = [fixed stringByReplacingOccurrencesOfString:@"so" withString:@"25"];
	fixed = [fixed stringByReplacingOccurrencesOfString:@"lo" withString:@"26"];
	fixed = [fixed stringByReplacingOccurrencesOfString:@"vo" withString:@"27"];
    
	return fixed;
	
}

- (NSString*) toQwerty :(NSString*)traumae
{
	NSString *fixed = traumae;
	
	fixed = [fixed stringByReplacingOccurrencesOfString:@"xi" withString:@"w"];
	fixed = [fixed stringByReplacingOccurrencesOfString:@"di" withString:@"t"];
	fixed = [fixed stringByReplacingOccurrencesOfString:@"bi" withString:@"i"];
	fixed = [fixed stringByReplacingOccurrencesOfString:@"xa" withString:@"s"];
	fixed = [fixed stringByReplacingOccurrencesOfString:@"da" withString:@"g"];
	fixed = [fixed stringByReplacingOccurrencesOfString:@"ba" withString:@"k"];
	fixed = [fixed stringByReplacingOccurrencesOfString:@"xo" withString:@"x"];
	fixed = [fixed stringByReplacingOccurrencesOfString:@"do" withString:@"b"];
	fixed = [fixed stringByReplacingOccurrencesOfString:@"bo" withString:@","];
	
	fixed = [fixed stringByReplacingOccurrencesOfString:@"ki" withString:@"q"];
	fixed = [fixed stringByReplacingOccurrencesOfString:@"ti" withString:@"r"];
	fixed = [fixed stringByReplacingOccurrencesOfString:@"pi" withString:@"u"];
	fixed = [fixed stringByReplacingOccurrencesOfString:@"ka" withString:@"a"];
	fixed = [fixed stringByReplacingOccurrencesOfString:@"ta" withString:@"f"];
	fixed = [fixed stringByReplacingOccurrencesOfString:@"pa" withString:@"j"];
	fixed = [fixed stringByReplacingOccurrencesOfString:@"ko" withString:@"z"];
	fixed = [fixed stringByReplacingOccurrencesOfString:@"to" withString:@"v"];
	fixed = [fixed stringByReplacingOccurrencesOfString:@"po" withString:@"m"];
	
	fixed = [fixed stringByReplacingOccurrencesOfString:@"si" withString:@"e"];
	fixed = [fixed stringByReplacingOccurrencesOfString:@"li" withString:@"y"];
	fixed = [fixed stringByReplacingOccurrencesOfString:@"vi" withString:@"o"];
	fixed = [fixed stringByReplacingOccurrencesOfString:@"sa" withString:@"d"];
	fixed = [fixed stringByReplacingOccurrencesOfString:@"la" withString:@"h"];
	fixed = [fixed stringByReplacingOccurrencesOfString:@"va" withString:@"l"];
	fixed = [fixed stringByReplacingOccurrencesOfString:@"so" withString:@"c"];
	fixed = [fixed stringByReplacingOccurrencesOfString:@"lo" withString:@"n"];
	fixed = [fixed stringByReplacingOccurrencesOfString:@"vo" withString:@"."];
    
	return fixed;
	
}

@end
