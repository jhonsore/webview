## How To Use iOS WKWebView with UIWebView Fallback + Framework for interacting with embedded WebView in iOS application

*tip

When dragging & drop a folder to be used in file path:

NSURL *url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"index" ofType:@"html" inDirectory:@"webapp"]];
    [[self webView] loadRequest:[NSURLRequest requestWithURL:url]];

On "choose options for adding files", check in "create folder reference" checkbox






