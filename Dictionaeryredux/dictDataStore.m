//
//  dictDataStore.m
//  Dictionaeryredux
//
//  Created by Patrick Winchell on 6/10/14.
//  Copyright (c) 2014 Patrick Winchell. All rights reserved.
//

#import "dictDataStore.h"

@implementation dictDataStore


+ (id)sharedDataStore {
    static dictDataStore *sharedDataStore = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedDataStore = [[self alloc] init];
    });
    return sharedDataStore;
}

- (id)init {
    if (self = [super init]) {
        [self dictionaeryUpdate];
        [self dictionaeryLoad:nil];
    }
    return self;
}


// ------------------------
#  pragma mark API
// ------------------------

- (void)apiPull
{
	NSURL *myURL = [NSURL URLWithString: @"http://api.xxiivv.com/?key=traumae" ];
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:myURL cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:60];
	[[NSURLConnection alloc] initWithRequest:request delegate:self];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
	responseData = [[NSMutableData alloc] init];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
	[responseData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
	
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	NSString *response = [[NSString alloc] initWithData:responseData encoding: NSASCIIStringEncoding];
	[self dictionaeryLoad:response];
}

// ------------------------
#  pragma mark Dictionaery
// ------------------------


- (void) dictionaeryUpdate
{
	[self apiPull];
}

-(void)dictionaeryLoad:(NSString*)newData {
    if(newData) {
        NSError *error;
        NSDictionary *JSON = [NSJSONSerialization JSONObjectWithData: [newData dataUsingEncoding:NSUTF8StringEncoding] options: NSJSONReadingMutableContainers error: &error];
        if(!error) {
            [newData writeToFile:[[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:@"newDict.json"] atomically:YES encoding:NSUTF8StringEncoding error:&error];
            [self dictionaerySequence:JSON];
            return;
        }
    }
    if([[NSFileManager defaultManager] fileExistsAtPath:[[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:@"newDict.json"] ]) {
        NSError *error;
        NSString *loadedData = [NSString stringWithContentsOfFile:[[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:@"newDict.json"] encoding:NSUTF8StringEncoding error:&error];
        if(!error) {
            NSDictionary *JSON = [NSJSONSerialization JSONObjectWithData: [loadedData dataUsingEncoding:NSUTF8StringEncoding] options: NSJSONReadingMutableContainers error: &error];
            if(!error) {
                [self dictionaerySequence:JSON];
                return;
            }
        }
    }
    NSError *error;
    NSString *loadedData = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"dict" ofType:@"json"] encoding:NSUTF8StringEncoding error:&error];
    if(!error) {
        NSDictionary *JSON = [NSJSONSerialization JSONObjectWithData: [loadedData dataUsingEncoding:NSUTF8StringEncoding] options: NSJSONReadingMutableContainers error: &error];
        if(!error) {
            [self dictionaerySequence:JSON];
            return;
        }
    }
}

- (void) dictionaerySequenceFilter
{   NSMutableDictionary *tempDict = [NSMutableDictionary new];
    for (NSString* key in nodeRaw) {
        id value = [nodeRaw objectForKey:key];
        NSString *englishval = @"";
        if(value[@"traumae"]!=NULL && [value[@"traumae"] length]>0){
            NSMutableDictionary *tempVal = [NSMutableDictionary dictionaryWithDictionary:value];
            NSMutableArray *tempStringArray = [NSMutableArray new];
            NSMutableArray *tempEngArray = [NSMutableArray new];
            NSMutableArray *englishWords = [NSMutableArray new];
            [tempStringArray addObject:value[@"traumae"]];
            [tempStringArray addObject:value[@"adultspeak"]];
            if(value[@"english"] && [value[@"english"] isKindOfClass:[NSString class]]) {
                [tempStringArray addObject:value[@"english"]];
                [tempEngArray addObject:value[@"english"]];
                [englishWords addObject:value[@"english"]];
                englishval = value[@"english"];
            }
            if(value[@"alternatives"] &&  [value[@"alternatives"] isKindOfClass:[NSDictionary class]]) {
                for (NSString* key in value[@"alternatives"]) {
                    [tempStringArray addObject:key];
                    [tempEngArray addObject:key];
                    if(![englishval isEqualToString:key])
                        [englishWords addObject:key];
                }
            }
            [tempVal setObject:[tempStringArray componentsJoinedByString:@","] forKey:@"searchString"];
            [tempVal setObject:[tempEngArray componentsJoinedByString:@","] forKey:@"engSearchString"];
            [tempVal setObject:englishWords forKey:@"englishWords"];
            [tempVal setObject:[self toNumeric:(NSString*)value[@"traumae"]] forKey:@"numericSort"];
            [tempDict setObject:tempVal forKey:key];
        }
    }
	nodeDict = tempDict;//[self dictionaerySequenceFilterLoop];
}

- (void) dictionaerySequence :(NSDictionary*)sequence
{
	nodeRaw = sequence;
    //	[self dictionaeryTypesColoursCreate:sequence];
	[self dictionaerySequenceFilter];
}


- (NSArray*) DataforFilter:(NSString*)filter maxLength:(int)length {
    NSMutableArray *tempArray = [NSMutableArray new];
    for (NSString* key in nodeDict) {
		NSDictionary *value = [nodeDict objectForKey:key];
        
		
		// Default letters
        if(!filter || [(NSString*)value[@"traumae"]  rangeOfString:filter].location == 0) {
            if([value[@"traumae"] length] <= length && [value[@"traumae"] length]>0){
                
                NSMutableDictionary *tempVal = [NSMutableDictionary dictionaryWithDictionary:value];
                
                
                [tempArray addObject:tempVal];
            }
        }
		
	}
    
    NSArray *sortedArray = [tempArray sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
        NSString *first = ((NSDictionary*)a)[@"numericSort"];
        NSString *second = ((NSDictionary*)b)[@"numericSort"];
        return [first compare:second];
    }];
    
    sortedArray = [sortedArray sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
        NSString *first = ((NSDictionary*)a)[@"traumae"];
        NSString *second = ((NSDictionary*)b)[@"traumae"];
        NSNumber *firsta = [NSNumber numberWithLong:first.length];
        NSNumber *seconda = [NSNumber numberWithLong:second.length];
        return [firsta compare:seconda];
    }];
    tempArray = [NSMutableArray arrayWithArray:sortedArray];
    
    for(int i=0;i<tempArray.count;i++) {
        NSDictionary* value = tempArray[i];
        if([(NSString*)value[@"traumae"] isEqualToString:filter]) {
            [tempArray removeObject:value];
            [tempArray insertObject:value atIndex:0];
            break;
        }
    }
    
    return sortedArray;
    
}

