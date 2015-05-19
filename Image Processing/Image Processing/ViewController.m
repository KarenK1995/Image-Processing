//
//  ViewController.m
//  Image Processing
//
//  Created by Karen Karapetyan on 5/6/15.
//  Copyright (c) 2015 Connectto. All rights reserved.
//

#import "ViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "Cropper.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <Social/Social.h>

@interface ViewController () <UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITableViewDelegate>

@property (strong, nonatomic) NSMutableArray *filterNames;
@property (assign, nonatomic) BOOL isFullScreen;
@property (strong, nonatomic) Cropper *cropper;
@property (strong, nonatomic) UIImageView *bgImageView;
@property (strong, nonatomic) UIImageView *bgImage;
@property (assign, nonatomic) CGRect bgImageFrame;
@property (strong, nonatomic) UIScrollView *scrollView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self createBgImageView];
    [self createScrollingImageView];
    [self fullScreenGeture];
    [self availableFilterNames];
}

- (void)createScrollingImageView {
    self.bgImageFrame = CGRectMake(0, 57, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame) - 2*57);
    _scrollView = [[UIScrollView alloc] initWithFrame:self.bgImageFrame];
    self.scrollView.minimumZoomScale = 1.0;
    self.scrollView.maximumZoomScale = 6.0;
    self.scrollView.contentSize = self.bgImage.frame.size;
    self.scrollView.delegate = self;
    _bgImage = [[UIImageView alloc] initWithFrame:self.scrollView.bounds];
    //[self.bgImage setImage:[UIImage imageNamed:@"ex.jpeg"]];
    [self.scrollView addSubview:self.bgImage];
    [self.view addSubview:self.scrollView];
    self.scrollView.hidden = YES;
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.bgImage;
}

- (void)createBgImageView {
    _bgImageView = [[UIImageView alloc] initWithFrame:self.view.frame];
    [self.bgImageView setImage:[UIImage imageNamed:@"bg.jpg"]];
    [self.view addSubview:self.bgImageView];
    for (UIView *subView in self.view.subviews) {
        if (subView != self.bgImageView) {
            [self.view bringSubviewToFront:subView];
        }
    }
}

- (void)fullScreenGeture {
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(fullScreenAction:)];
    tapGesture.numberOfTapsRequired = 2;
    self.bgImage.userInteractionEnabled = YES;
    [self.bgImage addGestureRecognizer:tapGesture];
}

- (void)fullScreenAction:(UITapGestureRecognizer *)tapGesture {
    CGRect currenImageRect = CGRectZero;
    if (!self.isFullScreen) {
        self.isFullScreen = YES;
        currenImageRect = self.view.frame;
        self.scrollView.backgroundColor = [UIColor lightGrayColor];
        [self.scrollView setZoomScale:1];
    }
    else {
        self.isFullScreen = NO;
        currenImageRect = CGRectMake(0, 57, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame) - 2*57);
    }
    [UIView animateWithDuration:0.4 animations:^{
        if (self.isFullScreen == NO) {
            self.scrollView.backgroundColor = [UIColor clearColor];
        }
        self.scrollView.frame = currenImageRect;
        self.bgImage.frame = self.scrollView.bounds;
    }];
}




- (void)actionHandleTapOnCreateImageWithCamera {
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc]init];
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    }
    else{
        imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    }
    imagePicker.delegate = self;
    self.cameraButton.hidden = YES;
    self.imageLibraryButton.hidden = YES;
    [self presentViewController:imagePicker animated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage* img = info[UIImagePickerControllerOriginalImage];
    [self.bgImage setImage:img];
    [self dismissViewControllerAnimated:YES completion:nil];
    self.cameraButton.hidden = YES;
    self.imageLibraryButton.hidden = YES;
    self.scrollView.hidden = NO;
}

- (void)actionHandleTapOnCreateImageWithImageLibrary {
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc]init];
    imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    imagePicker.delegate = self;
    [self presentViewController:imagePicker animated:YES completion:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.bgImage.contentMode = UIViewContentModeScaleAspectFit;
    [self.buttomView setBackgroundColor:[[UIColor lightGrayColor] colorWithAlphaComponent:0.5]];
    [self.topView setBackgroundColor:[[UIColor lightGrayColor] colorWithAlphaComponent:0.5]];
}

- (UIImage *)firstImage {
    UIImage* img = [UIImage imageNamed:@"img.jpg"];
    return img;
}




- (IBAction)cameraAction:(UIButton *)sender {
    [self actionHandleTapOnCreateImageWithCamera];
}

- (IBAction)imageLibraryAction:(UIButton *)sender {
    [self actionHandleTapOnCreateImageWithImageLibrary];
}

