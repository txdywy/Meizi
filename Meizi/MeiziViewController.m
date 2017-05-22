//
//  MeiziViewController.m
//  Meizi
//
//  Created by Sunnyyoung on 15/7/14.
//  Copyright (c) 2015年 Sunnyyoung. All rights reserved.
//

#import "MeiziViewController.h"
#import "SYNavigationDropdownMenu.h"
#import "MeiziRequest.h"
#import "MeiziCell.h"
#import "Meizi.h"
#import "AppDelegate.h"
#import <SpriteKit/SpriteKit.h>
#import "PasterController.h"
@import GoogleMobileAds;


#define SCREEN_SCALE [[UIScreen mainScreen] scale]
#define DEGREES_TO_RADIANS(angle) ((angle) / 180.0 * M_PI)

@interface MeiziViewController () <UICollectionViewDelegateFlowLayout, SYNavigationDropdownMenuDataSource, SYNavigationDropdownMenuDelegate>

@property (nonatomic, assign) NSInteger page;
@property (nonatomic, assign) MeiziCategory category;
@property (nonatomic, strong) NSMutableArray *meiziArray;
@property (nonatomic, strong) GADBannerView *banner;
@property (nonatomic, strong) GADInterstitial *interstitial;
@property (nonatomic, assign) NSInteger counter;

//Core Animation
@property (nonatomic, strong) UIImageView *caStarImageView;
@property (nonatomic, strong) CAEmitterLayer *caStarEmitter;

@end

@implementation MeiziViewController

#pragma mark - LifeCycle

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        _page = 1;
        _category = MeiziCategoryAll;
    }
    return self;
}

- (IBAction)stickerPressed:(id)sender {
    [self performSegueWithIdentifier:@"2paster" sender:nil];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"2paster"])
    {
        PasterController *pasterCtrller = (PasterController *)[segue destinationViewController] ;
        UIButton *btn = (UIButton *)sender;
        MeiziCell *cell = (MeiziCell *)[btn superview];
        pasterCtrller.imageWillHandle = cell.imageView.image;
        pasterCtrller.delegate = self ;
    }
}


- (void)viewDidLoad {
    [super viewDidLoad];
    [self.collectionView.mj_header beginRefreshing];
    [self.navigationController setToolbarHidden:NO];
    self.interstitial = [self createAndLoadInterstitial];
    self.banner = [[GADBannerView alloc] initWithAdSize:kGADAdSizeBanner];
    self.banner.adUnitID = @"ca-app-pub-7366328858638561/4822998731";
    self.banner.rootViewController = self;
    self.banner.center = CGPointMake(self.navigationController.toolbar.frame.size.width / 2, self.navigationController.toolbar.frame.size.height / 2 - 3);
    [self.navigationController.toolbar addSubview:self.banner];
    [self.navigationController.toolbar sizeToFit];
    [self.banner loadRequest:[GADRequest request]];
    [self showX];
    self.counter = 0;
    [self initStar];
}

- (GADInterstitial *)createAndLoadInterstitial {
    GADInterstitial *interstitial =
    [[GADInterstitial alloc] initWithAdUnitID:@"ca-app-pub-7366328858638561/6299731937"];
    interstitial.delegate = self;
    [interstitial loadRequest:[GADRequest request]];
    return interstitial;
}

- (void)interstitialDidDismissScreen:(GADInterstitial *)interstitial {
    self.interstitial = [self createAndLoadInterstitial];
}

- (void)showX {
    if (self.interstitial.isReady) {
        [self.interstitial presentFromRootViewController:self];
        self.interstitial = [self createAndLoadInterstitial];
    }
}

- (void)initStar {
    [self shootOffSpriteKitStarFromView:self.view];
}

- (void)tapStar {
    [self shootOffCoreAnimationStarFromView:self.view];

}

#pragma mark - Orientation method

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    [self.collectionView.collectionViewLayout invalidateLayout];
    [self.collectionView.collectionViewLayout finalizeCollectionViewUpdates];
}

#pragma mark - CollectionView DataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    collectionView.mj_footer.hidden = self.meiziArray.count == 0;
    return self.meiziArray.count;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat screeWidth = CGRectGetWidth([UIScreen mainScreen].bounds);
    NSInteger perLine = ([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationPortrait)?3:5;
    return CGSizeMake(screeWidth/perLine-1, screeWidth/perLine-1);
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    MeiziCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"MeiziCell" forIndexPath:indexPath];
    [cell setMeizi:self.meiziArray[indexPath.row]];
    return cell;
}

