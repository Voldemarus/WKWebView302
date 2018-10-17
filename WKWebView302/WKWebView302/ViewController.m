//
//  ViewController.m
//  WKWebView302
//
//  Created by Водолазкий В.В. on 17/10/2018.
//  Copyright © 2018 Geomatix Laboratory S.R.O. All rights reserved.
//

#import "ViewController.h"
#import "Definitions.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet FZWebView *webView;

@end

@implementation ViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	
	NSURL *url = [NSURL URLWithString:TEST_PAGE];
	NSURLRequestCachePolicy policy = NSURLRequestReloadIgnoringLocalCacheData;
	NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:policy timeoutInterval:TIMEOUT_INTERVAL];
	
	[self.webView loadRequest:request];
	
}


@end
