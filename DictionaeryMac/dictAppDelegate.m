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
    
    NSString* filePath = [[NSBundle mainBundle] pathForResource:@"template" ofType:@"html"];
    NSURL* fileURL = [NSURL fileURLWithPath:filePath];
    NSError* err;
    htmlTemplate = [NSString stringWithContentsOfURL:fileURL encoding:NSUTF8StringEncoding error:&err];
    // Insert code here to initialize your application
    _filters = [NSMutableArray new];
    filterIndex = 0;
    _currentFilter = @"";
    [self setFilter:@""];
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
    
    [self goHome:self];
    [myWebView setPolicyDelegate:self];
    [myWebView setFrameLoadDelegate:self];
    
    
    [self setButtonStates];
}

- (void)webView:(WebView *)sender didFinishLoadForFrame:(WebFrame *)frame {
    NSScrollView *scrollView = [[[[myWebView mainFrame] frameView] documentView] enclosingScrollView];
    [[scrollView documentView] scrollPoint:saveScrollPosition];
}

- (void)webView:(WebView *)sender didCommitLoadForFrame:(WebFrame *)frame {
    NSScrollView *scrollView = [[[[myWebView mainFrame] frameView] documentView] enclosingScrollView];
    [[scrollView documentView] scrollPoint:saveScrollPosition];
}

- (void)webView:(WebView *)sender decidePolicyForNavigationAction:(NSDictionary *)actionInformation request:(NSURLRequest *)request frame:(WebFrame *)frame decisionListener:(id<WebPolicyDecisionListener>)listener {
    
    NSUInteger actionType = [[actionInformation objectForKey:WebActionNavigationTypeKey] unsignedIntValue];
    if (actionType == WebNavigationTypeLinkClicked) {
        NSString *host = [[request URL] host];
        if (host) {
            [[NSWorkspace sharedWorkspace] openURL:[actionInformation objectForKey:WebActionOriginalURLKey]];
            [listener ignore];
        } else {
            NSString *lastPath = [[[request URL] absoluteString] lowercaseString];
            if([lastPath  rangeOfString:@"traumae:"].location != NSNotFound) {
                NSString* traumaeWord = [[lastPath componentsSeparatedByString:@":"] lastObject];
                [self selectWord:traumaeWord forced:true];
                [listener ignore];
                return;
            }
            [listener use];
        }

    } else {
        [listener use];
    }
    
    
    
}

- (void)webView:(WebView *)sender decidePolicyForNewWindowAction:(NSDictionary *)actionInformation request:(NSURLRequest *)request newFrameName:(NSString *)frameName decisionListener:(id<WebPolicyDecisionListener>)listener {
    [[NSWorkspace sharedWorkspace] openURL:[actionInformation objectForKey:WebActionOriginalURLKey]];
    [listener ignore];
}

-(IBAction)goHome:(id)sender {
    [self loadWord:[[dictTraumaeWord alloc] init]];
    [self setFilter:@""];
    [self setButtonStates];
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)theApplication {
    return true;
}

-(void)refreshData {
    if(![_currentFilter isEqualToString:@""]) {
        if([_currentFilter rangeOfString:@"!"].location==0) {
            NSString* newFilter = [[_currentFilter componentsSeparatedByString:@"!"] lastObject];
            _objects = [[dictDataStore sharedDataStore] DataForSearch:newFilter];
            //_objects = [[dictDataStore sharedDataStore] DataforFilterWithParents:newFilter maxLength:(int)newFilter.length+2];
        }
        else {
            _objects = [[dictDataStore sharedDataStore] DataforFilterWithParents:_currentFilter maxLength:(int)_currentFilter.length+2];
        }
    }
    else {
        _objects = [[dictDataStore sharedDataStore] DataforFilter:nil maxLength:2];
    }
    [_tableView scrollPoint:NSPointFromCGPoint(CGPointMake(0, 0))];
    [_tableView reloadData];
}

-(void)setFilter:(NSString*)newFilter {
    if(![_currentFilter isEqualToString:newFilter])
        if(!_currentFilter || !newFilter || [_currentFilter rangeOfString:@"!"].location!=0 || [newFilter rangeOfString:@"!"].location!=0)
            _lastFilter=_currentFilter;
    _currentFilter = newFilter;
    
    if([newFilter rangeOfString:@"!"].location==0) {
        [_searchField setStringValue:[[newFilter componentsSeparatedByString:@"!"] lastObject]];
    }
    
    if([_currentFilter isEqualToString:@"!"] && _filters.count>0) {
        _currentFilter = _lastFilter;
        [self setFilter:_currentFilter];
    }
    else {
        [self refreshData];
    }
}

