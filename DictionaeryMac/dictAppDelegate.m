//
//  dictAppDelegate.m
//  DictionaeryMac
//
//  Created by Patrick Winchell on 6/13/14.
//  Copyright (c) 2014 Patrick Winchell. All rights reserved.
//

#import "dictAppDelegate.h"
#import "dictDataStore.h"

#define kSearchToolbarItemID      @"SearchItem"
#define kNavToolbarItemID     @"NavItem"
#define kHomeToolbarItemID     @"HomeItem"

@implementation dictAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
    _currentFilter = nil;
    _objects = [[dictDataStore sharedDataStore] DataforFilter:_currentFilter maxLength:2];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshData) name:@"dictDataStoreUpdate" object:nil];
    [toolbar setDelegate:self];
    
    [toolbar setAllowsUserCustomization:YES];
    
    // tell the toolbar that it should save any configuration changes to user defaults.  ie. mode
    // changes, or reordering will persist.  Specifically they will be written in the app domain using
    // the toolbar identifier as the key.
    //
    [toolbar setAutosavesConfiguration:YES];
    
    // tell the toolbar to show icons only by default
    [toolbar setDisplayMode:NSToolbarDisplayModeIconOnly];
    NSData *htmlData = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"core" ofType:@"html"]];
    NSAttributedString *textToBeInserted = [[NSAttributedString alloc] initWithHTML:htmlData documentAttributes:nil];
    [[_textView textStorage] setAttributedString:textToBeInserted];
    
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
    
    NSFont *font =[NSFont fontWithName:@"Septambres-Revisit" size:24];
    
    NSDictionary *attrsDictionary = [NSDictionary dictionaryWithObject:font
                                                                forKey:NSFontAttributeName];
    NSAttributedString *theNewString = [[NSAttributedString alloc] initWithString:[self toQwerty:object[@"traumae"]] attributes:attrsDictionary];
    [[_textView textStorage] appendAttributedString:theNewString];
    //[_textView setAttributedStringValue:theNewString];
    
}

#pragma mark -
#pragma mark NSToolbarItemValidation

//--------------------------------------------------------------------------------------------------
// We don't do anything useful here (and we don't really have to implement this method) but you could
// if you wanted to. If, however, you want to have validation checks on your standard NSToolbarItems
// (with images) and have inactive ones grayed out, then this is the method for you.
// It isn't called for custom NSToolbarItems (with custom views); you'd have to override -validate:
// (see NSToolbarItem.h for a discussion) to get it to do so if you wanted it to.
// If you don't implement this method, the NSToolbarItems are enabled by default.
//--------------------------------------------------------------------------------------------------
- (BOOL)validateToolbarItem:(NSToolbarItem *)theItem
{
    // You could check [theItem itemIdentifier] here and take appropriate action if you wanted to
    return YES;
}


#pragma mark -
#pragma mark NSToolbarDelegate

//--------------------------------------------------------------------------------------------------
// This is an optional delegate method, called when a new item is about to be added to the toolbar.
// This is a good spot to set up initial state information for toolbar items, particularly ones
// that you don't directly control yourself (like with NSToolbarPrintItemIdentifier here).
// The notification's object is the toolbar, and the @"item" key in the userInfo is the toolbar item
// being added.
//--------------------------------------------------------------------------------------------------
- (void)toolbarWillAddItem:(NSNotification *)notif
{
    NSToolbarItem *addedItem = [[notif userInfo] objectForKey:@"item"];
    
    // Is this the printing toolbar item?  If so, then we want to redirect it's action to ourselves
    // so we can handle the printing properly; hence, we give it a new target.
    //
    if ([[addedItem itemIdentifier] isEqual: NSToolbarPrintItemIdentifier])
    {
        [addedItem setToolTip:@"Print your document"];
        [addedItem setTarget:self];
    }
}

