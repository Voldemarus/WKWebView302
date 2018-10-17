//
//  FZWebView.m
//  WKWebView302
//
//  Created by Водолазкий В.В. on 17/10/2018.
//  Copyright © 2018 Geomatix Laboratory S.R.O. All rights reserved.
//

#import "FZWebView.h"
#import "AppDelegate.h"

@interface FZWebView () <NSURLSessionDelegate>

@end

@implementation FZWebView

- (nullable WKNavigation *)loadRequest:(NSURLRequest *)request
{
	AppDelegate *d = (AppDelegate *)[[UIApplication sharedApplication] delegate];
	if (d.useCookies == NO) {
		// use basic WKWebView loading implementation
		return [super loadRequest:request];
	}
	// Trying to preserve cookies from initial request
	[self requestWithCookieHandling:request success:^(NSURLRequest *newRequest, NSURLResponse *response, NSData *data) {
		NSLog(@"Successfully loaded - %@", request.URL);
		NSLog(@"Successfully Redirected to  - %@", newRequest.URL);
		
		
		dispatch_async(dispatch_get_main_queue(), ^{
//
//			[self syncCookiesInJS: nil];
			if (data != nil && response != nil) {
				[self webViewLoad: data response: response];

			} else {
				[self syncCookiesRequest:newRequest task:nil completion:^(NSURLRequest *cookieRequest) {
					[super loadRequest:cookieRequest];
				}];
			}
		});

		
	} failure:^{
		NSLog(@"failed to load - %@", request.URL);
		dispatch_async(dispatch_get_main_queue(), ^{
			[self syncCookiesRequest:nil task:nil completion:^(NSURLRequest *cookieRequest) {
				[super loadRequest:cookieRequest];
			}];
		});
	}];
	
	return nil;		// should not get here
}

- (void)requestWithCookieHandling:(NSURLRequest *)request
						  success: (nonnull void (^)(NSURLRequest *, NSURLResponse *, NSData *))success
						  failure: (nonnull void (^)(void))failure {
	
	NSURLSessionConfiguration *sessionConfig = NSURLSessionConfiguration.defaultSessionConfiguration;
	NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfig delegate:self delegateQueue:nil];
	NSURLSessionDataTask *task = [session dataTaskWithRequest:request
											completionHandler:^(NSData * _Nullable data,
																NSURLResponse * _Nullable response,
																NSError * _Nullable error) {
		if (error) {
			NSLog(@"Error on data task - %@", [error localizedDescription]);
			failure();
		} else {
			[self printCookies];
			NSLog(@"Headers - %@",[(NSHTTPURLResponse *)response allHeaderFields]);
			NSLog(@"");
			NSInteger code = 200;
			if ([response isKindOfClass:[NSHTTPURLResponse class]]){
				code = ((NSHTTPURLResponse *)response).statusCode;
			}
			NSLog(@"code of page loading - %ld",(long)code);
			if (code == 200) {
				success(request, response, data);
			} else if (code >= 300 && code <  400)  {
				// for redirect get location in header,and make a new URLRequest
				NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
				NSString *location = [httpResponse allHeaderFields][@"Location"];
				if (location == nil) {
					failure();
					return;
				}
				NSURL *redirectURL = [NSURL URLWithString:location];
				if (redirectURL == nil) {
					failure();
					return;
				}
				
				NSURLRequest *_request = [NSURLRequest requestWithURL:redirectURL cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:5];
				
				success(_request, nil, nil);
				
			} else {
				success(request, response, data);
			}
		}
		
	}];
	[task resume];
}

