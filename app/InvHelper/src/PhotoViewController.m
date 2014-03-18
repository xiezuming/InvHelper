//
//  PhotoVIewControllerViewController.m
//  Inv Helper
//
//  Created by 谢 祖铭 on 13-8-17.
//  Copyright (c) 2013年 Self. All rights reserved.
//

#import "PhotoViewController.h"
#import "MoveScaleImageView.h"
#import "PhotoDao.h"

@interface PhotoViewController ()
{
    CGSize minSize;
    CGSize maxSize;
}
@end

@implementation PhotoViewController

@synthesize imageView;
@synthesize photoName;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    UIImage *image = [[[PhotoDao alloc] init] getImageByPhotoName:photoName];
    //[imageView setImage:image];
    
    CGSize imageSize = image.size;
    CGSize frameSize = self.view.frame.size;
    CGFloat minScale = MIN(1.0, MIN(frameSize.width / imageSize.width, frameSize.height / imageSize.height));
    CGFloat maxScale = 2.0;
    minSize = CGSizeApplyAffineTransform(imageSize, CGAffineTransformMakeScale(minScale, minScale));
    maxSize = CGSizeApplyAffineTransform(imageSize, CGAffineTransformMakeScale(maxScale, maxScale));
    
    imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, minSize.width, minSize.height)];
    imageView.image = image;
    [imageView setUserInteractionEnabled:YES];
    [imageView setMultipleTouchEnabled:YES];
    [self addGestureRecognizerToView:imageView];
    [self.view addSubview:imageView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) addGestureRecognizerToView:(UIView *)view
{
    //UIRotationGestureRecognizer *rotationGestureRecognizer = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(rotateView:)];
    //[view addGestureRecognizer:rotationGestureRecognizer];
    
    UIPinchGestureRecognizer *pinchGestureRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchView:)];
    [view addGestureRecognizer:pinchGestureRecognizer];
    
    UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panView:)];
    [view addGestureRecognizer:panGestureRecognizer];
}

- (IBAction)panView:(UIPanGestureRecognizer *)panGestureRecognizer {
    UIView *view = panGestureRecognizer.view;
    if (panGestureRecognizer.state == UIGestureRecognizerStateBegan || panGestureRecognizer.state == UIGestureRecognizerStateChanged) {
        CGPoint translation = [panGestureRecognizer translationInView:view.superview];
        CGSize viewSize = view.frame.size;
        CGSize superViewSize = view.superview.frame.size;
        CGRect targetFrame = view.frame;
        CGFloat x = targetFrame.origin.x + translation.x;
        CGFloat y = targetFrame.origin.y + translation.y;
        if (viewSize.width <= superViewSize.width) {
            x = MIN(MAX(x, 0), superViewSize.width - viewSize.width);
        } else {
            x = MAX(MIN(x, 0), superViewSize.width - viewSize.width);
        }
        if (viewSize.height <= superViewSize.height) {
            y = MIN(MAX(y, 0), superViewSize.height - viewSize.height);
        } else {
            y = MAX(MIN(y, 0), superViewSize.height - viewSize.height);
        }

        targetFrame.origin.x = x;
        targetFrame.origin.y = y;
        [view setFrame:targetFrame];
        //[view setCenter:(CGPoint){view.center.x + translation.x, view.center.y + translation.y}];
        [panGestureRecognizer setTranslation:CGPointZero inView:view.superview];
    }
}

- (IBAction)pinchView:(UIPinchGestureRecognizer *)pinchGestureRecognizer {
    UIView *view = pinchGestureRecognizer.view;
    if (pinchGestureRecognizer.state == UIGestureRecognizerStateBegan || pinchGestureRecognizer.state == UIGestureRecognizerStateChanged) {
        CGPoint centerPoint = imageView.center;
        view.transform = CGAffineTransformScale(view.transform, pinchGestureRecognizer.scale, pinchGestureRecognizer.scale);
        if (imageView.frame.size.width < minSize.width) {
            CGRect minFrame = {.origin = imageView.frame.origin, .size = minSize};
            [imageView setFrame:minFrame];
            [imageView setCenter:centerPoint];
        }
        if (imageView.frame.size.width > maxSize.width) {
            CGRect maxFrame = {.origin = imageView.frame.origin, .size = maxSize};
            [imageView setFrame:maxFrame];
            [imageView setCenter:centerPoint];
        }
        pinchGestureRecognizer.scale = 1;
    }
}

@end
