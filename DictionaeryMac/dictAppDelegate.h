//
//  dictAppDelegate.h
//  DictionaeryMac
//
//  Created by Patrick Winchell on 6/13/14.
//  Copyright (c) 2014 Patrick Winchell. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>

@interface dictAppDelegate : NSObject <NSApplicationDelegate,NSToolbarDelegate> {
    NSArray *_objects;
    NSArray *_filteredObjects;
    NSString *_currentFilter;
    IBOutlet NSToolbar *toolbar;
    IBOutlet NSView *searchView;
    IBOutlet NSView *navView;
    IBOutlet NSView *homeView;
    IBOutlet WebView *myWebView;
}

@property (assign) IBOutlet NSWindow *window;
@property (assign) IBOutlet NSTextView *textView;
@property (assign) IBOutlet NSTableView *tableView;

-(IBAction)goHome:(id)sender ;
@end
