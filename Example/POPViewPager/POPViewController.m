//
//  POPViewController.m
//  POPViewPager
//
//  Created by popeveryday on 03/08/2016.
//  Copyright (c) 2016 popeveryday. All rights reserved.
//

#import "POPViewController.h"
#import "DetailTableVC.h"

@interface POPViewController ()<POPViewPagerDelegate>

@end

@implementation POPViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.popViewPagerDelegate = self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma POPViewPager delegate
-(NSArray *)popViewPagerReturnDatasource{
    return @[[DetailTableVC new],[DetailTableVC new],[DetailTableVC new],[DetailTableVC new]];
}

-(NSString *)popViewPagerReturnPageTileAtIndex:(NSInteger)pageIndex{
    return [NSString stringWithFormat:@"Page %02d", (int)pageIndex];
}

-(void) popViewPagerDidPageChangedWithIndex:(NSInteger)pageIndex{
    
}

//-(UIImage*) popViewPagerReturnPageIconAtIndex:(NSInteger)pageIndex{
//    return [UIImage imageNamed:@"more"];
//}
//
//-(UIImage*) popViewPagerReturnPageSelectedIconAtIndex:(NSInteger)pageIndex{
//    return [UIImage imageNamed:@"rate"];
//}

@end
