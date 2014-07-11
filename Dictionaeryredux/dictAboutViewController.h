//
//  dictAboutViewController.h
//  Dictionaeryredux
//
//  Created by Patrick Winchell on 7/11/14.
//  Copyright (c) 2014 Patrick Winchell. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface dictAboutViewController : UIViewController <UIWebViewDelegate>

-(IBAction)close:(id)sender;

@property IBOutlet UIWebView *webView;



@end