-(NSArray*) DataForSearch:(NSString*)searchString {
    if(searchString.length<2)
        return [NSArray new];
    NSMutableArray *tempArrays = [NSMutableArray new];
    tempArrays[0] = [NSMutableArray new];
    tempArrays[1] = [NSMutableArray new];
    tempArrays[2] = [NSMutableArray new];
    for (NSString* key in nodeDict) {
        NSDictionary* value = [nodeDict objectForKey:key];
        if([(NSString*)value[@"searchString"]  rangeOfString:searchString].location != NSNotFound) {
            
            BOOL added=false;
            if([(NSString*)value[@"traumae"]  rangeOfString:searchString].location == 0) {
                [tempArrays[0] addObject:value];
                added=true;
            }
            if([(NSString*)value[@"adultspeak"]  rangeOfString:searchString].location == 0) {
                [tempArrays[0] addObject:value];
                added=true;
            }
            if(!added && [(NSString*)value[@"traumae"]  rangeOfString:searchString].location != NSNotFound) {
                [tempArrays[1] addObject:value];
                added=true;
            }
            if(!added && [(NSString*)value[@"adultspeak"]  rangeOfString:searchString].location != NSNotFound) {
                [tempArrays[1] addObject:value];
                added=true;
            }
            if(!added && [(NSString*)value[@"engSearchString"]  rangeOfString:searchString].location != NSNotFound) {
                [tempArrays[2] addObject:value];
                added=true;
            }
            
        }
        
    }
    
    NSMutableArray *tempArray = [NSMutableArray new];
    for(NSArray* arr in tempArrays) {
        [tempArray addObjectsFromArray:arr];
    }
    
    return tempArray;
}

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


@end
