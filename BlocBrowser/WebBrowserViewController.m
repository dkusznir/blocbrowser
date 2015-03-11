//
//  WebBrowserViewController.m
//  BlocBrowser
//
//  Created by Dorian Kusznir on 3/8/15.
//  Copyright (c) 2015 Bloc. All rights reserved.
//

#import "WebBrowserViewController.h"
#import "AwesomeFloatingToolbar.h"

#define kWebBrowserBackString NSLocalizedString(@"Back", @"Back Command")
#define kWebBrowserForwardString NSLocalizedString(@"Forward", @"Forward Command")
#define kWebBrowserStopString NSLocalizedString(@"Stop", @"Stop Command")
#define kWebBrowserRefreshString NSLocalizedString(@"Refresh", @"Refresh Command")

#define IS_IPAD (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#define IS_IPHONE (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
#define IS_RETINA ([[UIScreen mainScreen] scale] >= 2.0)

#define SCREEN_WIDTH ([[UIScreen mainScreen] bounds].size.width)
#define SCREEN_HEIGHT ([[UIScreen mainScreen] bounds].size.height)
#define SCREEN_MAX_LENGTH (MAX(SCREEN_WIDTH, SCREEN_HEIGHT))
#define SCREEN_MIN_LENGTH (MIN(SCREEN_WIDTH, SCREEN_HEIGHT))

#define IS_IPHONE_4_OR_LESS (IS_IPHONE && SCREEN_MAX_LENGTH < 568.0)
#define IS_IPHONE_5 (IS_IPHONE && SCREEN_MAX_LENGTH == 568.0)
#define IS_IPHONE_6 (IS_IPHONE && SCREEN_MAX_LENGTH == 667.0)
#define IS_IPHONE_6P (IS_IPHONE && SCREEN_MAX_LENGTH == 736.0)

#define LANDSCAPE (UIDeviceOrientationIsLandscape([UIDevice currentDevice].orientation))
#define PORTRAIT (UIDeviceOrientationIsPortrait([UIDevice currentDevice].orientation))

@interface WebBrowserViewController () <UIWebViewDelegate, UITextFieldDelegate, AwesomeFloatingToolbarDelegate>

@property (nonatomic, strong) UIWebView *webview;
@property (nonatomic, strong) UITextField *textField;
@property (nonatomic, assign) NSUInteger frameCount;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;
@property (nonatomic, strong) AwesomeFloatingToolbar *awesomeToolBar;

@end

@implementation WebBrowserViewController

#pragma mark - UIViewController

- (void) loadView
{
    UIView *mainView = [UIView new];
    
    self.webview = [[UIWebView alloc] init];
    self.webview.delegate = self;
    
    self.textField = [[UITextField alloc] init];
    self.textField.keyboardType = UIKeyboardTypeURL;
    self.textField.returnKeyType = UIReturnKeyDone;
    self.textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.textField.autocorrectionType = UITextAutocorrectionTypeNo;
    self.textField.placeholder = NSLocalizedString(@"Search Google or type URL", @"Placeholder text for web browser URL field");
    self.textField.backgroundColor = [UIColor colorWithWhite:220/225.0f alpha:1];
    self.textField.delegate = self;
    
    self.awesomeToolBar = [[AwesomeFloatingToolbar alloc] initWithFourTitles:@[kWebBrowserBackString, kWebBrowserForwardString, kWebBrowserStopString, kWebBrowserRefreshString]];
    
    self.awesomeToolBar.delegate = self;
    
    for (UIView *viewToAdd in @[self.webview, self.textField, self.awesomeToolBar])
    {
        [mainView addSubview:viewToAdd];
    }
    
    self.view = mainView;
}

- (void) viewDidLoad
{
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.activityIndicator];
    
}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return ( UIInterfaceOrientationMaskAll);
}