//--------------------------------------------------------------------------------------------------
// This method is required of NSToolbar delegates.
// It takes an identifier, and returns the matching NSToolbarItem. It also takes a parameter telling
// whether this toolbar item is going into an actual toolbar, or whether it's going to be displayed
// in a customization palette.
//--------------------------------------------------------------------------------------------------
- (NSToolbarItem *)toolbar:(NSToolbar *)toolbar itemForItemIdentifier:(NSString *)itemIdentifier willBeInsertedIntoToolbar:(BOOL)flag
{
    NSToolbarItem *toolbarItem = nil;
    
    // We create and autorelease a new NSToolbarItem, and then go through the process of setting up its
    // attributes from the master toolbar item matching that identifier in our dictionary of items.
    if ([itemIdentifier isEqualToString:kSearchToolbarItemID])
    {
        // 1) Font style toolbar item
        toolbarItem = [self toolbarItemWithIdentifier:kSearchToolbarItemID
                                                label:@"Search"
                                          paleteLabel:@"Search"
                                              toolTip:@"Search"
                                               target:self
                                          itemContent:searchView
                                               action:nil
                                                 menu:nil];
    }
    else if ([itemIdentifier isEqualToString:kNavToolbarItemID])
    {
        // 2) Font size toolbar item
        toolbarItem = [self toolbarItemWithIdentifier:kNavToolbarItemID
                                                label:@"Navigation"
                                          paleteLabel:@"Navigation"
                                              toolTip:@"Navigation"
                                               target:self
                                          itemContent:navView
                                               action:nil
                                                 menu:nil];
    }
    else if ([itemIdentifier isEqualToString:kHomeToolbarItemID])
    {
        // 2) Font size toolbar item
        toolbarItem = [self toolbarItemWithIdentifier:kHomeToolbarItemID
                                                label:@"Home"
                                          paleteLabel:@"Home"
                                              toolTip:@"Home"
                                               target:self
                                          itemContent:homeView
                                               action:nil
                                                 menu:nil];
    }
    
    return toolbarItem;
}

//--------------------------------------------------------------------------------------------------
// This method is required of NSToolbar delegates.  It returns an array holding identifiers for the default
// set of toolbar items.  It can also be called by the customization palette to display the default toolbar.
//--------------------------------------------------------------------------------------------------
- (NSArray *)toolbarDefaultItemIdentifiers:(NSToolbar *)toolbar
{
    return [NSArray arrayWithObjects:   kHomeToolbarItemID,
            kNavToolbarItemID,
            NSToolbarFlexibleSpaceItemIdentifier,
            kSearchToolbarItemID,
            nil];
    // note:
    // that since our toolbar is defined from Interface Builder, an additional separator and customize
    // toolbar items will be automatically added to the "default" list of items.
}

//--------------------------------------------------------------------------------------------------
// This method is required of NSToolbar delegates.  It returns an array holding identifiers for all allowed
// toolbar items in this toolbar.  Any not listed here will not be available in the customization palette.
//--------------------------------------------------------------------------------------------------
- (NSArray *)toolbarAllowedItemIdentifiers:(NSToolbar *)toolbar
{
    return [NSArray arrayWithObjects:  kHomeToolbarItemID,
            kSearchToolbarItemID,
            kNavToolbarItemID,
            NSToolbarSpaceItemIdentifier,
            NSToolbarFlexibleSpaceItemIdentifier,
            nil];
    // note:
    // that since our toolbar is defined from Interface Builder, an additional separator and customize
    // toolbar items will be automatically added to the "default" list of items.
}

- (NSToolbarItem *)toolbarItemWithIdentifier:(NSString *)identifier
                                       label:(NSString *)label
                                 paleteLabel:(NSString *)paletteLabel
                                     toolTip:(NSString *)toolTip
                                      target:(id)target
                                 itemContent:(id)imageOrView
                                      action:(SEL)action
                                        menu:(NSMenu *)menu
{
    // here we create the NSToolbarItem and setup its attributes in line with the parameters
    NSToolbarItem *item = [[NSToolbarItem alloc] initWithItemIdentifier:identifier];
    
    [item setLabel:label];
    [item setPaletteLabel:paletteLabel];
    [item setToolTip:toolTip];
    [item setTarget:target];
    [item setAction:action];
    
    // Set the right attribute, depending on if we were given an image or a view
    if([imageOrView isKindOfClass:[NSImage class]]){
        [item setImage:imageOrView];
    } else if ([imageOrView isKindOfClass:[NSView class]]){
        [item setView:imageOrView];
    }else {
        assert(!"Invalid itemContent: object");
    }
    
    
    
    return item;
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
