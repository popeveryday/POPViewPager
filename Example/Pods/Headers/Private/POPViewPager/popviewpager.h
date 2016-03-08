//
//  POPViewPager.h
//  Pods
//
//  Created by Trung Pham Hieu on 3/8/16.
//
//

#import <UIKit/UIKit.h>
#import <POPLib/POPLib.h>

@protocol POPViewPagerDelegate <NSObject>

-(NSArray*) popViewPagerReturnDatasource;
-(NSString*) popViewPagerReturnPageTileAtIndex:(NSInteger)pageIndex;
@optional
-(UIImage*) popViewPagerReturnPageIconAtIndex:(NSInteger)pageIndex;
-(UIImage*) popViewPagerReturnPageSelectedIconAtIndex:(NSInteger)pageIndex;


-(CGFloat) popViewPagerReturnCustomBarHeight; //default 35
-(UIColor*) popViewPagerReturnCustomBarColor; //default red
-(UIColor*) popViewPagerReturnCustomIndicatorBarColor; //default white
-(UIColor*) popViewPagerReturnCustomTitleColor; //default #5c0d09
-(UIColor*) popViewPagerReturnCustomSelectedTitleColor; //default white

@end

@interface POPViewPager : UIPageViewController

@end