-(void)navAction:(int)direction {
    BOOL indexChanged = false;
    [self saveScrollPosition];
        if (direction==-1) {
            if(filterIndex>0) {
                filterIndex--;
                indexChanged=true;
                //_currentFilter = [_filters objectAtIndex:filterIndex];
                //[self refreshData];
            }
        } else if (direction==1) {
            if(filterIndex+1<_filters.count) {
                filterIndex++;
                
                indexChanged=true;
                //[self refreshData];
            }
        }
    if(indexChanged) {
        NSDictionary *tempDict =[_filters objectAtIndex:filterIndex];
        
        [self setFilter:tempDict[@"filter"]];
        [self showWord: tempDict[@"word"]];
        
        [self restoreScrollPosition:tempDict[@"scrollPosition"]];
    }
    [self setButtonStates];
}
-(IBAction)goBack:(id)sender {
    [self navAction:-1];
}
-(IBAction)goForward:(id)sender {
    [self navAction:1];
}

-(void)setButtonStates {
    [forwardButton setEnabled:false];
    [backButton setEnabled:false];
    if(filterIndex>0 && _filters.count>1) {
        [backButton setEnabled:true];
    }
    if(filterIndex+1<_filters.count && _filters.count>1) {
        [forwardButton setEnabled:true];
    }
}


-(void)showWord:(dictTraumaeWord*)word {
    if(word.valid) {
        NSMutableArray* elements = [NSMutableArray new];
        NSString *adultSpeak = @"";
        //if(![word.traumae isEqualToString:word.adultspeak])
            adultSpeak = word.adultspeak;
        [elements addObject:[NSString stringWithFormat:@"<div class='traumword'>%@</div><div class='word'>%@ <span class='adultspeak'>%@</span></div>",word.qwertyString,word.traumae,adultSpeak]];
        /*if(![word.traumae isEqualToString:word.adultspeak])
            [elements addObject:[NSString stringWithFormat:@"<div class='adultspeak'>%@</div>",word.adultspeak ]];*/
        
        [elements addObject:[NSString stringWithFormat:@"<ul><li>%@</ul>",[word.alternatives componentsJoinedByString:@"<li>"]]];
        
        if(word.traumae.length>2) {
            NSMutableArray *comp = [NSMutableArray new];
            for(int i=0;i<word.traumae.length/2;i++) {
                NSString *tempString = [word.traumae substringWithRange:(NSRange){i*2,2}];
                dictTraumaeWord *tempWord = [[dictDataStore sharedDataStore] getWord:tempString];
                [comp addObject:tempWord.english];
            }
            [elements addObject:[NSString stringWithFormat:@"<p>%@</p>",[comp componentsJoinedByString:@"."]]];
        }
        
        if(word.children>0) {
            NSArray *children = [[dictDataStore sharedDataStore] DataforFilter:word.traumae maxLength:(int)word.traumae.length+2];
            NSMutableArray *links = [NSMutableArray new];
            for(dictTraumaeWord* child in children) {
                if(child.traumae.length>word.traumae.length) {
                    [links addObject:[NSString stringWithFormat:@"<li><a href='traumae:%@'>%@ - <span class='childefine'> %@</span></a>",child.traumae,child.traumae,child.english]];
                    
                }
            }
            [elements addObject:[NSString stringWithFormat:@"<div class='header'>Children</div><ul class='childList' >%@</ul>",[links componentsJoinedByString:@" "]]];
        }
        
        [[myWebView mainFrame] loadHTMLString:[htmlTemplate stringByReplacingOccurrencesOfString:@"<*content*>" withString:[elements componentsJoinedByString:@"\n"]]  baseURL:nil];
        
        
        int index=0;
        for(dictTraumaeWord* thisWord in _objects) {
            if ([thisWord.traumae isEqualToString:word.traumae]) {
                [_tableView selectRowIndexes:[NSIndexSet indexSetWithIndex:index] byExtendingSelection:false];
            }
            index++;
            
        }
    }
    else {
        NSString* filePath = [[NSBundle mainBundle] pathForResource:@"core" ofType:@"html"];
        NSURL* fileURL = [NSURL fileURLWithPath:filePath];
        NSURLRequest* request = [NSURLRequest requestWithURL:fileURL];
        [[myWebView mainFrame] loadRequest:request];
    }
}

