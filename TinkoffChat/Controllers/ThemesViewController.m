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

@end

@implementation ThemesViewController

//@synthesize model = _model;
//@synthesize delegate = _delegate;

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
    _model.theme1 = newModel.theme1;
    _model.theme2 = newModel.theme2;
    _model.theme3 = newModel.theme3;
}
- (instancetype) initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder: aDecoder];
    
    if (self) {
        _model = [Themes new];
        Themes* newModel = [Themes new];
        newModel.theme1 = [UIColor blackColor];
        newModel.theme2 = [UIColor whiteColor];
        newModel.theme3 = [[UIColor alloc] initWithRed:(255.0/255.0) green:(221.0/255.0) blue:(45.0/255.0) alpha:1.0];
        [self setModel: newModel];
        printf("создали темы и модель\n");
        newModel.theme1 = NULL;
        newModel.theme2 = NULL;
        newModel.theme3 = NULL;
        [newModel release];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)dealloc {
    //[_model.theme1 release];
    //[_model.theme2 release];
    [_model.theme3 release];
    
    [_model release];
    printf("удалили темы и модель\n");
    
    [super dealloc];
}
- (IBAction)closeAction:(UIBarButtonItem *)sender {
    [self dismissViewControllerAnimated: YES completion: NULL];
}
- (IBAction)theme1Action:(UIButton *)sender {
    self.view.backgroundColor = self.model.theme1;
    [self.delegate themesViewController: self didSelectTheme: self.model.theme1];
}
- (IBAction)theme2Action:(UIButton *)sender {
    self.view.backgroundColor = self.model.theme2;
    [self.delegate themesViewController: self didSelectTheme: self.model.theme2];
}
- (IBAction)theme3Action:(UIButton *)sender {
    self.view.backgroundColor = self.model.theme3;
    [self.delegate themesViewController: self didSelectTheme: self.model.theme3];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
