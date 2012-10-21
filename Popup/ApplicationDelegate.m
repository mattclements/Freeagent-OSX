#import "ApplicationDelegate.h"
#import "URLParser.h"
#import "NSString+Base64.h"

static NSString* const apiURL = @"https://api.sandbox.freeagent.com/v2";
static NSString* const apiType = @"freeagentService";
static NSString* const apiKey = @"rXgDnfe4r9CYAOJ8QADjdA";
static NSString* const apiSecret = @"FBUao5_jf74vh5LKn9I-kQ";

@implementation ApplicationDelegate

@synthesize panelController = _panelController;
@synthesize menubarController = _menubarController;
@synthesize requestToken;
@synthesize showAuth;

#pragma mark -

- (void)dealloc
{
    [_panelController removeObserver:self forKeyPath:@"hasActivePanel"];
}

#pragma mark -

void *kContextActivePanel = &kContextActivePanel;

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context == kContextActivePanel) {
        self.menubarController.hasActiveIcon = self.panelController.hasActivePanel;
    }
    else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

+ (void)initialize
{
    /**
     *  redirectURL is nil as this is a Desktop Application
     *  forAccountType is required by Spec, but ignored by Freeagent
     */
    
    NSLog(@"%@/approve_app?client_id=%@&response_type=code",apiURL,apiKey);
    
    
    //[[NSWorkspace sharedWorkspace] openURL:url];
    
    ApplicationDelegate *appDelegate = [[ApplicationDelegate alloc] init];
    [appDelegate showAuthScreen];
    
    
}

- (void)showAuthScreen {
    NSLog(@"Showing Auth Screen");
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/approve_app?client_id=%@&response_type=code",apiURL,apiKey]];
    
    showAuth = [[ShowAuth alloc] init];
    [showAuth loadWindow];
    [showAuth showWindow:[showAuth window]];
    [showAuth loadWebPage:url];
}

- (void)startAuthorisation:(NSString *) code {
    
    OAConsumer *consumer = [[OAConsumer alloc] initWithKey:apiKey
                                                    secret:apiSecret];
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/token_endpoint",apiURL]];
    
    OAToken * token = [[OAToken alloc] initWithKey:apiKey secret:apiSecret];
    
    OAMutableURLRequest *request = [[OAMutableURLRequest alloc] initWithURL:url
                                                                   consumer:nil
                                                                      token:nil   // we don't have a Token yet
                                                                      realm:apiType
                                                          signatureProvider:nil]; // use the default method, HMAC-SHA
    
    [request prepare];
    [request setHTTPMethod:@"POST"];
    
    NSString *requestString = [NSString stringWithFormat:@"grant_type=authorization_code&code=%@",code];
    
    NSData *postData = [NSData dataWithBytes:[requestString UTF8String] length:[requestString lengthOfBytesUsingEncoding:NSUTF8StringEncoding]];
    
    [request setHTTPBody:postData];
    [request setValue:[NSString stringWithFormat:@"%ld", [postData length]] forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setValue:[NSString stringWithFormat:@"Basic %@",[[NSString stringWithFormat:@"%@:%@",apiKey,apiSecret] base64EncodedString]] forHTTPHeaderField:@"Authorization"];
    
    OADataFetcher *fetcher = [[OADataFetcher alloc] init];
    
    NSLog(@"%@",request.allHTTPHeaderFields);
    
    [fetcher fetchDataWithRequest:request
                         delegate:self
                didFinishSelector:@selector(requestTokenTicket:didFinishWithData:)
                  didFailSelector:@selector(requestTokenTicket:didFailWithError:)];
}

- (void)requestTokenTicket:(OAServiceTicket *)ticket didFinishWithData:(NSData *)data {
    if (ticket.didSucceed) {
        NSString *responseBody = [[NSString alloc] initWithData:data
                                                       encoding:NSUTF8StringEncoding];
        requestToken = [[OAToken alloc] initWithHTTPResponseBody:responseBody];
        
        NSLog(@"Registered Token");
    }
NSLog(@"Succeeded: %@",[[NSString alloc] initWithData:data
                                              encoding:NSUTF8StringEncoding]);
}

- (void)requestTokenTicket:(OAServiceTicket *)ticket didFailWithError:(NSError *)error {
    NSLog(@"Failed with Error: %@",error.description);
}

#pragma mark - NSApplicationDelegate

- (void)applicationWillFinishLaunching:(NSNotification *)notification
{
    [[NSAppleEventManager sharedAppleEventManager] setEventHandler:self andSelector:@selector(handleAppleEvent:withReplyEvent:) forEventClass:kInternetEventClass andEventID:kAEGetURL];
}

- (void)applicationDidFinishLaunching:(NSNotification *)notification
{
    // Install icon into the menu bar
    self.menubarController = [[MenubarController alloc] init];
}

- (void)handleAppleEvent:(NSAppleEventDescriptor *)event withReplyEvent:(NSAppleEventDescriptor *)replyEvent {
    NSString *urlString = [[event paramDescriptorForKeyword:keyDirectObject] stringValue];
    NSLog(@"Started with: %@",urlString);
    
    URLParser *parser = [[URLParser alloc] initWithURLString:urlString];
    NSString *code = [parser valueForVariable:@"code"];
    NSLog(@"Code: %@",code);
    
    if(code!=nil && code!=@"")
    {
        [[showAuth window] setTitle:@"ABC123"];
        [self startAuthorisation:code];
    }
    
    // do something with the URL string
}

- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender
{
    // Explicitly remove the icon from the menu bar
    self.menubarController = nil;
    return NSTerminateNow;
}

#pragma mark - Actions

- (IBAction)togglePanel:(id)sender
{
    self.menubarController.hasActiveIcon = !self.menubarController.hasActiveIcon;
    self.panelController.hasActivePanel = self.menubarController.hasActiveIcon;
}

#pragma mark - Public accessors

- (PanelController *)panelController
{
    if (_panelController == nil) {
        _panelController = [[PanelController alloc] initWithDelegate:self];
        [_panelController addObserver:self forKeyPath:@"hasActivePanel" options:0 context:kContextActivePanel];
    }
    return _panelController;
}

#pragma mark - PanelControllerDelegate

- (StatusItemView *)statusItemViewForPanelController:(PanelController *)controller
{
    return self.menubarController.statusItemView;
}

@end
