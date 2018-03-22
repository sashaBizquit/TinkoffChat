//
//  Themes.m
//  TinkoffChat
//
//  Created by Александр Лыков on 17.03.2018.
//  Copyright © 2018 Lykov. All rights reserved.
//

#import "Themes.h"

@implementation Themes {
    Theme *_theme1, *_theme2, *_theme3;
}

-(void)setTheme1:(Theme *)theme1 {
    _theme1 = theme1;
}

-(void)setTheme2:(Theme *)theme2 {
    _theme2 = theme2;
}

-(void)setTheme3:(Theme *)theme3 {
    _theme3 = theme3;
}

-(Theme *)theme1 {
    return _theme1;
}

-(Theme *)theme2 {
    return _theme2;
}

-(Theme *)theme3 {
    return _theme3;
}
- (void)dealloc {
    if (_theme1 != nil) [_theme1 release];
    if (_theme2 != nil) [_theme2 release];
    if (_theme3 != nil) [_theme3 release];
    [super dealloc];
}
@end

@implementation Theme {
    UIColor* _backgroundColor;
    UIColor* _tintColor;
}

- (void)setBackgroundColor:(UIColor *)backgroundColor {
    _backgroundColor = [backgroundColor copy];
}

- (UIColor *)backgroundColor {
    return _backgroundColor;
}

- (void)setTintColor:(UIColor *)tintColor {
    _tintColor = [tintColor copy];
}

- (UIColor *)tintColor {
    return _tintColor;
}

- (instancetype)init {
    return [self initWithBackgroundColor: NULL andTintColor: NULL];
}

- (instancetype)initWithBackgroundColor: (UIColor*) backColor andTintColor: (UIColor*) tintColor {
    self = [super init];
    if (self) {
        _backgroundColor = backColor;
        _tintColor = tintColor;
    }
    return self;
}

+ (instancetype)sharedWhiteTheme {
    return  [[Theme alloc] initWithBackgroundColor: [[UIColor alloc] initWithWhite: 1 alpha: 1]
                             andTintColor: [[UIColor alloc] initWithRed: 0
                                                                  green: (122/255.0)
                                                                   blue: 1
                                                                  alpha: 1
                                            ]
             ];
}

+ (instancetype)sharedBlackTheme {
    return [[Theme alloc] initWithBackgroundColor: [[UIColor alloc] initWithWhite: 0.2 alpha: 1]
                            andTintColor: [[UIColor alloc] initWithWhite: 1 alpha: 1]
            ];
}

+ (instancetype)sharedChampainTheme {
    return [[Theme alloc] initWithBackgroundColor: [[UIColor alloc] initWithRed: 1
                                                                 green: (221.0/255.0)
                                                                  blue: (45.0/255.0)
                                                                 alpha: 1
                                           ]
                            andTintColor: [[UIColor alloc] initWithRed: 1
                                                                 green: (122/255.0)
                                                                  blue: 0
                                                                 alpha: 1
                                           ]
            ];
}

- (void)dealloc {
    if (_backgroundColor != nil) [_backgroundColor release];
    if (_tintColor != nil) [_tintColor release];
    [super dealloc];
}

// MARK: - NSCoding -

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]){
        _backgroundColor = [aDecoder decodeObjectForKey: @"backgroundColor"];
        _tintColor = [aDecoder decodeObjectForKey: @"tintColor"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject: _backgroundColor forKey: @"backgroundColor"];
    [aCoder encodeObject: _tintColor forKey: @"tintColor"];
}

// MARK: - NSCopying -
-(instancetype)copyWithZone:(NSZone *)zone {
    Theme *another = [[Theme alloc] init];
    another.backgroundColor = [_backgroundColor copyWithZone: zone];
    another.tintColor = [_tintColor copyWithZone:zone];
    return another;
}

@end
