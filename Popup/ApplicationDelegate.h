#import "MenubarController.h"
#include "sys/types.h"
#include "OAuthConsumer.h"
#import "PanelController.h"
#import "ShowAuth.h"

@interface ApplicationDelegate : NSObject <NSApplicationDelegate, PanelControllerDelegate> {
    OAToken *requestToken;
    ShowAuth *showAuth;
}

@property (nonatomic, strong) MenubarController *menubarController;
@property (nonatomic, strong, readonly) PanelController *panelController;
@property (nonatomic, retain) OAToken *requestToken;
@property (nonatomic, retain) ShowAuth *showAuth;

- (IBAction)togglePanel:(id)sender;

@end
