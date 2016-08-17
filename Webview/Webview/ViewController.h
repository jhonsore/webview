//
//  ViewController.h
//  Webview
//
//  Created by iOS on 17/08/16.
//  Copyright © 2016 iOS. All rights reserved.
//

// Needed for UIViewController, UIWebViewDelegate, and UIView
#import <UIKit/UIKit.h>
// Needed for WKNavigationDelegate and WKUIDelegate
#import <WebKit/WebKit.h>
// Used to define the webView property below
#import "FLWebViewProvider.h"

/**
 * This is the view controller for the main interface.
 * It also acts as a delegate for the web view.
 */
@interface ViewController : UIViewController <UIWebViewDelegate, WKNavigationDelegate, WKUIDelegate>

// The main web view that is set up in the viewDidLoad method.
@property (nonatomic) UIView <FLWebViewProvider> *webView;

@end

