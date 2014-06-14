//
//  dictAppDelegate.m
//  DictionaeryMac
//
//  Created by Patrick Winchell on 6/13/14.
//  Copyright (c) 2014 Patrick Winchell. All rights reserved.
//

#import "dictAppDelegate.h"
#import "dictDataStore.h"

@implementation dictAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
    _currentFilter = nil;
    _objects = [[dictDataStore sharedDataStore] DataforFilter:_currentFilter maxLength:2];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshData) name:@"dictDataStoreUpdate" object:nil];
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)theApplication {
    return true;
}

-(void)refreshData {
    if(_currentFilter!=nil)
        _objects = [[dictDataStore sharedDataStore] DataforFilter:_currentFilter maxLength:(int)_currentFilter.length+2];
    else
        _objects = [[dictDataStore sharedDataStore] DataforFilter:nil maxLength:2];
    [_tableView reloadData];
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView {
    if(!_objects)
        _objects = [[dictDataStore sharedDataStore] DataforFilter:Nil maxLength:2];
    return _objects.count;
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    
    NSView *view = [tableView makeViewWithIdentifier:@"dataCell" owner:self];
    NSDictionary *object = _objects[row];
    NSTextField *textField = [view viewWithTag:100];
    //if(textField!=NULL)
    //[textField setTitle:object[@"traumae"]];
    [textField setStringValue:[((NSString*)object[@"traumae"]) capitalizedString]];
    
    
    return view;
    
    
}

- (void)tableViewSelectionDidChange:(NSNotification *)aNotification {
    NSInteger row = [_tableView selectedRow];
    if(row!=-1) {
        NSDictionary *object = _objects[row];
        [self selectItem:object];
    }
}

-(void)selectItem:(NSDictionary*)object {
    if(object[@"children"]>0) {
        _currentFilter = object[@"traumae"];
        _objects = [[dictDataStore sharedDataStore] DataforFilter:_currentFilter maxLength:(int)_currentFilter.length+2];
        [_tableView scrollPoint:NSPointFromCGPoint(CGPointMake(0, 0))];
        [_tableView reloadData];
    }
    [_textView setString:[((NSString*)object[@"traumae"]) capitalizedString]];
}

@end
