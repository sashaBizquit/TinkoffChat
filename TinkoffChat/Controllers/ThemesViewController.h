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

@protocol ThemesViewControllerDelegate <NSObject>
- (void) themesViewController: (ThemesViewController *) controller didSelectTheme: (UIColor*) selectedTheme;
@end

@interface ThemesViewController : UIViewController
    @property (assign) Themes* model;
    @property (assign) id<ThemesViewControllerDelegate> delegate;
@end