- (void) viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    //Calculate dimensions:
    static const CGFloat itemHeight = 50;
    CGFloat width = CGRectGetWidth(self.view.bounds);
    CGFloat browserHeight = CGRectGetHeight(self.view.bounds) - itemHeight;
    
    //Assign the frames:
    self.textField.frame = CGRectMake(0, 0, width, itemHeight);
    self.webview.frame = CGRectMake(0, CGRectGetMaxY(self.textField.frame), width, browserHeight);
    
    if (IS_IPHONE_6)
    {
        if (PORTRAIT)
        {
            self.awesomeToolBar.frame = CGRectMake(47.5, 100, 280, 60);
        }
        
        else if (LANDSCAPE)
        {
            self.awesomeToolBar.frame = CGRectMake(193.5, 100, 280, 60);
        }
    }
    
    else if (IS_IPHONE_6P)
    {
        if (PORTRAIT)
        {
            self.awesomeToolBar.frame = CGRectMake(67, 100, 280, 60);
        }
        
        else if (LANDSCAPE)
        {
            self.awesomeToolBar.frame = CGRectMake(228, 100, 280, 60);
        }
    }
    
    else if (IS_IPHONE_5)
    {
        if (PORTRAIT)
        {
            self.awesomeToolBar.frame = CGRectMake(20, 100, 280, 60);
        }
        
        else if (LANDSCAPE)
        {
            self.awesomeToolBar.frame = CGRectMake(144, 100, 280, 60);
        }
    }
    
    else if (IS_IPHONE_4_OR_LESS)
    {
        if (PORTRAIT)
        {
            self.awesomeToolBar.frame = CGRectMake(20, 100, 280, 60);
        }
        
        else if (LANDSCAPE)
        {
            self.awesomeToolBar.frame = CGRectMake(100, 100, 280, 60);
        }
    }
    
    else if (IS_RETINA)
    {
        if (PORTRAIT)
        {
            self.awesomeToolBar.frame = CGRectMake(174, 100, 420, 80);
        }
        
        else if (LANDSCAPE)
        {
            self.awesomeToolBar.frame = CGRectMake(302, 100, 420, 80);
        }
    }
    
    else if (IS_IPAD)
    {
        if (PORTRAIT)
        {
            self.awesomeToolBar.frame = CGRectMake(174, 100, 420, 80);
        }
        
        else if (LANDSCAPE)
        {
            self.awesomeToolBar.frame = CGRectMake(302, 100, 420, 80);
        }
    }

}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    NSString *userInput = textField.text;
    
    NSURL *URL = [NSURL URLWithString:userInput];
    
    if ([userInput containsString:@" "])
    {
        NSString *newURLString = [userInput stringByReplacingOccurrencesOfString:@" " withString:@"+"];
        URL = [NSURL URLWithString:[NSString stringWithFormat:@"http://www.google.com/search?q=%@", newURLString]];
        NSURLRequest *googleRequest = [NSURLRequest requestWithURL:URL];
        [self.webview loadRequest:googleRequest];
    }
    
    else
    {
        if (!URL.scheme)
        {
            URL = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@", userInput]];
        }
        
        if (URL)
        {
            NSURLRequest *request = [NSURLRequest requestWithURL:URL];
            [self.webview loadRequest:request];
        }
    }

    return NO;
}

#pragma mark - UIWebViewDelegate

- (void) webViewDidStartLoad:(UIWebView *)webView
{
    self.frameCount++;
    [self updateButtonsAndTitle];
}

- (void) webViewDidFinishLoad:(UIWebView *)webView
{
    self.frameCount--;
    [self updateButtonsAndTitle];
}

- (void) webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    if (error.code != -999)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"Error")
                                                        message:[error localizedDescription]
                                                       delegate:nil
                                              cancelButtonTitle:NSLocalizedString(@"OK", nil)
                                              otherButtonTitles:nil];
    
    [alert show];
    }
    
    [self updateButtonsAndTitle];
    self.frameCount--;
}

#pragma mark - Miscellaneous

- (void) updateButtonsAndTitle
{
    NSString *webpageTitle = [self.webview stringByEvaluatingJavaScriptFromString:@"document.title"];
    
    if (webpageTitle)
    {
        self.title = webpageTitle;
    }
    
    else
    {
        self.title = self.webview.request.URL.absoluteString;
    }
    
    if (self.frameCount > 0)
    {
        [self.activityIndicator startAnimating];
    }
    
    else
    {
        [self.activityIndicator stopAnimating];
    }
    
    [self.awesomeToolBar setEnabled:[self.webview canGoBack] forButtonWithTitle:kWebBrowserBackString];
    [self.awesomeToolBar setEnabled:[self.webview canGoForward] forButtonWithTitle:kWebBrowserForwardString];
    [self.awesomeToolBar setEnabled:self.frameCount > 0 forButtonWithTitle:kWebBrowserStopString];
    [self.awesomeToolBar setEnabled:self.webview.request.URL && self.frameCount == 0 forButtonWithTitle:kWebBrowserRefreshString];

    
}

- (void) resetWebView
{
    [self.webview removeFromSuperview];
    
    UIWebView *newWebView = [[UIWebView alloc] init];
    newWebView.delegate = self;
    [self.view addSubview:newWebView];
    
    self.webview = newWebView;
    
    self.textField.text = nil;
    [self updateButtonsAndTitle];
    
}

#pragma mark - AwesomeFloatingToolBarDelegate

- (void) floatingToolBar:(AwesomeFloatingToolbar *)toolbar didSelectButtonWithTitle:(NSString *)title
{
    if ([title isEqual:kWebBrowserBackString])
    {
        [self.webview goBack];
    }
    
    else if ([title isEqual:kWebBrowserForwardString])
    {
        [self.webview goForward];
    }
    
    else if ([title isEqual:kWebBrowserStopString])
    {
        [self.webview stopLoading];
    }
    
    else if ([title isEqual:kWebBrowserRefreshString])
    {
        [self.webview reload];
    }
}

- (void) didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