-(void)saveScrollPosition {
    ;
    if(_filters.count>0 && filterIndex<_filters.count) {
        NSScrollView *scrollView = [[[[myWebView mainFrame] frameView] documentView] enclosingScrollView];
        NSRect scrollViewBounds = [[scrollView contentView] bounds];
        NSPoint scrollPosition = scrollViewBounds.origin;
        NSValue *pointValue =[NSValue valueWithPoint:scrollPosition];
        
        if(scrollPosition.x!=0 || scrollPosition.y!=0) {
            //NSLog([pointValue description]);
        _filters[filterIndex][@"scrollPosition"]= pointValue;
        }
    }
}

-(void)restoreScrollPosition:(NSValue*)pointValue {
    saveScrollPosition = CGPointMake(0, 0);
    if(pointValue) {
        NSScrollView *scrollView = [[[[myWebView mainFrame] frameView] documentView] enclosingScrollView];
        //NSLog([pointValue description]);
        saveScrollPosition =[pointValue pointValue];
        [[scrollView documentView] scrollPoint:[pointValue pointValue]];
    }
}

-(void)loadWord:(dictTraumaeWord*)word {
    
    if(_filters.count!=0 && _filters[filterIndex][@"word"]==word)
        return;
    
    if(_filters.count!=0 && !((dictTraumaeWord*)_filters[filterIndex][@"word"]).valid && !word.valid)
        return;
    
    if(filterIndex+1<_filters.count) {
        [_filters removeObjectsInRange:(NSRange){filterIndex+1,_filters.count-(filterIndex+1)}];
    }
    [self saveScrollPosition];
    if(_filters.count==0 || [_filters lastObject][@"word"]!=word) {
        NSMutableDictionary* tempDict = [NSMutableDictionary new];
        tempDict[@"word"]=word;
        tempDict[@"filter"]=_currentFilter;
        [_filters addObject:tempDict];
        filterIndex = (int)_filters.count-1;
    }
    [self showWord:word];
    [self setButtonStates];
}

-(void)selectItem:(dictTraumaeWord*)object {
    if(!object.valid) {
        [self goHome:self];
        return;
    }
    [self selectWord:object.traumae forced:false];
    
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView {
    if(!_objects)
        _objects = [[dictDataStore sharedDataStore] DataforFilter:Nil maxLength:2];
    return _objects.count;
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    
    NSView *view = [tableView makeViewWithIdentifier:@"dataCell" owner:self];
    dictTraumaeWord *object = _objects[row];
    NSTextField *textField = [view viewWithTag:100];
    [textField setStringValue:[object.traumae capitalizedString]];
    
    textField = [view viewWithTag:200];
    [textField setStringValue:[object.english capitalizedString]];
    
    return view;
    
    
}

- (void)tableViewSelectionDidChange:(NSNotification *)aNotification {
    NSInteger row = [_tableView selectedRow];
    if(row!=-1) {
        dictTraumaeWord *object = _objects[row];
        [self selectItem:object];
    }
}

-(void)selectWord:(NSString*)word forced:(bool)forced {
    if(word) {
        dictTraumaeWord *object = [[dictDataStore sharedDataStore] getWord:word];
        if(!object)
            return;
        if(object.traumae!=_currentFilter) {
            if(object.children==-1 || forced) {
                [self setFilter:object.traumae];
                int index = 0;
                for(dictTraumaeWord* thisWord in _objects) {
                    if ([thisWord.traumae isEqualToString:object.traumae]) {
                        [_tableView selectRowIndexes:[NSIndexSet indexSetWithIndex:index] byExtendingSelection:false];
                    }
                    index++;
                }
            }
        }
        [self loadWord:object];
        
    }
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



- (void)controlTextDidChange:(NSNotification *)aNotification {
    NSSearchField *searchField = [aNotification object];
    NSString* currentString = searchField.stringValue;
    [self setFilter:[NSString stringWithFormat:@"!%@",currentString]];
}

/*- (void)controlTextDidEndEditing:(NSNotification *)aNotification {
    NSSearchField *searchField = [aNotification object];
    NSString* currentString = searchField.stringValue;
    NSLog(@"X%@",currentString);
}*/

@end
