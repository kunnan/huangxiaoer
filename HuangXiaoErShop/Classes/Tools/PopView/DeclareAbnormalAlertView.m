//
//  DeclareAbnormalAlertView.m
//  iDeliver
//
//  Created by 蔡强 on 2017/4/3.
//  Copyright © 2017年 kuaijiankang. All rights reserved.
//

//========== 申报异常弹窗 ==========//

#import "DeclareAbnormalAlertView.h"
#import "UIColor+Util.h"
#import "UIView+frameAdjust.h"
#import "pickViewModel.h"

@interface DeclareAbnormalAlertView ()<UINavigationControllerDelegate,UIImagePickerControllerDelegate,UIPickerViewDelegate,UIPickerViewDataSource>

/** 弹窗主内容view */
@property (nonatomic,strong) UIView   *contentView;
/** 弹窗标题 */
@property (nonatomic,copy)   NSString *title;
/** 弹窗message */
@property (nonatomic,copy)   NSString *message;
/** message label */
@property (nonatomic,strong) UILabel  *messageLabel;
/** 左边按钮title */
@property (nonatomic,copy)   NSString *leftButtonTitle;
/** 右边按钮title */
@property (nonatomic,copy)   NSString *rightButtonTitle;

@property (nonatomic, strong) NSMutableArray *dataSource;

@end


@implementation DeclareAbnormalAlertView{
    UILabel *label;
}

- (NSMutableArray*)dataSource{
    
    if (!_dataSource) {
        _dataSource = [NSMutableArray arrayWithCapacity:0];
    }
    return _dataSource;
}
#pragma mark - 构造方法
/**
 申报异常弹窗的构造方法
 
 @param title 弹窗标题
 @param message 弹窗message
 @param delegate 确定代理方
 @param leftButtonTitle 左边按钮的title
 @param rightButtonTitle 右边按钮的title
 @return 一个申报异常的弹窗
 */
- (instancetype)initWithTitle:(NSString *)title message:(NSString *)message delegate:(id)delegate leftButtonTitle:(NSString *)leftButtonTitle rightButtonTitle:(NSString *)rightButtonTitle{
    if (self = [super init]) {
        self.title = title;
        self.message = message;
        self.delegate = delegate;
        self.leftButtonTitle = leftButtonTitle;
        self.rightButtonTitle = rightButtonTitle;
        
        // 接收键盘显示隐藏的通知
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHidden:) name:UIKeyboardWillHideNotification object:nil];
        
        // UI搭建
        [self setUpUI];
        [self requestData];
    }
    return self;
}

