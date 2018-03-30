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
@property (retain) UIColor* backgroundColor;
@property (retain) UIColor* tintColor;

+ (instancetype)sharedWhiteTheme;
+ (instancetype)sharedBlackTheme;
+ (instancetype)sharedChampainTheme;
@end

@interface Themes : NSObject
    @property (retain) Theme* theme1;
    @property (retain) Theme* theme2;
    @property (retain) Theme* theme3;
@end
