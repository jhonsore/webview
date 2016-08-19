//
//  ViewController.m
//  Webview
//
//  Created by iOS on 17/08/16.
//  Copyright © 2016 iOS. All rights reserved.

//for uiwebview/wkwebview implementation
//https://gowithfloat.com/2014/12/one-webview-to-rule-them-all/

//for js comunication
//http://ramkulkarni.com/blog/framework-for-interacting-with-embedded-webview-in-ios-application/

#import "ViewController.h"
// Required for calls to UIWebView and WKWebView to "see" our categories
#import "UIWebView+FLUIWebView.h"
#import "WKWebView+FLWKWebView.h"

@interface ViewController ()

@end

@implementation ViewController

/*
 * Called when the view has completed loading. Time to set up our WebView!
 */
- (void) viewDidLoad {
    [super viewDidLoad];
    
    // Check if WKWebView is available
    // If it is present, create a WKWebView. If not, create a UIWebView.
    if (NSClassFromString(@"WKWebView")) {
        _webView = [[WKWebView alloc] initWithFrame: [[self view] bounds]];
    } else {
        _webView = [[UIWebView alloc] initWithFrame: [[self view] bounds]];
    }
    
    [[self webView] preventFromBounce];
    
    // Add the webView to the current view.
    [[self view] addSubview: [self webView]];
    
    // Assign this view controller as the delegate view.
    // The delegate methods are below, and include methods for UIWebViewDelegate, WKNavigationDelegate, and WKUIDelegate
    [[self webView] setDelegateViews: self];
    
    // Ensure that everything will resize on device rotate.
    [[self webView] setAutoresizingMask: UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
    [[self view]    setAutoresizingMask: UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
    
    // Just to show *something* on load, we go to our favorite site.
    //[[self webView] loadRequestFromString:@"http://www.google.com/"];
    NSURL *url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"index" ofType:@"html" inDirectory:@"webapp"]];
    [[self webView] loadRequest:[NSURLRequest requestWithURL:url]];
}

/*
 * Enable rotating the view when the device rotates.
 */
- (BOOL) shouldAutorotateToInterfaceOrientation: (UIInterfaceOrientation) toInterfaceOrientation
{
    return YES;
}

/*
 * This more or less ensures that the status bar is hidden for this view.
 * We also set UIStatusBarHidden to true in the Info.plist file.
 * We hide the status bar so we can use the full screen height without worrying about an offset for the status bar.
 */
- (BOOL) prefersStatusBarHidden
{
    return NO;
}

#pragma mark - js call

