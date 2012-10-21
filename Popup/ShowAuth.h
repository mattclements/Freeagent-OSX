//
//  ShowAuth.h
//  Freeagent OSX
//
//  Created by Matt Clements on 21/10/2012.
//
//

#import <Cocoa/Cocoa.h>
#import <Webkit/Webkit.h>

@interface ShowAuth : NSWindowController <NSWindowDelegate> {
    IBOutlet WebView *webView;
}

- (void)loadWebPage:(NSURL *) url;

@property (strong) IBOutlet WebView *webView;

@end
