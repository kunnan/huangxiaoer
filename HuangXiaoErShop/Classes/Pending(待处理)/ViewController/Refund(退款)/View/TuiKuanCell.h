//
//  TuiKuanCell.h
//  HXEshop
//
//  Created by apple on 2018/3/11.
//  Copyright © 2018年 aladdin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CellModel.h"


typedef void(^TuiKuanBlock)(NSInteger index, NSInteger btnTag);

@interface TuiKuanCell : UITableViewCell


- (void)cellViewsValueWithModel:(CellModel *)model;

@property (nonatomic, assign) NSInteger index;

@property (weak, nonatomic) IBOutlet UILabel *nameLb;

@property (weak, nonatomic) IBOutlet UIView *addView;

@property (weak, nonatomic) IBOutlet UILabel *bzLb;

@property (weak, nonatomic) IBOutlet UILabel *timeLb;
@property (weak, nonatomic) IBOutlet UILabel *priceLb;

@property (nonatomic, copy) TuiKuanBlock block;

@property (weak, nonatomic) IBOutlet UIButton *judabBt;
@property (weak, nonatomic) IBOutlet UIButton *jiedanBT;


@end
