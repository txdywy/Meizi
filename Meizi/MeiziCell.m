//
//  MeiziCell.m
//  Meizi
//
//  Created by Sunnyyoung on 15/7/14.
//  Copyright (c) 2015年 Sunnyyoung. All rights reserved.
//

#import "MeiziCell.h"
#import "Meizi.h"

@interface MeiziCell ()

@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end

@implementation MeiziCell

#pragma mark - Public method

- (void)setMeizi:(Meizi *)meizi {
    NSURL *imageURL = [NSURL URLWithString:meizi.thumb_url];
    [self.imageView setImageWithURL:imageURL usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.imageView.userInteractionEnabled = YES;
    UITapGestureRecognizer *pgr = [[UITapGestureRecognizer alloc]
                                     initWithTarget:self action:@selector(handleTap:)];
    pgr.delegate = self;
    [self.imageView addGestureRecognizer:pgr];
    //[pgr release];
}

- (void)handleTap:(UITapGestureRecognizer *)tapGestureRecognizer
{
    NSLog(@"12321321");
}

@end
