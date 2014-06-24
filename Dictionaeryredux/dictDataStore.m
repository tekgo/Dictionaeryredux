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
	apiConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
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


- (void) dictionaerySequence :(NSDictionary*)nodeRaw
{
	NSMutableArray *tempArr = [NSMutableArray new];
    for (NSString* key in nodeRaw) {
        id value = [nodeRaw objectForKey:key];
        
        dictTraumaeWord* word = [[dictTraumaeWord alloc] initWithDictionary:value];
        if(word.valid) {
            [tempArr addObject:word];
        }
        
        
        }
	words = tempArr;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"dictDataStoreUpdate" object:self];
}

// ------------------------
#  pragma mark Search Functions
// ------------------------


- (NSArray*) DataforFilter:(NSString*)filter maxLength:(int)length {
    NSMutableArray *tempArray = [NSMutableArray new];
    for (dictTraumaeWord* word in words) {;
        
		
		// Default letters
        if(!filter || [word.traumae  rangeOfString:filter].location == 0) {
            if([word.traumae length] <= length && [word.traumae length]>0){
                
                //NSMutableDictionary *tempVal = [NSMutableDictionary dictionaryWithDictionary:value];
                
                
                [tempArray addObject:word];
            }
        }
		
	}
    
    NSArray *sortedArray = [tempArray sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
        NSString *first = ((dictTraumaeWord*)a).sortString;
        NSString *second = ((dictTraumaeWord*)b).sortString;
        return [first compare:second];
    }];
    
    sortedArray = [sortedArray sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
        NSString *first = ((dictTraumaeWord*)a).traumae;
        NSString *second = ((dictTraumaeWord*)b).traumae;
        NSNumber *firsta = [NSNumber numberWithLong:first.length];
        NSNumber *seconda = [NSNumber numberWithLong:second.length];
        return [firsta compare:seconda];
    }];
    tempArray = [NSMutableArray arrayWithArray:sortedArray];
    
    for(int i=0;i<tempArray.count;i++) {
        dictTraumaeWord* word = tempArray[i];
        if([word.traumae isEqualToString:filter]) {
            [tempArray removeObject:word];
            [tempArray insertObject:word atIndex:0];
            break;
        }
    }
    
    return sortedArray;
    
}

- (NSArray*) DataforFilterWithParents:(NSString*)filter maxLength:(int)length {
    NSMutableArray *tempArray = [NSMutableArray new];
    for (dictTraumaeWord* word in words) {
        
		bool added=false;
		// Default letters
        if(!filter || [word.traumae  rangeOfString:filter].location == 0) {
            if([word.traumae length] <= length && [word.traumae length]>0){
                
                
                added=true;
                [tempArray addObject:word];
            }
        }
        if(!added && filter) {
            if([filter rangeOfString:word.traumae].location == 0) {
                [tempArray addObject:word];
            }
        }
		
	}
    
    NSArray *sortedArray = [tempArray sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
        NSString *first = ((dictTraumaeWord*)a).sortString;
        NSString *second = ((dictTraumaeWord*)b).sortString;
        return [first compare:second];
    }];
    
    sortedArray = [sortedArray sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
        NSString *first = ((dictTraumaeWord*)a).traumae;
        NSString *second = ((dictTraumaeWord*)b).traumae;
        NSNumber *firsta = [NSNumber numberWithLong:first.length];
        NSNumber *seconda = [NSNumber numberWithLong:second.length];
        return [firsta compare:seconda];
    }];
    tempArray = [NSMutableArray arrayWithArray:sortedArray];
    
    for(int i=0;i<tempArray.count;i++) {
        dictTraumaeWord* word = tempArray[i];
        if([word.traumae isEqualToString:filter]) {
            [tempArray removeObject:word];
            [tempArray insertObject:word atIndex:0];
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
    for (dictTraumaeWord* word in words) {
        
        if([word.searchString  rangeOfString:searchString].location != NSNotFound) {
            
            BOOL added=false;
            if([word.traumae  rangeOfString:searchString].location == 0) {
                [tempArrays[0] addObject:word];
                added=true;
            }
            if([word.adultspeak  rangeOfString:searchString].location == 0) {
                [tempArrays[0] addObject:word];
                added=true;
            }
            if(!added && [word.traumae  rangeOfString:searchString].location != NSNotFound) {
                [tempArrays[1] addObject:word];
                added=true;
            }
            if(!added && [word.adultspeak rangeOfString:searchString].location != NSNotFound) {
                [tempArrays[1] addObject:word];
                added=true;
            }
            if(!added && [word.englishSearchString rangeOfString:searchString].location != NSNotFound) {
                [tempArrays[2] addObject:word];
            }
            
        }
        
    }
    
    NSMutableArray *tempArray = [NSMutableArray new];
    for(NSArray* arr in tempArrays) {
        [tempArray addObjectsFromArray:arr];
    }
    
    return tempArray;
}

-(dictTraumaeWord*)getWord:(NSString*)word {
    for (dictTraumaeWord* tword in words) {
        if(tword.traumae && [[tword.traumae lowercaseString] isEqualToString:[[word lowercaseString] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]])
            return tword;
        
    }

    return nil;
}




@end
