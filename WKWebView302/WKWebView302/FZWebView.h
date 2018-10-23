//
//  FZWebView.h
//  WKWebView302
//
//  Created by Водолазкий В.В. on 17/10/2018.
//  Copyright © 2018 Geomatix Laboratory S.R.O. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface FZWebView : WKWebView

- (instancetype) initAsSubViewFor:(UIView *)parentView withProcessPool:(WKProcessPool *) processPool;


- (void) loadURL:(NSURL *)url;

// overriden method
- (nullable WKNavigation *)loadRequest:(NSURLRequest *)request;

// delete cookies for given URL
- (void) resetCookis:(NSURL *)url;

@end

NS_ASSUME_NONNULL_END
