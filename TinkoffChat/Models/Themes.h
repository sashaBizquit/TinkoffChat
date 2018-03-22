//
//  Themes.h
//  TinkoffChat
//
//  Created by Александр Лыков on 17.03.2018.
//  Copyright © 2018 Lykov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface Theme : NSObject <NSCoding>
@property (copy) UIColor* backgroundColor;
@property (copy) UIColor* tintColor;

+ (instancetype)sharedWhiteTheme;
+ (instancetype)sharedBlackTheme;
+ (instancetype)sharedChampainTheme;
@end

@interface Themes : NSObject
    @property (assign) Theme* theme1;
    @property (assign) Theme* theme2;
    @property (assign) Theme* theme3;
@end