#pragma mark - CollectionView Delegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSMutableArray *photoURLArray = [NSMutableArray array];
    for (Meizi *meizi in self.meiziArray) {
        [photoURLArray addObject:meizi.image_url];
    }
    SYPhotoBrowser *photoBrowser = [[SYPhotoBrowser alloc] initWithImageSourceArray:photoURLArray caption:nil delegate:self];
    photoBrowser.enableStatusBarHidden = NO;
    photoBrowser.pageControlStyle = SYPhotoBrowserPageControlStyleLabel;
    photoBrowser.initialPageIndex = indexPath.item;
    [((AppDelegate *)[UIApplication sharedApplication].delegate).window.rootViewController presentViewController:photoBrowser animated:YES completion:nil];
}

#pragma mark - NavigationDropdownMenu DataSource

- (NSArray<NSString *> *)titleArrayForNavigationDropdownMenu:(SYNavigationDropdownMenu *)navigationDropdownMenu {
    return @[@"所有"];//, @"大胸", @"翘臀", @"黑丝", @"美腿", @"清新", @"杂烩"];
}

- (UIImage *)arrowImageForNavigationDropdownMenu:(SYNavigationDropdownMenu *)navigationDropdownMenu {
    return [UIImage imageNamed:@"Arrow"];
}

- (CGFloat)arrowPaddingForNavigationDropdownMenu:(SYNavigationDropdownMenu *)navigationDropdownMenu {
    return 8.0;
}

- (BOOL)keepCellSelectionForNavigationDropdownMenu:(SYNavigationDropdownMenu *)navigationDropdownMenu {
    return NO;
}

#pragma mark - NavigationDropdownMenu Delegate

- (void)navigationDropdownMenu:(SYNavigationDropdownMenu *)navigationDropdownMenu didSelectTitleAtIndex:(NSUInteger)index {
    self.category = index;
    [self.collectionView.mj_header beginRefreshing];
}

#pragma mark - Refresh method



- (void)refreshMeizi {
    self.page = 1;
    [MeiziRequest requestWithPage:self.page category:self.category success:^(NSArray<Meizi *> *meiziArray) {
        [self.collectionView.mj_header endRefreshing];
        [self reloadDataWithMeiziArray:meiziArray emptyBeforeReload:YES];
    } failure:^(NSString *message) {
        [SVProgressHUD showErrorWithStatus:message];
        [self.collectionView.mj_header endRefreshing];
    }];
    [self tapStar];
}

- (void)loadMoreMeizi {
    self.counter += 1;
    if (self.counter > 0 && self.counter % 5 == 0) {
        [self showX];
    }
    [MeiziRequest requestWithPage:self.page+1 category:self.category success:^(NSArray<Meizi *> *meiziArray) {
        [self.collectionView.mj_footer endRefreshing];
        [self reloadDataWithMeiziArray:meiziArray emptyBeforeReload:NO];
    } failure:^(NSString *message) {
        [SVProgressHUD showErrorWithStatus:message];
        [self.collectionView.mj_footer endRefreshing];
    }];
    [self initStar];
}

- (void)reloadDataWithMeiziArray:(NSArray<Meizi *> *)meiziArray emptyBeforeReload:(BOOL)emptyBeforeReload {
    if (emptyBeforeReload) {
        self.page = 1;
        [self.meiziArray removeAllObjects];
        [self.meiziArray addObjectsFromArray:meiziArray];
        [self.collectionView.mj_footer resetNoMoreData];
    } else {
        if (meiziArray.count) {
            [self.meiziArray addObjectsFromArray:meiziArray];
            self.page++;
        } else {
            [self.collectionView.mj_footer endRefreshingWithNoMoreData];
        }
    }
    [self.collectionView reloadData];
}

#pragma mark - Property method

- (UINavigationItem *)navigationItem {
    UINavigationItem *navigationItem = [super navigationItem];
    if (navigationItem.titleView == nil) {
        SYNavigationDropdownMenu *dropdownMenu = [[SYNavigationDropdownMenu alloc] initWithNavigationController:self.navigationController];
        dropdownMenu.dataSource = self;
        dropdownMenu.delegate = self;
        navigationItem.titleView = dropdownMenu;
    }
    return navigationItem;
}

- (UICollectionView *)collectionView {
    UICollectionView *collectionView = [super collectionView];
    if (collectionView.mj_header == nil) {
        MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(refreshMeizi)];
        header.automaticallyChangeAlpha = YES;
        collectionView.mj_header = header;
    }
    if (collectionView.mj_footer == nil) {
        MJRefreshAutoNormalFooter *footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreMeizi)];
        footer.automaticallyRefresh = YES;
        collectionView.mj_footer = footer;
    }
    return collectionView;
}