- (void)syncCookiesRequest:(NSURLRequest *)request task:(NSURLSessionTask *)task completion: (nonnull void (^)(NSURLRequest *)) completion {
	
	NSMutableURLRequest * mRequest = [request mutableCopy];
	NSMutableArray <NSHTTPCookie *> *cookiesArray = [NSMutableArray new];
	if (task){
		[[NSHTTPCookieStorage sharedHTTPCookieStorage] getCookiesForTask: task completionHandler:^(NSArray<NSHTTPCookie *> * _Nullable cookies) {
			
			if (cookies) {
				[cookiesArray addObjectsFromArray:cookies];
				
				NSDictionary<NSString *, NSString *> *cookieDict = [NSHTTPCookie requestHeaderFieldsWithCookies:cookiesArray];
				if (cookieDict[@"Cookie"] && [cookieDict[@"Cookie"] isKindOfClass:[NSString class]]){
					[mRequest addValue:@"Cookie" forHTTPHeaderField:(NSString *)cookieDict[@"Cookie"]];
				}
			}
			completion(mRequest);
		}];
	} else if (mRequest.URL) {
		NSURL *url = mRequest.URL;
		NSArray<NSHTTPCookie *> * cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:url];
		if (cookies){
			[cookiesArray addObjectsFromArray:cookies];
		}
		
		NSDictionary<NSString *, NSString *> *cookieDict = [NSHTTPCookie requestHeaderFieldsWithCookies: cookiesArray];
		
		if (cookieDict[@"Cookie"] && [cookieDict[@"Cookie"] isKindOfClass:[NSString class]]){
			[mRequest addValue:@"Cookie" forHTTPHeaderField:(NSString *)cookieDict[@"Cookie"]];
		}
		
		completion(request);
		
	} else {
		NSArray<NSHTTPCookie *> * cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies];
		
		if (cookies){
			[cookiesArray addObjectsFromArray:cookies];
		}
		NSDictionary<NSString *, NSString *> *cookieDict = [NSHTTPCookie requestHeaderFieldsWithCookies: cookiesArray];
		
		if (cookieDict[@"Cookie"] && [cookieDict[@"Cookie"] isKindOfClass:[NSString class]]){
			[mRequest addValue:@"Cookie" forHTTPHeaderField:(NSString *)cookieDict[@"Cookie"]];
		}
		
		completion(request);
	}
}

- (nullable WKNavigation *)webViewLoad:(NSData *)data response:(NSURLResponse *)response {
	NSLog(@"WebView loaded: response.URL - %@",response.URL);
	if (response.URL == nil) {
		return nil;
	}
	
	NSString *encode = [response textEncodingName];
	if (encode == nil) encode = @"utf8";
	NSString *mine = [response MIMEType];
	if (mine == nil) mine = @"text/html";
	
	return [self loadData:data MIMEType:mine characterEncodingName:encode baseURL:response.URL];
}


#pragma mark - Auxillary methods

- (void) resetCookis:(NSURL *)url
{
	NSString *urlPath = url.absoluteString;
	if (!urlPath) {
		return;
	}
	NSArray<NSHTTPCookie *> * cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies];
	NSInteger initialCount = cookies.count;
	if (cookies && cookies.count > 0) {
		for (NSHTTPCookie *cookie in cookies) {
			NSLog(@">> %@  %@::  %@ -> %@",cookie.domain, (cookie.sessionOnly ? @"+TMP+" : @""),
				  cookie.name, cookie.value);
			if ([urlPath rangeOfString:cookie.domain].location != NSNotFound) {
				// delete this cookie
				[[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:cookie];
			}
		}
		NSInteger finalCount = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies].count;
		if (finalCount < initialCount) {
			NSLog(@">>> Cookies deleted - %ld . Remained - %ld",
				  (long) initialCount - finalCount, (long) finalCount);
		}
	}
}

- (void) printCookies
{
	NSLog(@"!!!");
	NSArray<NSHTTPCookie *> * cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies];
	if (cookies && cookies.count > 0) {
		for (NSHTTPCookie *cookie in cookies) {
			NSLog(@"!!! %@  %@::  %@ -> %@",cookie.domain, (cookie.sessionOnly ? @"+TMP+" : @""),
				  cookie.name, cookie.value);
		}
	}
	NSLog(@"!!!");

}


@end
