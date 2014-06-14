//
//  dictAppDelegate.h
//  DictionaeryMac
//
//  Created by Patrick Winchell on 6/13/14.
//  Copyright (c) 2014 Patrick Winchell. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface dictAppDelegate : NSObject <NSApplicationDelegate> {
    NSArray *_objects;
    NSArray *_filteredObjects;
    NSString *_currentFilter;
}

@property (assign) IBOutlet NSWindow *window;
@property (assign) IBOutlet NSTextView *textView;
@property (assign) IBOutlet NSTableView *tableView;
@end
