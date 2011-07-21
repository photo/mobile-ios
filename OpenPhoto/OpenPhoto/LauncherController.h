#import <Foundation/Foundation.h>
#import <Three20/Three20.h>

@interface LauncherController : TTViewController <TTLauncherViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate> {
    TTLauncherView* launcherView;
}
@end
