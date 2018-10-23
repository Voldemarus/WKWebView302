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

@interface ViewController () {
	FZWebView *webView;
	WKProcessPool *processPool;
	NSHTTPCookieStorage *sharedStorage;
}
@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UISwitch *modeSwitch;
- (IBAction)modeSwitchChanged:(id)sender;

@end

@implementation ViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	
	processPool = [[WKProcessPool alloc] init];
	sharedStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
	
	AppDelegate *d = (AppDelegate *)[[UIApplication sharedApplication] delegate];
	self.modeSwitch.on = d.useCookies;
	
	webView = [[FZWebView alloc] initAsSubViewFor:self.view withProcessPool:processPool];
	
	[self reloadPageClicked:nil];
}


- (IBAction)reloadPageClicked:(id)sender
{
	NSURL *url = [NSURL URLWithString:TEST_PAGE];
	[webView resetCookis:url];
	NSURLRequestCachePolicy policy = NSURLRequestReloadIgnoringLocalCacheData;
	NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:policy timeoutInterval:TIMEOUT_INTERVAL];
	
	[webView loadRequest:request];
}


- (IBAction)modeSwitchChanged:(id)sender
{
	AppDelegate *d = (AppDelegate *)[[UIApplication sharedApplication] delegate];
	d.useCookies = self.modeSwitch.on;
}

@end
