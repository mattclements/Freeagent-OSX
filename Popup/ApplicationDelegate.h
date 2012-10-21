#import "MenubarController.h"
#import <OAuthConsumer/OAuthConsumer.h>
#import "PanelController.h"

@interface ApplicationDelegate : NSObject <NSApplicationDelegate, PanelControllerDelegate> {
    OAToken *requestToken;
}

@property (nonatomic, strong) MenubarController *menubarController;
@property (nonatomic, strong, readonly) PanelController *panelController;
@property (nonatomic, retain) OAToken *requestToken;

- (IBAction)togglePanel:(id)sender;

@end