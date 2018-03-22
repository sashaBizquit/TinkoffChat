//
//  ThemesViewController.m
//  TinkoffChat
//
//  Created by Александр Лыков on 17.03.2018.
//  Copyright © 2018 Lykov. All rights reserved.
//

#import "ThemesViewController.h"

@interface ThemesViewController () {
    Themes * _model;
    id<ThemesViewControllerDelegate> _delegate;
}

- (void)changeThemeTo:(Theme*)theme;
@end

@implementation ThemesViewController

- (Themes*) model {
    return _model;
}

- (id<ThemesViewControllerDelegate>) delegate {
    return _delegate;
}

- (void) setDelegate:(id<ThemesViewControllerDelegate>)newDelegate {
    _delegate = newDelegate;
}

- (void) setModel:(Themes *)newModel {
    _model.theme1 = [newModel.theme1 copy];
    _model.theme2 = [newModel.theme2 copy];
    _model.theme3 = [newModel.theme3 copy];
}
- (instancetype) initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder: aDecoder];
    
    if (self) {
        _model = [Themes new];
        
        Themes* newModel = [Themes new];
        
        newModel.theme1 = [Theme sharedBlackTheme];
        newModel.theme2 = [Theme sharedWhiteTheme];
        newModel.theme3 = [Theme sharedChampainTheme];
        
        [self setModel: newModel];
        [newModel release];
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    UIColor* color = [((UIViewController *)_delegate).navigationController.navigationBar.backgroundColor copy];
    self.view.backgroundColor = color;
    [color release];
}

- (void)dealloc {
    [_model release];
    [super dealloc];
}
- (void)changeThemeTo:(Theme*)theme {
    self.view.backgroundColor = theme.backgroundColor;
    UINavigationBar* currentBar = self.navigationController.navigationBar;
    currentBar.backgroundColor = theme.backgroundColor;
    currentBar.tintColor = theme.tintColor;
    currentBar = NULL;
    [self.delegate themesViewController: self didSelectTheme: theme];
}

- (IBAction)closeAction:(UIBarButtonItem *)sender {
    [self dismissViewControllerAnimated: YES completion: NULL];
}
- (IBAction)theme1Action:(UIButton *)sender {
    [self changeThemeTo: self.model.theme1];
}
- (IBAction)theme2Action:(UIButton *)sender {
    [self changeThemeTo: self.model.theme2];
}
- (IBAction)theme3Action:(UIButton *)sender {
    [self changeThemeTo: self.model.theme3];
}

@end
