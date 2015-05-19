//
//  ViewController.h
//  Image Processing
//
//  Created by Karen Karapetyan on 5/6/15.
//  Copyright (c) 2015 Connectto. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController

- (IBAction)processImageAction:(UIButton *)sender;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bgImageTopSpaace;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bgImageButtomSpace;
- (IBAction)cameraAction:(UIButton *)sender;
- (IBAction)imageLibraryAction:(UIButton *)sender;
@property (weak, nonatomic) IBOutlet UIButton *cameraButton;
@property (weak, nonatomic) IBOutlet UIButton *imageLibraryButton;
- (IBAction)cropbutton:(UIButton *)sender;
@property (weak, nonatomic) IBOutlet UIButton *cropButton;
- (IBAction)shareButtonAction:(UIButton *)sender;
- (IBAction)takePhotoAction:(UIButton *)sender;
@property (weak, nonatomic) IBOutlet UIView *buttomView;
- (IBAction)localSaveImageAction:(UIButton *)sender;
@property (weak, nonatomic) IBOutlet UIView *topView;

@end

