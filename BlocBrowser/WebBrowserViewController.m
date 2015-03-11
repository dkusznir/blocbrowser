//
//  WebBrowserViewController.m
//  BlocBrowser
//
//  Created by Dorian Kusznir on 3/8/15.
//  Copyright (c) 2015 Bloc. All rights reserved.
//

#import "WebBrowserViewController.h"

@interface WebBrowserViewController () <UIWebViewDelegate, UITextFieldDelegate>

@property (nonatomic, strong) UIWebView *webview;
@property (nonatomic, strong) UITextField *textField;
@property (nonatomic, strong) UIButton *backButton;
@property (nonatomic, strong) UIButton *forwardButton;
@property (nonatomic, strong) UIButton *stopButton;
@property (nonatomic, strong) UIButton *reloadButton;
@property (nonatomic, assign) NSUInteger frameCount;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;

@end

@implementation WebBrowserViewController

#pragma mark - UIViewController

- (void) loadView
{
    UIView *mainView = [UIView new];
    
    self.webview = [[UIWebView alloc] init];
    self.webview.delegate = self;
    
    //testing something
    
    self.textField = [[UITextField alloc] init];
    self.textField.keyboardType = UIKeyboardTypeURL;
    self.textField.returnKeyType = UIReturnKeyDone;
    self.textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.textField.autocorrectionType = UITextAutocorrectionTypeNo;
    self.textField.placeholder = NSLocalizedString(@"Search Google or type URL", @"Placeholder text for web browser URL field");
    self.textField.backgroundColor = [UIColor colorWithWhite:220/225.0f alpha:1];
    self.textField.delegate = self;
    
    self.backButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.backButton setEnabled:NO];
    
    self.forwardButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.forwardButton setEnabled:NO];
    
    self.stopButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.stopButton setEnabled:NO];
    
    self.reloadButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.reloadButton setEnabled:NO];
    
    [self.backButton setTitle:NSLocalizedString(@"Back", @"Back command") forState:UIControlStateNormal];
    [self.forwardButton setTitle:NSLocalizedString(@"Forward", @"Forward command") forState:UIControlStateNormal];
    [self.stopButton setTitle:NSLocalizedString(@"Stop", @"Stop command") forState:UIControlStateNormal];
    [self.reloadButton setTitle:NSLocalizedString(@"Reload", @"Reload command") forState:UIControlStateNormal];
    
    [self addButtonTargets];
    
    for (UIView *viewToAdd in @[self.webview, self.textField, self.backButton, self.forwardButton, self.stopButton, self.reloadButton])
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

- (void) viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    //Calculate dimensions:
    static const CGFloat itemHeight = 50;
    CGFloat width = CGRectGetWidth(self.view.bounds);
    CGFloat browserHeight = CGRectGetHeight(self.view.bounds) - itemHeight - itemHeight;
    CGFloat buttonWidth = CGRectGetWidth(self.view.bounds) / 4;
    
    //Assign the frames:
    self.textField.frame = CGRectMake(0, 0, width, itemHeight);
    self.webview.frame = CGRectMake(0, CGRectGetMaxY(self.textField.frame), width, browserHeight);
    
    //Add loop to handle positioning of each button:
    CGFloat currentButtonX = 0;
    
    for (UIButton *thisButton in @[self.backButton, self.forwardButton, self.stopButton, self.reloadButton])
    {
        thisButton.frame = CGRectMake(currentButtonX, CGRectGetMaxY(self.webview.frame), buttonWidth, itemHeight);
        currentButtonX += buttonWidth;
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
    
    self.backButton.enabled = [self.webview canGoBack];
    self.forwardButton.enabled = [self.webview canGoForward];
    self.stopButton.enabled = self.frameCount > 0;
    self.reloadButton.enabled = self.webview.request.URL && self.frameCount == 0;
    
}

- (void) resetWebView
{
    [self.webview removeFromSuperview];
    
    UIWebView *newWebView = [[UIWebView alloc] init];
    newWebView.delegate = self;
    [self.view addSubview:newWebView];
    
    self.webview = newWebView;
    
    [self addButtonTargets];
    
    self.textField.text = nil;
    [self updateButtonsAndTitle];
    
}

- (void) addButtonTargets
{
    for (UIButton *button in @[self.backButton, self.forwardButton, self.stopButton, self.reloadButton])
    {
        [button removeTarget:nil action:NULL forControlEvents:UIControlEventTouchUpInside];
    }
    
    [self.backButton addTarget:self.webview action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
    [self.forwardButton addTarget:self.webview action:@selector(goForward) forControlEvents:UIControlEventTouchUpInside];
    [self.stopButton addTarget:self.webview action:@selector(stopLoading) forControlEvents:UIControlEventTouchUpInside];
    [self.reloadButton addTarget:self.webview action:@selector(reload) forControlEvents:UIControlEventTouchUpInside];
    
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