- (BOOL) processURL:(NSString *) url
{
    NSString *urlStr = [NSString stringWithString:url];
    
    NSString *protocolPrefix = @"js2ios://";
    if ([[urlStr lowercaseString] hasPrefix:protocolPrefix])
    {
        urlStr = [urlStr substringFromIndex:protocolPrefix.length];
        
        urlStr = [urlStr stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        
        NSError *jsonError;
        
        NSDictionary *callInfo = [NSJSONSerialization
                                  JSONObjectWithData:[urlStr dataUsingEncoding:NSUTF8StringEncoding]
                                  options:kNilOptions
                                  error:&jsonError];
        
        if (jsonError != nil)
        {
            //call error callback function here
            NSLog(@"Error parsing JSON for the url %@",url);
            return NO;
        }
        
        
        NSString *functionName = [callInfo objectForKey:@"functionname"];
        if (functionName == nil)
        {
            NSLog(@"Missing function name");
            return NO;
        }
        
        NSString *successCallback = [callInfo objectForKey:@"success"];
        NSString *errorCallback = [callInfo objectForKey:@"error"];
        NSArray *argsArray = [callInfo objectForKey:@"args"];
        
        
        [self callFunction:functionName withArgs:argsArray onSuccess:successCallback onError:errorCallback];
        
        return NO;
        
    }
    
    return YES;
}

- (void) callFunction:(NSString *) name withArgs:(NSArray *) args onSuccess:(NSString *) successCallback onError:(NSString *) errorCallback
{
    NSError *error;
    
    id retVal = [self processFunctionFromJS:name withArgs:args error:&error];
    
    if (error != nil)
    {
        NSString *resultStr = [NSString stringWithString:error.localizedDescription];
        [self callErrorCallback:errorCallback withMessage:resultStr];
        return;
    }
    
    [self callSuccessCallback:successCallback withRetValue:retVal forFunction:name];
    
}

-(void) callErrorCallback:(NSString *) name withMessage:(NSString *) msg
{
    if (name != nil)
    {
        //call error handler
        
        [[self webView] evaluateJavaScript:[NSString stringWithFormat:@"%@('%@');",name,msg] completionHandler:nil];
        
    }
    else
    {
        NSLog(@"%@",msg);
    }
    
}

-(void) callSuccessCallback:(NSString *) name withRetValue:(id) retValue forFunction:(NSString *) funcName
{
    if (name != nil)
    {
        retValue = (retValue) ? retValue : [NSMutableDictionary dictionary];
        
        NSMutableDictionary *resultDict = [NSMutableDictionary dictionary];
        [resultDict setObject:retValue forKey:@"result"];
        [self callJSFunction:name withArgs:resultDict];
        
    }
    else
    {
        NSLog(@"Result of function %@ = %@", funcName,retValue);
    }
    
}

-(void) callJSFunction:(NSString *) name withArgs:(NSMutableDictionary *) args
{
    NSError *jsonError;
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:args options:0 error:&jsonError];
    
    if (jsonError != nil)
    {
        //call error callback function here
        NSLog(@"Error creating JSON from the response  : %@",[jsonError localizedDescription]);
        return;
    }
    
    NSString *jsonStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    //NSLog(@"jsonStr = %@", jsonStr);
    
    if (jsonStr == nil)
    {
        NSLog(@"jsonStr is null. count = %lu", (unsigned long)[args count]);
    }
    
    [[self webView] evaluateJavaScript:[NSString stringWithFormat:@"%@('%@');",name,jsonStr] completionHandler:nil];
    
}

- (void) createError:(NSError**) error withMessage:(NSString *) msg
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setValue:msg forKey:NSLocalizedDescriptionKey];
    
    *error = [NSError errorWithDomain:@"JSiOSBridgeError" code:-1 userInfo:dict];
    
}

-(void) createError:(NSError**) error withCode:(int) code withMessage:(NSString*) msg
{
    NSMutableDictionary *msgDict = [NSMutableDictionary dictionary];
    [msgDict setValue:[NSNumber numberWithInt:code] forKey:@"code"];
    [msgDict setValue:msg forKey:@"message"];
    
    NSError *jsonError;
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:msgDict options:0 error:&jsonError];
    
    if (jsonError != nil)
    {
        //call error callback function here
        NSLog(@"Error creating JSON from error message  : %@",[jsonError localizedDescription]);
        return;
    }
    
    NSString *jsonStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    
    [self createError:error withMessage:jsonStr];
}

- (id) processFunctionFromJS:(NSString *) name withArgs:(NSArray*) args error:(NSError **) error
{
    if ([name compare:@"initApp" options:NSCaseInsensitiveSearch] == NSOrderedSame)
    {
        NSArray *listElements = @[@"Item 1", @"Item 2"];
        
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:listElements options:0 error:nil];
        
        NSString *result = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        
        return result;
    }
    
    return nil;
}

#pragma mark - UIWebView Delegate Methods

/*
 * Called on iOS devices that do not have WKWebView when the UIWebView requests to start loading a URL request.
 * Note that it just calls shouldStartDecidePolicy, which is a shared delegate method.
 * Returning YES here would allow the request to complete, returning NO would stop it.
 */
- (BOOL) webView: (UIWebView *) webView shouldStartLoadWithRequest: (NSURLRequest *) request navigationType: (UIWebViewNavigationType) navigationType
{
    return [self shouldStartDecidePolicy: request];
}

/*
 * Called on iOS devices that do not have WKWebView when the UIWebView starts loading a URL request.
 * Note that it just calls didStartNavigation, which is a shared delegate method.
 */
- (void) webViewDidStartLoad: (UIWebView *) webView
{
    [self didStartNavigation];
}

/*
 * Called on iOS devices that do not have WKWebView when a URL request load failed.
 * Note that it just calls failLoadOrNavigation, which is a shared delegate method.
 */
