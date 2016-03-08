//
//  POPViewPager.m
//  Pods
//
//  Created by Trung Pham Hieu on 3/8/16.
//
//

#import "POPViewPager.h"

@interface POPViewPager ()<UIPageViewControllerDataSource, UIPageViewControllerDelegate, UIScrollViewDelegate>



@end

@implementation POPViewPager

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
}

-(void) viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    if (self.dataSource != nil) return;
    
    _pageDataSource = [self.popViewPagerDelegate popViewPagerReturnDatasource];
    
    self.dataSource = self;
    self.delegate = self;
    self.view.backgroundColor = [UIColor whiteColor];
    
    //fix navigation bar cover content
    self.navigationController.navigationBar.translucent = NO;
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)])
        self.edgesForExtendedLayout = UIRectEdgeNone;
    
    //get barheight
    CGFloat barHeight = 35;
    if (self.popViewPagerDelegate && [self.popViewPagerDelegate respondsToSelector:@selector(popViewPagerReturnCustomBarHeight)])
    {
        barHeight = [self.popViewPagerDelegate popViewPagerReturnCustomBarHeight];
    }
    
    //init buttonBar
    _buttonBarScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, GC_ScreenWidth, barHeight+5)];
    _buttonBarScrollView.userInteractionEnabled = YES;
    
    if (self.popViewPagerDelegate && [self.popViewPagerDelegate respondsToSelector:@selector(popViewPagerReturnCustomBarColor)])
    {
        _buttonBarScrollView.backgroundColor = [self.popViewPagerDelegate popViewPagerReturnCustomBarColor];
    }else{
        _buttonBarScrollView.backgroundColor = [CommonLib colorFromHexString:@"e62117" alpha:1];
    }
    
    
    [self.view addSubview:self.buttonBarScrollView];
    CGFloat buttonWidth = GC_ScreenWidth / self.pageDataSource.count;
    for (NSInteger i = 0; i < self.pageDataSource.count; i++) {
        UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(buttonWidth*i, 0, buttonWidth, barHeight);
        button.userInteractionEnabled = YES;
        button.backgroundColor = [UIColor clearColor];
        
        //button image if available
        if (self.popViewPagerDelegate && [self.popViewPagerDelegate respondsToSelector:@selector(popViewPagerReturnPageIconAtIndex:)])
        {
            [button setImage:[self.popViewPagerDelegate popViewPagerReturnPageIconAtIndex:i] forState:UIControlStateNormal];
            button.imageView.contentMode = UIViewContentModeBottom;
        }
        //button title if available
        else if (self.popViewPagerDelegate && [self.popViewPagerDelegate respondsToSelector:@selector(popViewPagerReturnPageTileAtIndex:)])
        {
            [button setTitle:[self.popViewPagerDelegate popViewPagerReturnPageTileAtIndex:i] forState:UIControlStateNormal];
            
            //button title color
            if (self.popViewPagerDelegate && [self.popViewPagerDelegate respondsToSelector:@selector(popViewPagerReturnCustomTitleColor)])
            {
                [button setTitleColor:[self.popViewPagerDelegate popViewPagerReturnCustomTitleColor] forState:UIControlStateNormal];
            }else{
                [button setTitleColor:[CommonLib colorFromHexString:@"5c0d09" alpha:1] forState:UIControlStateNormal];
            }
        }else{
            [button setTitle:[NSString stringWithFormat:@"%d", (int)i+1] forState:UIControlStateNormal];
        }
        
        button.tag = 1000+i;
        [button addTarget:self action:@selector(actionButton:) forControlEvents:UIControlEventTouchUpInside];
        [self.buttonBarScrollView addSubview:button];
    }
    
    //init indicator bar view
    _barIndicatorView = [[UIView alloc] initWithFrame:CGRectMake(0, barHeight+1, buttonWidth, 4)];
    _barIndicatorView.backgroundColor = [UIColor redColor];
    if (self.popViewPagerDelegate && [self.popViewPagerDelegate respondsToSelector:@selector(popViewPagerReturnCustomIndicatorBarColor)])
    {
        _barIndicatorView.backgroundColor = [self.popViewPagerDelegate popViewPagerReturnCustomIndicatorBarColor];
    }else{
        _barIndicatorView.backgroundColor = [CommonLib colorFromHexString:@"eeeeee" alpha:1];
    }
    
    [self.view addSubview:_barIndicatorView];
    
    _currentPageIndex = -1;
    [self displayPageWithIndex:0];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma action functions