- (IBAction)cropbutton:(UIButton *)sender {
    self.cropper = [[Cropper alloc] initWithImageView:self.bgImage];
    __weak ViewController *_self = self;
    _cropper.cropAction = ^(CropperAction action, UIImage *image){
        //        [_self.cropper removeFromSuperview];
        if( action == CropperActionDidCrop )
        {
            _self.bgImage.image = image;
        }
        [_self.cropButton setEnabled:YES];
    };
    [self.cropButton setEnabled:NO];
}





- (IBAction)processImageAction:(UIButton *)sender {
    if (![sender isSelected]) {
        [sender setSelected:YES];
        [self.bgImage setImage:[self intensity]];
    }
    else {
        [self.bgImage setImage:[self firstImage]];
        [sender setSelected:NO];
    }
}

- (void)availableFilterNames {
    _filterNames = [NSMutableArray array];
    [self.filterNames addObjectsFromArray:[CIFilter filterNamesInCategory:kCICategoryColorEffect]];
    NSLog(@"filtersName = %@",self.filterNames);
    //[filterNames addObjectsFromArray:[CIFilter filterNamesInCategory:kCICategoryDistortionEffect]];
    //filtersByCategory[@"Distortion"] = [self buildFilterDictionary: filterNames];
}



- (UIImage *)intensity {
    static int count = 0;
    NSString *path = [[NSBundle mainBundle] pathForResource:@"img" ofType:@"jpg"];
    NSURL *myURL = [[NSURL alloc] initFileURLWithPath:path];
    CIContext *context = [CIContext contextWithOptions:nil];
    CIImage *image = [CIImage imageWithContentsOfURL:myURL];
    CIFilter *filter = [CIFilter filterWithName:@"CIMinimumComponent"];
    [filter setValue:image forKey:kCIInputImageKey];
    //[filter setValue:@0.8f forKey:kCIInputIntensityKey];
    CIImage *result = [filter valueForKey:kCIOutputImageKey];
    CGRect extent = [result extent];
    CGImageRef cgImage = [context createCGImage:result fromRect:extent];
    UIImage *img = [UIImage imageWithCGImage:cgImage];
    ++count;
    return img;
}

- (IBAction)shareButtonAction:(UIButton *)sender {
//    SLComposeViewController *fbVC = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
//    [fbVC setInitialText:@"Hello Facebook"];
//    [fbVC addURL:[NSURL URLWithString:@"https://developers.facebook.com/ios"]];
//    [fbVC addImage:[UIImage imageNamed:@"bg.jpg"]];
//    [self presentViewController:fbVC animated:YES completion:nil];
    
    
//    NSString *text = @"How to add Facebook and Twitter sharing to an iOS app";
//    NSURL *url = [NSURL URLWithString:@"http://roadfiresoftware.com/2014/02/how-to-add-facebook-and-twitter-sharing-to-an-ios-app/"];
//    UIImage *image = [UIImage imageNamed:@"twiter.png"];
//    UIActivityViewController *controller = [[UIActivityViewController alloc] initWithActivityItems:@[text, url, image] applicationActivities:nil];
//    [self presentViewController:controller animated:YES completion:nil];
    
    NSString *urlString=@"https://itunes.apple.com/us/app/glavhimchistka/id986310493?ls=1&mt=8";
    NSString *authLink = [NSString stringWithFormat:@"http://vkontakte.ru/share.php?url=%@",urlString];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:authLink]];
}

- (IBAction)takePhotoAction:(UIButton *)sender {
    self.cameraButton.hidden = NO;
    self.imageLibraryButton.hidden = NO; 
    self.scrollView.hidden = YES;
}

#pragma mark - Rotation
- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        self.bgImageView.frame = self.view.frame;
        self.scrollView.frame = CGRectMake(0, 57, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame) - 2*57);
        self.bgImage.frame = self.scrollView.bounds;
    } completion:^(id<UIViewControllerTransitionCoordinatorContext> context) {
    }];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    self.bgImageView.frame = self.view.frame;
    self.scrollView.frame = CGRectMake(0, 57, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame) - 2*57);
    self.bgImage.frame = self.scrollView.bounds;
}

- (IBAction)localSaveImageAction:(UIButton *)sender {
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    [library writeImageToSavedPhotosAlbum:[self.bgImage.image CGImage] orientation:(ALAssetOrientation)[self.bgImage.image imageOrientation] completionBlock:^(NSURL *assetURL, NSError *error){
        if (error) {
            // TODO: error handling
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"Try gain" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
        } else {
            // TODO: success handling
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"Photo saved to Image Library" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
        }
    }];
}

@end