- (NSMutableArray *)meiziArray {
    if (_meiziArray == nil) {
        _meiziArray = [NSMutableArray arrayWithArray:[MeiziRequest cachedMeiziArrayWithCategory:MeiziCategoryAll]];
    }
    return _meiziArray;
}

- (void)setCategory:(MeiziCategory)category {
    _category = category;
    [self.meiziArray removeAllObjects];
    [self.meiziArray addObjectsFromArray:[MeiziRequest cachedMeiziArrayWithCategory:category]];
    [self.collectionView reloadData];
}

// Sprite Kit Example
- (void)shootOffSpriteKitStarFromView:(UIView *)view {
    CGPoint viewOrigin;
    
    viewOrigin.y = 0;
    viewOrigin.x = (view.frame.origin.x + (view.frame.size.width / 2)) / SCREEN_SCALE;
    
    UIView *containerView = [[UIView alloc] initWithFrame:self.view.bounds];
    containerView.userInteractionEnabled = NO;
    
    SKView *skView = [[SKView alloc] initWithFrame:containerView.frame];
    skView.allowsTransparency = YES;
    [containerView addSubview:skView];
    
    SKScene *skScene = [SKScene sceneWithSize:skView.frame.size];
    skScene.scaleMode = SKSceneScaleModeFill;
    skScene.backgroundColor = [UIColor clearColor];
    
    SKSpriteNode *starSprite = [SKSpriteNode spriteNodeWithImageNamed:@"filled_star"];
    [starSprite setScale:0.6];
    starSprite.position = viewOrigin;
    [skScene addChild:starSprite];
    
    SKEmitterNode *emitter =  [NSKeyedUnarchiver unarchiveObjectWithFile:[[NSBundle mainBundle] pathForResource:@"StarParticle" ofType:@"sks"]];
    SKEmitterNode *dotEmitter =  [NSKeyedUnarchiver unarchiveObjectWithFile:[[NSBundle mainBundle] pathForResource:@"AsteriskParticle" ofType:@"sks"]];
    
    [dotEmitter setParticlePosition:CGPointMake(0, -starSprite.size.height)];
    [emitter setParticlePosition:CGPointMake(0, -starSprite.size.height)];
    
    emitter.targetNode = skScene;
    dotEmitter.targetNode = skScene;
    
    [starSprite addChild:emitter];
    [starSprite addChild:dotEmitter];
    
    [skView presentScene:skScene];
    
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, viewOrigin.x, viewOrigin.y);
    
    CGPoint endPoint = CGPointMake(self.view.frame.size.width / 2, self.view.frame.size.height + 100);
    UIBezierPath *bp = [UIBezierPath new];
    [bp moveToPoint:viewOrigin];
    
    // curvy path
    // control points "pull" the curve to that point on the screen. You should be smarter then just using magic numbers like below.
    [bp addCurveToPoint:endPoint controlPoint1:CGPointMake(viewOrigin.x + 500, viewOrigin.y + 275) controlPoint2:CGPointMake(-200, skView.frame.size.height - 250)];
    
    __weak typeof(containerView) weakView = containerView;
    SKAction *followline = [SKAction followPath:bp.CGPath asOffset:YES orientToPath:YES duration:3.0];
    
    SKAction *done = [SKAction runBlock:^{
        // lets delay until all particles are removed
        int64_t delayInSeconds = 2.2;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [weakView removeFromSuperview];
        });
    }];
    
    [starSprite runAction:[SKAction sequence:@[followline, done]]];
    
    [self.view addSubview:containerView];
}



