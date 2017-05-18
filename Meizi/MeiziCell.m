//
//  MeiziCell.m
//  Meizi
//
//  Created by Sunnyyoung on 15/7/14.
//  Copyright (c) 2015年 Sunnyyoung. All rights reserved.
//

#import "MeiziCell.h"
#import "Meizi.h"
#import "MeiziViewController.h"

@interface MeiziCell ()

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *zanLabel;
@property (nonatomic, assign) NSInteger counter;
@property (nonatomic, assign) NSString *id;

@end

@implementation MeiziCell

#pragma mark - Public method

- (void)setMeizi:(Meizi *)meizi {
    NSURL *imageURL = [NSURL URLWithString:meizi.thumb_url];
    [self.imageView setImageWithURL:imageURL usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.counter = [meizi.like intValue];
    self.id = meizi.id;
    NSString *s = @"👍x";
    //NSLog(@"%@", meizi.like);
    self.zanLabel.text = [s stringByAppendingString: meizi.like];
    self.imageView.userInteractionEnabled = YES;
    UITapGestureRecognizer *pgr = [[UITapGestureRecognizer alloc]
                                     initWithTarget:self action:@selector(handleTap:)];
    pgr.delegate = self;
    [self.imageView addGestureRecognizer:pgr];
    //[pgr release];
}

- (void)handleTap:(UITapGestureRecognizer *)tapGestureRecognizer
{
    //NSLog(@"12321321");
    self.counter += 1;
    [self star];
    NSString *zan = @"👍x";
    NSString *cnt = [NSString stringWithFormat: @"%ld", (long)self.counter];
    zan = [zan stringByAppendingString:cnt];
    self.zanLabel.text = zan;
    //[self.imageView setContentMode:UIViewContentModeScaleAspectFit];
    /*
    double delayInSeconds = 1.5;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        //code to be executed on the main queue after delay
        UIImageView *clickedImageView = (UIImageView *)tapGestureRecognizer.view;
        [self scanBigImageWithImageView:clickedImageView];
    });
    */
    [self pin];
    
}


- (void)pin {
    NSString *s = @"https://mei12356.ml/pin?id=";
    s = [s stringByAppendingString: self.id];
    NSURL *url = [NSURL URLWithString:s];
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url];
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [NSURLConnection sendAsynchronousRequest:urlRequest queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
    {
        
        
        if (error)
        {
            //NSLog(@"Error,%@", [error localizedDescription]);
        }
        else
        {
            NSLog(@"=-=-=-=--=%@", [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding]);
        }
    }];
}


- (void)star {
    MeiziViewController *mvc = (MeiziViewController *)[self viewController];
    [mvc tapStar];
}

- (UIViewController *)viewController {
    UIResponder *responder = self;
    while (![responder isKindOfClass:[UIViewController class]]) {
        responder = [responder nextResponder];
        if (nil == responder) {
            break;
        }
    }
    return (UIViewController *)responder;
}

static CGRect oldframe;

/**
 *  浏览大图
 *
 *  @param scanImageView 图片所在的imageView
 */
-(void)scanBigImageWithImageView:(UIImageView *)currentImageview{
    //当前imageview的图片
    UIImage *image = currentImageview.image;
    //当前视图
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    //背景
    UIView *backgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
    //当前imageview的原始尺寸->将像素currentImageview.bounds由currentImageview.bounds所在视图转换到目标视图window中，返回在目标视图window中的像素值
    oldframe = [currentImageview convertRect:currentImageview.bounds toView:window];
    //[backgroundView setBackgroundColor:colorWithRGBA(107, 107, 99, 0.6)];
    //此时视图不会显示
    [backgroundView setAlpha:0];
    //将所展示的imageView重新绘制在Window中
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:oldframe];
    [imageView setImage:image];
    [imageView setTag:0];
    [backgroundView addSubview:imageView];
    //将原始视图添加到背景视图中
    [window addSubview:backgroundView];
    
    
    //添加点击事件同样是类方法 -> 作用是再次点击回到初始大小
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideImageView:)];
    [backgroundView addGestureRecognizer:tapGestureRecognizer];
    
    //动画放大所展示的ImageView
    
    [UIView animateWithDuration:0.4 animations:^{
        CGFloat y,width,height;
        y = ([UIScreen mainScreen].bounds.size.height - image.size.height * [UIScreen mainScreen].bounds.size.width / image.size.width) * 0.5;
        //宽度为屏幕宽度
        width = [UIScreen mainScreen].bounds.size.width;
        //高度 根据图片宽高比设置
        height = image.size.height * [UIScreen mainScreen].bounds.size.width / image.size.width;
        [imageView setFrame:CGRectMake(0, y, width, height)];
        //重要！ 将视图显示出来
        [backgroundView setAlpha:1];
    } completion:^(BOOL finished) {
        
    }];
    
}

/**
 *  恢复imageView原始尺寸
 *
 *  @param tap 点击事件
 */
-(void)hideImageView:(UITapGestureRecognizer *)tap{
    UIView *backgroundView = tap.view;
    //原始imageview
    UIImageView *imageView = [tap.view viewWithTag:0];
    //恢复
    [UIView animateWithDuration:0.4 animations:^{
        [imageView setFrame:oldframe];
        [backgroundView setAlpha:0];
    } completion:^(BOOL finished) {
        //完成后操作->将背景视图删掉
        [backgroundView removeFromSuperview];
    }];
}

@end
