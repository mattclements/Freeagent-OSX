#import "ApplicationDelegate.h"
#import "URLParser.h"

static NSString* const apiURL = @"https://api.sandbox.freeagent.com/v2";
static NSString* const apiType = @"freeagentService";
static NSString* const apiKey = @"X7OI4l5_sRozUtlgp1zVTg";
static NSString* const apiSecret = @"cz90veji5UpEQaMopCb6LQ";

@implementation ApplicationDelegate

@synthesize panelController = _panelController;
@synthesize menubarController = _menubarController;
@synthesize requestToken;

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
    
    ApplicationDelegate *appDelegate = [[ApplicationDelegate alloc] init];
    [appDelegate startAuthorisation];
}

- (void)startAuthorisation {
    
    OAConsumer *consumer = [[OAConsumer alloc] initWithKey:apiKey
                                                    secret:apiSecret];
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/approve_app",apiURL]];
    
    OAMutableURLRequest *request = [[OAMutableURLRequest alloc] initWithURL:url
                                                                   consumer:consumer
                                                                      token:nil   // we don't have a Token yet
                                                                      realm:nil   // our service provider doesn't specify a realm
                                                          signatureProvider:nil]; // use the default method, HMAC-SHA1
    
    [request setHTTPMethod:@"POST"];
    
    OADataFetcher *fetcher = [[OADataFetcher alloc] init];
    
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
        
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/token_endpoint",apiURL]];
        [[NSWorkspace sharedWorkspace] openURL:url];
        NSLog(@"Registered Token");
    }
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
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:code forKey:@"code"];
        [defaults synchronize];
        NSLog(@"Data saved");
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