#pragma mark - UI搭建
/** UI搭建 */
- (void)setUpUI{
    self.frame = [UIScreen mainScreen].bounds;
    self.backgroundColor = [UIColor colorWithWhite:0.5 alpha:0.5];
    [UIView animateWithDuration:0.1 animations:^{
        self.alpha = 1;
    }];
    
    //------- 弹窗主内容 -------//
    self.contentView = [[UIView alloc]init];
    self.contentView.frame = CGRectMake((kScreenWidth - 285) / 2, (kScreenHeight - 215) / 2, 285, 260);
    self.contentView.center = self.center;
    [self addSubview:self.contentView];
    self.contentView.backgroundColor = [UIColor whiteColor];
    self.contentView.layer.cornerRadius = 6;
    
    
    
    // 标题
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 10, self.contentView.width, 22)];
    [self.contentView addSubview:titleLabel];
    titleLabel.font = [UIFont boldSystemFontOfSize:20];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.text = self.title;
    
    // 填写异常情况描述的textView
    self.textView = [[UITextView alloc]initWithFrame:CGRectMake(22, titleLabel.maxY + 10, self.contentView.width - 44, 180)];
    [self.contentView addSubview:self.textView];
    self.textView.layer.cornerRadius = 6;
    self.textView.backgroundColor = [UIColor whiteColor];
    
    UILabel *nameLable = [[UILabel alloc]initWithFrame:CGRectMake(10, 10, 50, 20)];
    nameLable.text = @"菜名:";
    [self.textView addSubview:nameLable];
    
    _nameTF = [[UITextField alloc]initWithFrame:CGRectMake(70, 10, 100, 20)];
    _nameTF.placeholder = @"请输入菜名";
    [self.textView addSubview:_nameTF];

    UILabel *numberLable = [[UILabel alloc]initWithFrame:CGRectMake(10, CGRectGetMaxY(nameLable.frame) + 10, 50, 20)];
    numberLable.text = @"数量:";
    [self.textView addSubview:numberLable];
    
    _numberTF = [[UITextField alloc]initWithFrame:CGRectMake(70, CGRectGetMaxY(nameLable.frame) + 10, 100, 20)];
    _numberTF.placeholder = @"请输入数量";
    [self.textView addSubview:_numberTF];
    
    UILabel *priceLable = [[UILabel alloc]initWithFrame:CGRectMake(10, CGRectGetMaxY(numberLable.frame) + 10, 50, 20)];
    priceLable.text = @"价格:";
    [self.textView addSubview:priceLable];
    
    _priceTF = [[UITextField alloc]initWithFrame:CGRectMake(70, CGRectGetMaxY(numberLable.frame) + 10, 100, 20)];
    _priceTF.placeholder = @"请输入价格";
    [self.textView addSubview:_priceTF];
    
    UILabel *categoryLable = [[UILabel alloc]initWithFrame:CGRectMake(10, CGRectGetMaxY(priceLable.frame) + 35, 50, 20)];
    categoryLable.text = @"分类:";
    [self.textView addSubview:categoryLable];
    
    _picker = [[UIPickerView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(priceLable.frame) + 15, 200, 60)];
    _picker.delegate = self;
    _picker.dataSource = self;
    [_picker reloadAllComponents];
    [self.textView addSubview:_picker];
    
    // textView里面的占位label
    self.messageLabel = [[UILabel alloc]initWithFrame:CGRectMake(8, 8, self.textView.width - 16, self.textView.height - 16)];
   // self.messageLabel.text = self.message;
    self.messageLabel.numberOfLines = 0;
    self.messageLabel.font = [UIFont systemFontOfSize:12];
    self.messageLabel.textColor = [UIColor colorWithHexString:@"484848"];
    [self.messageLabel sizeToFit];
    [self.textView addSubview:self.messageLabel];
    
    // 红色提示label
    UILabel *redLabel = [[UILabel alloc]initWithFrame:CGRectMake(self.textView.x, self.textView.maxY + 5, self.textView.width, 20)];
    [self.contentView addSubview:redLabel];
    redLabel.textColor = [UIColor colorWithHexString:@"d51619"];
    redLabel.font = [UIFont systemFontOfSize:12];
    redLabel.numberOfLines = 0;
    [redLabel sizeToFit];
    
    // 确定按钮
    UIButton *abnormalButton = [[UIButton alloc]initWithFrame:CGRectMake(self.textView.minX, redLabel.maxY + 5, 100, 40)];
    [self.contentView addSubview:abnormalButton];
    abnormalButton.backgroundColor = [UIColor colorWithHexString:@"d51619"];
    [abnormalButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [abnormalButton setTitle:@"确定" forState:UIControlStateNormal];
    [abnormalButton.titleLabel setFont:[UIFont systemFontOfSize:18]];
    abnormalButton.layer.cornerRadius = 6;
    [abnormalButton addTarget:self action:@selector(abnormalButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    
    // 取消按钮
    UIButton *cancelButton = [[UIButton alloc]initWithFrame:CGRectMake(self.textView.maxX - 100, abnormalButton.minY, 100, 40)];
    [self.contentView addSubview:cancelButton];
    [cancelButton setTitle:@"取消" forState:UIControlStateNormal];
    cancelButton.backgroundColor = [UIColor colorWithHexString:@"c8c8c8"];
    [cancelButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [cancelButton.titleLabel setFont:[UIFont systemFontOfSize:18]];
    cancelButton.layer.cornerRadius = 6;
    [cancelButton addTarget:self action:@selector(cancelButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    
    //------- 调整弹窗高度和中心 -------//
    self.contentView.height = cancelButton.maxY + 10;
    self.contentView.center = self.center;
    
}

- (void)requestData{
    
    NSDictionary *partner = @{
                              @"token": KUSERID
                              };
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json",@"text/json", @"text/javascript",@"text/html", nil];
    
    [manager POST:[NSString stringWithFormat:@"%@/appproduct/category/findall",HXECOMMEN] parameters:partner progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
      //  NSLog(@"%@",responseObject);
        NSArray *arr = responseObject[@"data"];
        for (NSDictionary *dic in arr) {
            pickViewModel *model = [[pickViewModel alloc]init];
            [model setValuesForKeysWithDictionary:dic];
            [self.dataSource addObject:model];
            NSLog(@"%@=======%@",model.name,model.id);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
    }];
    
    
}


- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    
    return 1;
    
}
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    
    return self.dataSource.count;
    
}


- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    pickViewModel *model = self.dataSource[row];
    NSLog(@"%@",model.name);
    return [NSString stringWithFormat:@"%@%@",model.name,model.id];
    
  //  return [NSString stringWithFormat:@"%ld%ld",component,row];
}

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component{
    
    return 150;
    
}
- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component{
    
    return 30;
    
}


#pragma mark - 弹出此弹窗
/** 弹出此弹窗 */
- (void)show{
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    [keyWindow addSubview:self];
}

#pragma mark - 移除此弹窗
/** 移除此弹窗 */
- (void)dismiss{
    [self removeFromSuperview];
}

#pragma mark - 申报异常按钮点击
/** 申报异常按钮点击 */
- (void)abnormalButtonClicked{
    if ([self.delegate respondsToSelector:@selector(declareAbnormalAlertView:clickedButtonAtIndex:)]) {
        [self.delegate declareAbnormalAlertView:self clickedButtonAtIndex:AlertButtonLeft];
    }
    NSString *string = _nameTF.text;
    
    NSLog(@"%@",string);
    [self dismiss];
}

#pragma mark - 取消按钮点击
/** 取消按钮点击 */
- (void)cancelButtonClicked{
    if ([self.delegate respondsToSelector:@selector(declareAbnormalAlertView:clickedButtonAtIndex:)]) {
        [self.delegate declareAbnormalAlertView:self clickedButtonAtIndex:AlertButtonRight];
    }
    [self dismiss];
}

#pragma mark - UITextView代理方法
- (void)textViewDidChange:(UITextView *)textView{
    if ([textView.text isEqualToString:@""]) {
        self.messageLabel.hidden = NO;
    }else{
        self.messageLabel.hidden = YES;
    }
}


/**
 *  键盘将要显示
 *
 *  @param notification 通知
 */
-(void)keyboardWillShow:(NSNotification *)notification
{
    // 获取到了键盘frame
    CGRect frame = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat keyboardHeight = frame.size.height;
    
    self.contentView.maxY = kScreenHeight - keyboardHeight - 10;
}
/**
 *  键盘将要隐藏
 *
 *  @param notification 通知
 */
-(void)keyboardWillHidden:(NSNotification *)notification
{
    // 弹窗回到屏幕正中
    self.contentView.centerY = kScreenHeight / 2;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.textView resignFirstResponder];
}

@end
