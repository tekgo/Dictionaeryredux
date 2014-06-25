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
    NSString *_lastFilter;
    NSMutableArray* _filters;
    int filterIndex;
    IBOutlet NSToolbar *toolbar;
    IBOutlet NSView *searchView;
    IBOutlet NSView *navView;
    IBOutlet NSView *homeView;
    IBOutlet WebView *myWebView;
    NSPoint saveScrollPosition;
}

@property (assign) IBOutlet NSWindow *window;
@property (assign) IBOutlet NSTextView *textView;
@property (assign) IBOutlet NSTableView *tableView;
@property (assign) IBOutlet NSSearchField *searchField;

-(IBAction)goHome:(id)sender ;

-(IBAction)navAction:(id)sender;

@end
