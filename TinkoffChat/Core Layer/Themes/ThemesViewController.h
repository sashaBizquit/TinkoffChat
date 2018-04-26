//
//  ThemesViewController.h
//  TinkoffChat
//
//  Created by Александр Лыков on 17.03.2018.
//  Copyright © 2018 Lykov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Themes.h"

@class ThemesViewController;
@protocol ThemePickerProtocol;

@protocol ThemesViewControllerDelegate <NSObject>
- (void) themesViewController: (id<ThemePickerProtocol>) controller didSelectTheme: (Theme*) selectedTheme;
@end

@protocol ThemePickerProtocol <NSObject>
    @property (assign) id<ThemesViewControllerDelegate> delegate;
@end

@interface ThemesViewController : UIViewController <ThemePickerProtocol>
    @property (assign) Themes* model;
    @property (assign) id<ThemesViewControllerDelegate> delegate;
@end


