//
//  ShowAuth.m
//  Freeagent OSX
//
//  Created by Matt Clements on 21/10/2012.
//
//

#import "ShowAuth.h"

@interface ShowAuth ()

@end

@implementation ShowAuth

@synthesize webView;

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (id) init
{
	self = [super initWithWindowNibName:@"ShowAuth"];
	return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

- (void)loadWebPage:(NSURL *) url {
    [[webView mainFrame] loadRequest:[NSURLRequest requestWithURL:url]];
}





@end
