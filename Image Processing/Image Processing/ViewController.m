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
#import <VKSdk/VKSdk.h>
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

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.bgImage.contentMode = UIViewContentModeScaleAspectFit;
    [self.buttomView setBackgroundColor:[[UIColor lightGrayColor] colorWithAlphaComponent:0.5]];
    [self.topView setBackgroundColor:[[UIColor lightGrayColor] colorWithAlphaComponent:0.5]];
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
    switch (sender.tag) {
        case 1:
            [self VKShare];
            break;
        case 2:
            
            break;
        case 3:
            
            break;
        case 4:
            [self twitterShare];
            break;
        case 5:
            [self facebookShare];
            break;
            
        default:
            break;
    }
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

- (void)VKShare {
    VKShareDialogController * shareDialog = [VKShareDialogController new];
    shareDialog.uploadImages = @[[VKUploadImage uploadImageWithImage:self.bgImage.image andParams:nil]];
    [shareDialog setCompletionHandler:^(VKShareDialogControllerResult result) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }];
    [self presentViewController:shareDialog animated:YES completion:nil];
}

- (void)twitterShare {
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter]) {
        SLComposeViewController *tweet = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
        [tweet setInitialText:@"I just completed the Social.framework Tutorial by @iosdevtutorials !"];
        [tweet addImage:self.bgImage.image];
        [tweet setCompletionHandler:^(SLComposeViewControllerResult result) {
             if (result == SLComposeViewControllerResultCancelled) {
                 NSLog(@"The user cancelled.");
             }
             else if (result == SLComposeViewControllerResultDone) {
                 NSLog(@"The user sent the tweet");
             }
         }];
        [self presentViewController:tweet animated:YES completion:nil];
    }
    else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Twitter"
                                                        message:@"Twitter integration is not available.  A Twitter account must be set up on your device."
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }
}

- (void)facebookShare {
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook]) {
        SLComposeViewController *fbShare = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
        [fbShare addImage:self.bgImage.image];
        [fbShare setCompletionHandler:^(SLComposeViewControllerResult result) {
            if (result == SLComposeViewControllerResultCancelled) {
                NSLog(@"The user cancelled.");
            }
            else if (result == SLComposeViewControllerResultDone) {
                NSLog(@"The user sent the tweet");
            }
        }];
        [self presentViewController:fbShare animated:YES completion:nil];
    }
    else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Facebook"
                                                        message:@"Facebook integration is not available.  A Facebook account must be set up on your device."
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }
}

@end
