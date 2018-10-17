//
//  ViewController.m
//  WKWebView302
//
//  Created by Водолазкий В.В. on 17/10/2018.
//  Copyright © 2018 Geomatix Laboratory S.R.O. All rights reserved.
//

#import "ViewController.h"
#import "Definitions.h"
#import "AppDelegate.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet FZWebView *webView;
@property (weak, nonatomic) IBOutlet UISwitch *modeSwitch;
- (IBAction)modeSwitchChanged:(id)sender;

@end

@implementation ViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	
	AppDelegate *d = (AppDelegate *)[[UIApplication sharedApplication] delegate];
	self.modeSwitch.on = d.useCookies;
	
	[self reloadPageClicked:nil];
}


- (IBAction)reloadPageClicked:(id)sender
{
	NSURL *url = [NSURL URLWithString:TEST_PAGE];
	[self.webView resetCookis:url];
	NSURLRequestCachePolicy policy = NSURLRequestReloadIgnoringLocalCacheData;
	NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:policy timeoutInterval:TIMEOUT_INTERVAL];
	
	[self.webView loadRequest:request];
}


- (IBAction)modeSwitchChanged:(id)sender
{
	AppDelegate *d = (AppDelegate *)[[UIApplication sharedApplication] delegate];
	d.useCookies = self.modeSwitch.on;
}

@end
