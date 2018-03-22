//
//  Themes.m
//  TinkoffChat
//
//  Created by Александр Лыков on 17.03.2018.
//  Copyright © 2018 Lykov. All rights reserved.
//

#import "Themes.h"

@implementation Themes

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
    return [[Theme alloc] initWithBackgroundColor: [[UIColor alloc] initWithWhite: 0 alpha: 1]
                            andTintColor: [[UIColor alloc] initWithWhite: 0 alpha: 1]
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

-(instancetype)copyWithZone:(NSZone *)zone {
    Theme *another = [[Theme alloc] init];
    another.backgroundColor = [_backgroundColor copyWithZone: zone];
    another.tintColor = [_tintColor copyWithZone:zone];
    return another;
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

- (void)dealloc {
    if (_backgroundColor != nil) [_backgroundColor release];
    if (_tintColor != nil) [_tintColor release];
    [super dealloc];
}

@end