// Core Animation Example
- (void)shootOffCoreAnimationStarFromView:(UIView *)view {
    self.caStarImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"filled_star"]];
    self.caStarImageView.alpha = 1.0f;
    CGRect imageFrame = CGRectMake(self.caStarImageView.frame.origin.x, self.caStarImageView.frame.origin.y, 50, 50);
    
    //Your image frame.origin from where the animation need to get start
    CGPoint viewOrigin = self.caStarImageView.frame.origin;
    
    viewOrigin.y = self.view.frame.size.height;
    viewOrigin.x = (view.frame.origin.x + (view.frame.size.width / 2));
    
    self.caStarImageView.frame = imageFrame;
    self.caStarImageView.layer.position = viewOrigin;
    [self.view addSubview:self.caStarImageView];
    
    // need to rotate the image to get it on the right tangent
    self.caStarImageView.transform = CGAffineTransformMakeRotation(DEGREES_TO_RADIANS(90));
    
    // particles emitters
    self.caStarEmitter = [CAEmitterLayer new];
    self.caStarEmitter.emitterPosition = CGPointMake((self.caStarImageView.frame.size.width / 2) - 5, self.caStarImageView.frame.size.height);
    self.caStarEmitter.emitterShape = kCAEmitterLayerLine;
    self.caStarEmitter.emitterZPosition = 10; // 3;
    self.caStarEmitter.emitterSize = CGSizeMake(0.5, 0.5);
    
    CAEmitterCell *star = [self makeEmitterCellWithShape:0];
    CAEmitterCell *star2 = [self makeEmitterCellWithShape:0];
    CAEmitterCell *star3 = [self makeEmitterCellWithShape:0];
    
    CAEmitterCell *circle = [self makeEmitterCellWithShape:1];
    CAEmitterCell *circle2 = [self makeEmitterCellWithShape:1];
    CAEmitterCell *circle3 = [self makeEmitterCellWithShape:1];
    
    self.caStarEmitter.emitterCells = @[star, star2, star3, circle, circle2, circle3];
    [self.caStarImageView.layer addSublayer:self.caStarEmitter];
    
    // Set up fade out effect
    CABasicAnimation *fadeOutAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    [fadeOutAnimation setToValue:[NSNumber numberWithFloat:1.0]];
    fadeOutAnimation.fillMode = kCAFillModeForwards;
    fadeOutAnimation.removedOnCompletion = NO;
    
    // Set up path movement
    CAKeyframeAnimation *pathAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    pathAnimation.calculationMode = kCAAnimationCubicPaced;
    pathAnimation.fillMode = kCAFillModeForwards;
    pathAnimation.removedOnCompletion = NO;
    pathAnimation.rotationMode = kCAAnimationRotateAuto;
    
    //Setting Endpoint of the animation
    CGPoint endPoint = CGPointMake(self.view.frame.size.width, -100);
    UIBezierPath *bp = [UIBezierPath new];
    [bp moveToPoint:viewOrigin];
    
    // control points "pull" the curve to that point on the screen. You should be smarter then just using magic numbers like below.
    [bp addCurveToPoint:endPoint controlPoint1:CGPointMake(endPoint.x - 400, endPoint.y + 200) controlPoint2:endPoint];
    
    pathAnimation.path = bp.CGPath;
    
    CAAnimationGroup *group = [CAAnimationGroup animation];
    group.fillMode = kCAFillModeForwards;
    group.removedOnCompletion = NO;
    [group setAnimations:[NSArray arrayWithObjects:fadeOutAnimation, pathAnimation, nil]];
    group.duration = 2.3f;
    group.delegate = self;
    [group setValue:self.caStarImageView forKey:@"imageViewBeingAnimated"];
    
    [self.caStarImageView.layer addAnimation:group forKey:@"savingAnimation"];
}

- (CAEmitterCell *)makeEmitterCellWithShape:(NSInteger)shape {
    CAEmitterCell *cell = [CAEmitterCell new];
    cell.velocity = [self randFloatBetween:125 and:200];
    cell.velocityRange = [self randFloatBetween:15 and:40];
    cell.emissionLongitude = M_PI;
    cell.emissionRange = M_PI_4;
    cell.spin = 2;
    cell.spinRange = 10;
    cell.scale = 0.2;
    cell.scaleSpeed = -0.05;
    
    cell.lifetime = [self randFloatBetween:0.3 and:0.75];
    cell.lifetimeRange = [self randFloatBetween:0.6 and:1.5];
    
    if (shape == 0) {
        cell.color = [UIColor yellowColor].CGColor;
        cell.contents = (id)[[UIImage imageNamed:@"filled_star"] CGImage];
        cell.birthRate = 15;
    }
    else {
        cell.color = [UIColor orangeColor].CGColor;
        cell.contents = (id)[[UIImage imageNamed:@"asterisk_filled"] CGImage];
        cell.birthRate = 40;
    }
    
    return cell;
}

- (CGFloat)randFloatBetween:(float)low and:(float)high {
    float diff = high - low;
    return (((float) rand() / RAND_MAX) * diff) + low;
}

#pragma mark - CAAnimationGroup Delegate
- (void)animationDidStop:(CAAnimation *)animation finished:(BOOL)finished {
    if (finished) {
        // stop emitting particles, and wait a couple seconds so they all have time to disappear
        self.caStarEmitter.birthRate = 0;
        
        __weak typeof(self) weakSelf = self;
        int64_t delayInSeconds = 1.5;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [weakSelf.caStarImageView removeFromSuperview];
        });
    }
}


@end