- (void) webView: (UIWebView *) webView didFailLoadWithError: (NSError *) error
{
    [self failLoadOrNavigation: [webView request] withError: error];
}

/*
 * Called on iOS devices that do not have WKWebView when the UIWebView finishes loading a URL request.
 * Note that it just calls finishLoadOrNavigation, which is a shared delegate method.
 */
- (void) webViewDidFinishLoad: (UIWebView *) webView
{
    [self finishLoadOrNavigation: [webView request]];
}

#pragma mark - WKWebView Delegate Methods

/*
 * Called on iOS devices that have WKWebView when the web view wants to start navigation.
 * Note that it calls shouldStartDecidePolicy, which is a shared delegate method,
 * but it's essentially passing the result of that method into decisionHandler, which is a block.
 */
- (void) webView: (WKWebView *) webView decidePolicyForNavigationAction: (WKNavigationAction *) navigationAction decisionHandler: (void (^)(WKNavigationActionPolicy)) decisionHandler
{
    decisionHandler([self shouldStartDecidePolicy: [navigationAction request]]);
}

/*
 * Called on iOS devices that have WKWebView when the web view starts loading a URL request.
 * Note that it just calls didStartNavigation, which is a shared delegate method.
 */
- (void) webView: (WKWebView *) webView didStartProvisionalNavigation: (WKNavigation *) navigation
{
    [self didStartNavigation];
}

/*
 * Called on iOS devices that have WKWebView when the web view fails to load a URL request.
 * Note that it just calls failLoadOrNavigation, which is a shared delegate method,
 * but it has to retrieve the active request from the web view as WKNavigation doesn't contain a reference to it.
 */
- (void) webView:(WKWebView *) webView didFailProvisionalNavigation: (WKNavigation *) navigation withError: (NSError *) error
{
    [self failLoadOrNavigation: [webView request] withError: error];
}

/*
 * Called on iOS devices that have WKWebView when the web view begins loading a URL request.
 * This could call some sort of shared delegate method, but is unused currently.
 */
- (void) webView: (WKWebView *) webView didCommitNavigation: (WKNavigation *) navigation
{
    // do nothing
}

/*
 * Called on iOS devices that have WKWebView when the web view fails to load a URL request.
 * Note that it just calls failLoadOrNavigation, which is a shared delegate method.
 */
- (void) webView: (WKWebView *) webView didFailNavigation: (WKNavigation *) navigation withError: (NSError *) error
{
    [self failLoadOrNavigation: [webView request] withError: error];
}

/*
 * Called on iOS devices that have WKWebView when the web view finishes loading a URL request.
 * Note that it just calls finishLoadOrNavigation, which is a shared delegate method.
 */
- (void) webView: (WKWebView *) webView didFinishNavigation: (WKNavigation *) navigation
{
    [self finishLoadOrNavigation: [webView request]];
}

#pragma mark - Shared Delegate Methods

/*
 * This is called whenever the web view wants to navigate.
 */
- (BOOL) shouldStartDecidePolicy: (NSURLRequest *) request
{
    // Determine whether or not navigation should be allowed.
    // Return YES if it should, NO if not.
    
    NSURL *url = [request URL];
    NSString *urlStr = url.absoluteString;
    
    return [self processURL:urlStr];
}

/*
 * This is called whenever the web view has started navigating.
 */
- (void) didStartNavigation
{
    // Update things like loading indicators here.
}

/*
 * This is called when navigation failed.
 */
- (void) failLoadOrNavigation: (NSURLRequest *) request withError: (NSError *) error
{
    // Notify the user that navigation failed, provide information on the error, and so on.
    NSLog(@"%@",error);
}

/*
 * This is called when navigation succeeds and is complete.
 */
- (void) finishLoadOrNavigation: (NSURLRequest *) request
{
    // Remove the loading indicator, maybe update the navigation bar's title if you have one.
    
    NSMutableDictionary *dic = [NSMutableDictionary
                                dictionaryWithDictionary:@{
                                                           @"item" : @"some value"
                                                           }];
    
    [self callJSFunction:@"callJS" withArgs:dic];
    
}

@end