-(void)actionButton:(id)sender
{
    [self displayPageWithIndex:((UIButton*)sender).tag - 1000];
}

-(void) displayPageWithIndex:(NSInteger)index
{
    if (self.currentPageIndex == index) return;
    
    [self setViewControllers:@[self.pageDataSource[index]] direction:self.currentPageIndex <= index? UIPageViewControllerNavigationDirectionForward : UIPageViewControllerNavigationDirectionReverse animated:YES completion:nil];
    [self updateIndicatorPositionWithIndex:index];
}

-(void) updateIndicatorPositionWithIndex:(NSInteger)index
{
    NSInteger lastIndex = _currentPageIndex;
    _currentPageIndex = index;
    
    [UIView animateWithDuration:0.25 animations:^{
        CGRect frame = self.barIndicatorView.frame;
        frame.origin.x = index * (GC_ScreenWidth/self.pageDataSource.count);
        self.barIndicatorView.frame = frame;
    } completion:^(BOOL finished) {
        if(!finished) return;
        if (self.popViewPagerDelegate && [self.popViewPagerDelegate respondsToSelector:@selector(popViewPagerReturnPageIconAtIndex:)] && [self.popViewPagerDelegate respondsToSelector:@selector(popViewPagerReturnPageSelectedIconAtIndex:)])
        {
            [((UIButton*)[self.buttonBarScrollView viewWithTag:index+1000]) setImage:[self.popViewPagerDelegate popViewPagerReturnPageSelectedIconAtIndex:lastIndex] forState:UIControlStateNormal];
            
            if(lastIndex == -1) return;
            [((UIButton*)[self.buttonBarScrollView viewWithTag:lastIndex+1000]) setImage:[self.popViewPagerDelegate popViewPagerReturnPageIconAtIndex:lastIndex] forState:UIControlStateNormal];
        }else{
            if (self.popViewPagerDelegate && [self.popViewPagerDelegate respondsToSelector:@selector(popViewPagerReturnCustomSelectedTitleColor)])
            {
                [((UIButton*)[self.buttonBarScrollView viewWithTag:index+1000]) setTitleColor:[self.popViewPagerDelegate popViewPagerReturnCustomSelectedTitleColor] forState:UIControlStateNormal];
            }else{
                [((UIButton*)[self.buttonBarScrollView viewWithTag:index+1000]) setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            }
            
            if(lastIndex == -1) return;
            
            if (self.popViewPagerDelegate && [self.popViewPagerDelegate respondsToSelector:@selector(popViewPagerReturnCustomTitleColor)])
            {
                [((UIButton*)[self.buttonBarScrollView viewWithTag:lastIndex+1000]) setTitleColor:[self.popViewPagerDelegate popViewPagerReturnCustomTitleColor] forState:UIControlStateNormal];
            }else{
                [((UIButton*)[self.buttonBarScrollView viewWithTag:lastIndex+1000]) setTitleColor:[CommonLib colorFromHexString:@"5c0d09" alpha:1] forState:UIControlStateNormal];
            }
        }
        
    }];
    
    
}

#pragma pageviewcontroller
- (nullable UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    NSInteger index = [self.pageDataSource indexOfObject:viewController];
    if (index == 0) return nil;
    return self.pageDataSource[index-1];
}
- (nullable UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    NSInteger index = viewController == nil ? 0 : [self.pageDataSource indexOfObject:viewController];
    if (index == self.pageDataSource.count - 1) return nil;
    return self.pageDataSource[index+1];
}

-(void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray<UIViewController *> *)previousViewControllers transitionCompleted:(BOOL)completed
{
    if(!finished) return;
    [self updateIndicatorPositionWithIndex:[self.pageDataSource indexOfObject:[self.viewControllers lastObject]]];
}

@end
