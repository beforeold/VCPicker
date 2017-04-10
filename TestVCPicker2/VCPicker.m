//
//  VCPicker.m
//  VCPicker
//
//  Created by Brook on 16/3/24.
//

#import "VCPicker.h"
#import <objc/runtime.h>

#pragma mark - FloatingView

static const CGFloat kDownLoadWidth = 60.f;
static const CGFloat kOffSet = 0.5*kDownLoadWidth;
typedef void (^FloatingBlock) ();

@interface FloatingView : UIView <UIDynamicAnimatorDelegate>

@property (nonatomic, assign) CGPoint startPoint;//触摸起始点
@property (nonatomic, assign) CGPoint endPoint;//触摸结束点
@property (nonatomic, strong) UIView *backgroundView;//背景视图
@property (nonatomic, strong) UIImageView *imageView;//图片视图
@property (nonatomic, strong) UIDynamicAnimator *animator;//物理仿真动画
@property (nonatomic, copy) FloatingBlock floatingBlock;

@end

@implementation FloatingView
// 初始化
- (instancetype)initWithFrame:(CGRect)frame{
    frame.size.width = kDownLoadWidth;
    frame.size.height = kDownLoadWidth;
    if (self = [super initWithFrame:frame]) {
        //初始化背景视图
        _backgroundView = [[UIView alloc] initWithFrame:CGRectMake(0,
                                                                  0,
                                                                  CGRectGetWidth(self.frame),
                                                                  CGRectGetHeight(self.frame))];
        _backgroundView.layer.cornerRadius = _backgroundView.frame.size.width / 2;
        _backgroundView.clipsToBounds = YES;
        _backgroundView.backgroundColor = [UIColor colorWithRed:35/255.0 green:167/255.0 blue:67/255.0 alpha:1];
        _backgroundView.userInteractionEnabled = NO;
        [self addSubview:_backgroundView];
        
        //初始化图片背景视图
        UIView * imageBackgroundView = [[UIView alloc] initWithFrame:CGRectMake(5, 5,
                                                                               CGRectGetWidth(self.frame) - 10,
                                                                               CGRectGetHeight(self.frame) - 10)];
        imageBackgroundView.layer.cornerRadius = imageBackgroundView.frame.size.width / 2;
        imageBackgroundView.clipsToBounds = YES;
        imageBackgroundView.backgroundColor = [UIColor colorWithRed:35/255.0 green:167/255.0 blue:67/255.0 alpha:1];
        imageBackgroundView.userInteractionEnabled = NO;
        imageBackgroundView.alpha = 0.7;
        [self addSubview:imageBackgroundView];
        //初始化图片
        UIImage *image = [[UIImage imageNamed:@"icon_tempMarkup"]
                                   imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        _imageView = [[UIImageView alloc] initWithImage:image];
        _imageView.tintColor = [UIColor whiteColor];
        _imageView.frame = CGRectMake(0, 0, 30, 30);
        _imageView.center = CGPointMake(kDownLoadWidth / 2 , kDownLoadWidth / 2);
        [self addSubview:_imageView];
        //将正方形的view变成圆形
        self.layer.cornerRadius = kDownLoadWidth / 2;
        self.alpha = 0.7;
        //开启呼吸动画
        [self highlightAnimation];
    }
    
    return self;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    //得到触摸点
    UITouch *startTouch = [touches anyObject];
    //返回触摸点坐标
    self.startPoint = [startTouch locationInView:self.superview];
    // 移除之前的所有行为
    [self.animator removeAllBehaviors];
}

// 触摸移动
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    //得到触摸点
    UITouch *startTouch = [touches anyObject];
    //将触摸点赋值给touchView的中心点 也就是根据触摸的位置实时修改view的位置
    self.center = [startTouch locationInView:self.superview];
}

// 结束触摸
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    //得到触摸结束点
    UITouch *endTouch = [touches anyObject];
    //返回触摸结束点
    self.endPoint = [endTouch locationInView:self.superview];
    //判断是否移动了视图 (误差范围5)
    CGFloat errorRange = 5;
    if (( self.endPoint.x - self.startPoint.x >= -errorRange &&
         self.endPoint.x - self.startPoint.x <= errorRange ) &&
        ( self.endPoint.y - self.startPoint.y >= -errorRange &&
         self.endPoint.y - self.startPoint.y <= errorRange ))
    {
        //未移动
        //调用打开下载视图控制器方法
        //Bob-> 打开控制器
        if (self.floatingBlock) {
            self.floatingBlock();
        }
        
    } else {
        //移动
        self.center = self.endPoint;
        //计算距离最近的边缘 吸附到边缘停靠
        CGFloat superwidth = self.superview.bounds.size.width;
        CGFloat superheight = self.superview.bounds.size.height;
        CGFloat endX = self.endPoint.x;
        CGFloat endY = self.endPoint.y;
        CGFloat topRange = endY;//上距离
        CGFloat bottomRange = superheight - endY;//下距离
        CGFloat leftRange = endX;//左距离
        CGFloat rightRange = superwidth - endX;//右距离
        //比较上下左右距离 取出最小值
        CGFloat minRangeTB = topRange > bottomRange ? bottomRange : topRange;//获取上下最小距离
        CGFloat minRangeLR = leftRange > rightRange ? rightRange : leftRange;//获取左右最小距离
        CGFloat minRange = minRangeTB > minRangeLR ? minRangeLR : minRangeTB;//获取最小距离
        //判断最小距离属于上下左右哪个方向 并设置该方向边缘的point属性
        CGPoint minPoint = CGPointZero;
        if (minRange == topRange) {
            //上
            endX = endX - kOffSet < 0 ? kOffSet : endX;
            endX = endX + kOffSet > superwidth ? superwidth - kOffSet : endX;
            minPoint = CGPointMake(endX , 0 + kOffSet);
        } else if(minRange == bottomRange){
            //下
            endX = endX - kOffSet < 0 ? kOffSet : endX;
            endX = endX + kOffSet > superwidth ? superwidth - kOffSet : endX;
            minPoint = CGPointMake(endX , superheight - kOffSet);
            
        } else if(minRange == leftRange){
            //左
            endY = endY - kOffSet < 0 ? kOffSet : endY;
            endY = endY + kOffSet > superheight ? superheight - kOffSet : endY;
            minPoint = CGPointMake(0 + kOffSet , endY);
            
        } else if(minRange == rightRange){
            //右
            endY = endY - kOffSet < 0 ? kOffSet : endY;
            endY = endY + kOffSet > superheight ? superheight - kOffSet : endY;
            minPoint = CGPointMake(superwidth - kOffSet , endY);
        }
        
        //添加吸附物理行为
        UIAttachmentBehavior *attachmentBehavior = [[UIAttachmentBehavior alloc] initWithItem:self
                                                                             attachedToAnchor:minPoint];
        [attachmentBehavior setLength:0];
        [attachmentBehavior setDamping:0.1];
        [attachmentBehavior setFrequency:5];
        [self.animator addBehavior:attachmentBehavior];
    }
}

// UIDynamicAnimatorDelegate
- (void)dynamicAnimatorDidPause:(UIDynamicAnimator *)animator{
    
}

// LazyLoading
- (UIDynamicAnimator *)animator {
    if (!_animator) {
        // 创建物理仿真器(ReferenceView : 仿真范围)
        _animator = [[UIDynamicAnimator alloc] initWithReferenceView:self.superview];
        _animator.delegate = self;
    }
    
    return _animator;
}

// BreathingAnimation 呼吸动画
- (void)highlightAnimation {
    [UIView animateWithDuration:1.5f
                     animations:^
     {
         self.backgroundView.backgroundColor = [self.backgroundView.backgroundColor colorWithAlphaComponent:0.1f];
     }
                     completion:^(BOOL finished)
     {
         [self highlightAnimation];
     }];
}

- (void)darkAnimation{
    [UIView animateWithDuration:1.5f
                     animations:^
     {
         self.backgroundView.backgroundColor = [self.backgroundView.backgroundColor colorWithAlphaComponent:0.6f];
     }
                     completion:^(BOOL finished)
     {
         [self highlightAnimation];
     }];
}

@end

#pragma mark - VCPickerCell
static NSString *const kNameKey = @"kNameKey";
static NSString *const kTitleKey = @"kTitleKey";
static NSString *const kErrorKey = @"kErrorKey";
@interface VCPickerCell : UITableViewCell

@property (nonatomic,   copy) void(^presentClick)(void);
@property (nonatomic,   copy) void(^presentNaviClick)(void);

- (void)updateUIWithModel:(NSDictionary *)model;

@end

@interface VCPickerCell()

@property (nonatomic, strong) UIButton *presentButton;
@property (nonatomic, strong) UIButton *presentNaviButton;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *detailLabel;
@property (nonatomic, strong) UILabel *errorLabel;

@property (nonatomic, strong) NSDictionary *model;

@end

@implementation VCPickerCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self) {
        [self.contentView addSubview:self.presentButton];
        [self.contentView addSubview:self.presentNaviButton];
        [self.contentView addSubview:self.titleLabel];
        [self.contentView addSubview:self.detailLabel];
        [self.contentView addSubview:self.errorLabel];
    }
    
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat buttonWidth = 45;
    CGFloat buttonPadding = 10;
    CGFloat horizontalMarigin = 15;
    CGFloat buttonVerticalMargin = 12;
    CGFloat presentNaviWidth = 0.01;
    CGFloat heightRatio = 0.75;
    CGFloat errorLabelWidth = 20;

    self.presentButton.frame = CGRectMake(horizontalMarigin,
                                          buttonVerticalMargin,
                                          buttonWidth,
                                          CGRectGetHeight(self.contentView.frame) - 2*buttonVerticalMargin);
    self.presentNaviButton.frame = CGRectMake(CGRectGetMaxX(self.presentButton.frame) + buttonPadding,
                                              buttonVerticalMargin,
                                              presentNaviWidth,
                                              CGRectGetHeight(self.contentView.frame) - 2*buttonVerticalMargin);
    
    self.errorLabel.frame = CGRectMake(CGRectGetWidth(self.contentView.frame) - horizontalMarigin - errorLabelWidth,
                                       (CGRectGetHeight(self.contentView.frame) - errorLabelWidth) *0.5,
                                       errorLabelWidth,
                                       errorLabelWidth);
    self.errorLabel.layer.cornerRadius = 0.5*errorLabelWidth;
    
    CGFloat titleX = CGRectGetMaxX(self.presentNaviButton.frame) + buttonPadding;
    CGFloat titleWidth = CGRectGetMinX(self.errorLabel.frame) - buttonPadding - titleX;
    self.titleLabel.frame = CGRectMake(titleX,
                                       0,
                                       titleWidth,
                                       self.contentView.frame.size.height*heightRatio);
    
    self.detailLabel.frame = CGRectMake(CGRectGetMinX(self.titleLabel.frame),
                                        CGRectGetMaxY(self.titleLabel.frame),
                                        CGRectGetWidth(self.titleLabel.frame),
                                        (1-heightRatio)*self.contentView.frame.size.height);
}

- (void)updateUIWithModel:(NSDictionary *)classInfo {
    _model = classInfo;
    
    NSString *classTitle = classInfo[kTitleKey];
    NSString *className = classInfo[kNameKey];
    NSString *classError = classInfo[kErrorKey];
    
    self.titleLabel.text = classTitle;
    self.detailLabel.text = className;
    self.errorLabel.text = classError ? @"i" : @">";
    UIColor *errorColor = [UIColor colorWithRed:255/255.0 green:70/255.0 blue:1/255.0 alpha:1];
    self.errorLabel.layer.backgroundColor = classError ? errorColor.CGColor : [UIColor whiteColor].CGColor;
    self.errorLabel.textColor = classError ? [UIColor whiteColor] : [UIColor grayColor];
}

- (UIButton *)presentButton {
    if (!_presentButton) {
        _presentButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _presentButton.titleLabel.font = [UIFont systemFontOfSize:11];
        _presentButton.backgroundColor = [UIColor colorWithRed:35/255.0 green:167/255.0 blue:67/255.0 alpha:1];
        _presentButton.layer.cornerRadius = 5.0;
        [_presentButton addTarget:self action:@selector(presentClick:) forControlEvents:UIControlEventTouchUpInside];
        [_presentButton setTitle:@"Pres" forState:UIControlStateNormal];
        [_presentButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }
    
    return _presentButton;
}

- (UIButton *)presentNaviButton {
    if (!_presentNaviButton) {
        _presentNaviButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _presentNaviButton.backgroundColor = [UIColor colorWithRed:35/255.0 green:167/255.0 blue:67/255.0 alpha:1];
        _presentNaviButton.layer.cornerRadius = 5.0;
        _presentNaviButton.titleLabel.font = [UIFont systemFontOfSize:10];
        [_presentNaviButton addTarget:self action:@selector(presentNaviClick:) forControlEvents:UIControlEventTouchUpInside];
        [_presentNaviButton setTitle:@"PresNavi" forState:UIControlStateNormal];
        [_presentNaviButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }
    
    return _presentNaviButton;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.numberOfLines = 0;
        _titleLabel.font = [UIFont systemFontOfSize:13];
    }
    return _titleLabel;
}

- (UILabel *)detailLabel {
    if (!_detailLabel) {
        _detailLabel = [[UILabel alloc] init];
        _detailLabel.numberOfLines = 0;
        _detailLabel.font = [UIFont systemFontOfSize:11];
        _detailLabel.textColor = [UIColor lightGrayColor];
    }
    return _detailLabel;
}

- (UILabel *)errorLabel {
    if (!_errorLabel) {
        _errorLabel = [[UILabel alloc] init];
        _errorLabel.numberOfLines = 0;
        _errorLabel.font = [UIFont systemFontOfSize:15];
        _errorLabel.textAlignment = NSTextAlignmentCenter;
        _errorLabel.userInteractionEnabled = YES;
        [_errorLabel addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                  action:@selector(errorClick:)]];
    }
    return _errorLabel;
}

- (void)presentClick:(UIButton *)button {
    if (self.presentClick) {
        self.presentClick();
    }
}

- (void)presentNaviClick:(UIButton *)button {
    if (self.presentNaviClick) {
        self.presentNaviClick();
    }
}

- (void)errorClick:(UITapGestureRecognizer *)tap {
    if (self.model[kErrorKey]) {
        NSString *title = [NSString stringWithFormat:@"ErrorClass %@ - %@", self.model[kTitleKey], self.model[kNameKey]];
        [[[UIAlertView alloc] initWithTitle:title
                                    message:self.model[kErrorKey]
                                   delegate:nil
                          cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }
}

@end


#pragma mark - VCPicker

/**
 *  floating view 悬浮球
 */
static FloatingView *_floatingView = nil;

/**
 *  class prefixes array 类名前缀
 */
static NSArray *_prefixArray = nil;

static NSArray *_exceptArray = nil;

/**
 *  has floating view shown 悬浮球是否已经显示
 */
static BOOL _hasShown = NO;

/**
 *  is VCPicker activated   是否已经激活
 */
static BOOL _isActivated = NO;

/**
 *  all possible viewcontroller classes 所有可能的ViewController类型
 */
static NSArray *_finalArray = nil;


static NSString *const kSearchHistoryKey = @"searchHistoryKey";


typedef NS_ENUM(NSInteger, VCShowType) {
    VCShowTypePush,
    VCShowTypePresent,
    VCShowTypePresentNavi
};


@interface VCPicker () <UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource>
{
    /**
     *  temp searched results 临时搜索到的数组
     */
    NSArray *_tempArray;
    
    /**
     *  history searched classes 历史搜索使用的数组
     */
    NSMutableArray *_historyArray;
}

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIButton *cancelButton;

@end


@implementation VCPicker
#pragma mark - Life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    UISearchBar *searchBar = [[UISearchBar alloc] init];
    searchBar.placeholder = NSLocalizedString(@"Search", nil);
    searchBar.delegate = self;
    self.navigationItem.titleView = searchBar;
    
    [self loadHistoryData];
    
    [self.view addSubview:self.cancelButton];
    [self.view addSubview:self.tableView];
}

// view appear to find all controllers
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self findAndShowControllers];
    [[self class] setCircleHidden:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    UISearchBar *searchBar = (UISearchBar *)self.navigationItem.titleView;
    [searchBar resignFirstResponder];
    
    [[self class] setCircleHidden:NO];
}

//layout tableview
- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    CGFloat buttonHeight = 40;
    CGFloat padding = 10;
    
    self.cancelButton.frame = CGRectMake(padding,
                                         CGRectGetHeight(self.view.bounds) - padding - buttonHeight,
                                         CGRectGetWidth(self.view.bounds) - 2*padding,
                                         buttonHeight);
    
    self.tableView.frame = CGRectMake(0,
                                      0,
                                      CGRectGetWidth(self.view.bounds),
                                      CGRectGetMinY(self.cancelButton.frame) - padding);
}

/**
 *  load history data 加载历史数据
 */
- (void)loadHistoryData {
    _historyArray = [[NSUserDefaults standardUserDefaults] objectForKey:kSearchHistoryKey];
    if (_historyArray) {
        _historyArray = [_historyArray mutableCopy];
        
        NSMutableArray *replaceArray = [NSMutableArray array];
        NSMutableIndexSet *replaceSet = [NSMutableIndexSet indexSet];
        
        NSMutableArray *copyArray = [NSMutableArray array];
        NSMutableIndexSet *copySet = [NSMutableIndexSet indexSet];
        for (NSDictionary *dic in _historyArray) {
            NSInteger index = [_historyArray indexOfObject:dic];
            if ([dic isKindOfClass:[NSString class]]) {
                NSMutableDictionary *newDic = [NSMutableDictionary dictionary];
                newDic[kTitleKey] = dic;
                newDic[kNameKey] = dic;
                
                [replaceSet addIndex:index];
                [replaceArray addObject:newDic];
                
            }else {
                NSMutableDictionary *newDic = [dic mutableCopy];
                [copySet addIndex:index];
                [copyArray addObject:newDic];
            }
        }
        [_historyArray replaceObjectsAtIndexes:replaceSet withObjects:replaceArray];
        [_historyArray replaceObjectsAtIndexes:copySet withObjects:copyArray];
        
    } else {
        _historyArray = [NSMutableArray array];
    }
}

/**
 *  cancel pick 取消使用
 */
- (void)pickCancel {
    [self dismissViewControllerAnimated:YES completion:nil];
}

/**
 *  lazy initializing tableview 懒加载
 */
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
    }
    
    return _tableView;
}

- (UIButton *)cancelButton {
    if (!_cancelButton) {
        _cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _cancelButton.backgroundColor = [UIColor colorWithRed:35/255.0 green:167/255.0 blue:67/255.0 alpha:1];
        _cancelButton.layer.cornerRadius = 7.0f;
        
        [_cancelButton addTarget:self action:@selector(pickCancel) forControlEvents:UIControlEventTouchUpInside];
        [_cancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
        [_cancelButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }
    
    return _cancelButton;
}

/**
 *  find and show all viewcontroller in this project
 *  \nNote: there are some UI classes can not be handled async
 *  \nNote: some special classes can't conform to NSObject protocol, so avoid them
 *  \nNote获取工程中所有的ViewController
 *  \nNote注意，这里还是不要用异步处理了，系统有少量UI类异步处理会报线程错误
 *  \nNote另外，部分特殊类不支持NSObject协议，需要手动剔除
 */
- (void)findAndShowControllers {
    if (!_finalArray) {
        NSArray *classNameArray = [self findViewControllers];
        NSMutableArray *array = [NSMutableArray array];
        for (NSString *className in classNameArray) {
            UIViewController *controller = nil;
            NSMutableDictionary *dic = [NSMutableDictionary dictionary];
            
            @try {
                controller = [[NSClassFromString(className) alloc] init]; // nil
                 [controller view]; // to active viewDidLoad so we can get conroller.title
                
            } @catch (NSException *exception) {
                NSLog(@"[VCPicker <%@> exception: %@]", className, exception);
                dic[kErrorKey] = exception.description;
                
            } @finally {
                dic[kNameKey] = className;
                NSString *title = nil;
                title = controller.title ?: (controller.navigationItem.title ?: (controller.tabBarItem.title ?: className));
                dic[kTitleKey] = title;
                [self refreshHistoryForControllerInfo:dic];
                [array addObject:dic];
            }
        }
        
        _finalArray = array;
    }
    
    _tempArray = _finalArray;
    
    [self handleMissingHistory];
    [self.tableView reloadData];
}

/**
 *  刷新历史数据信息
 *
 *  @param classInfo 传入的类信息
 */
- (void)refreshHistoryForControllerInfo:(NSDictionary *)classInfo {
    for (NSMutableDictionary *dic in _historyArray) {
        if ([dic[kNameKey] isEqualToString:classInfo[kNameKey]]) {
            dic[kTitleKey] = classInfo[kTitleKey];
            [self synchronizeHistory];
            break;
        }
    }
}

/**
 *  if some classes has gone remove it from history records
 *  如果有些类已经不存在，那么从历史记录中删除
 */
- (void)handleMissingHistory {
    NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSet];
    for (NSDictionary *dic in _historyArray) {
        BOOL isExist = NO;
        for (NSDictionary *finalDic in _finalArray) {
            if ([dic[kNameKey] isEqualToString:finalDic[kNameKey]]) {
                isExist = YES;
                break;
            }
        }
        if (!isExist) {
            [indexSet addIndex:[_historyArray indexOfObject:dic]];
        }
    }
    
    [_historyArray removeObjectsAtIndexes:indexSet];
}

#pragma mark - UITableViewDelegate && UITableViewDataSource
//history or search
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return section ? _tempArray.count : _historyArray.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return section ? @"Search ↓" : @"History ↓";
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 66;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"TestPickerCell";
    VCPickerCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (!cell) {
        cell = [[VCPickerCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        cell.textLabel.font = [UIFont systemFontOfSize:11];
    }
    
    NSArray *dataArray = indexPath.section ? _tempArray : _historyArray;
    NSDictionary *classInfo = dataArray[indexPath.row];
    [cell updateUIWithModel:classInfo];
    
    cell.presentClick = ^{
        [self saveAndShowController:classInfo showType:VCShowTypePresent];
    };
    
    cell.presentNaviClick = ^{
        [self saveAndShowController:classInfo showType:VCShowTypePresentNavi];
    };
    
    return cell;
}

//edit history
- (void)tableView:(UITableView *)tableView
        commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
        forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [_historyArray removeObjectAtIndex:indexPath.row];
    [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
    
    [self synchronizeHistory];
}

- (void)synchronizeHistory {
    [[NSUserDefaults standardUserDefaults] setObject:_historyArray forKey:kSearchHistoryKey];
}


//can only edit history
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return !indexPath.section;
}

// did select one ViewController and show it
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSArray *dataArray = indexPath.section ? _tempArray : _historyArray;
    NSDictionary *classInfo = dataArray[indexPath.row];
    
    [self saveAndShowController:classInfo showType:VCShowTypePresentNavi];
}

- (void)saveAndShowController:(NSDictionary *)controllerInfo showType:(VCShowType)showType {
    [self addHistoryRecord:controllerInfo];
    
    [self dismissViewControllerAnimated:YES completion:^{
        NSString *controllerName = controllerInfo[kNameKey];
        [self showViewController:controllerName showType:showType];
    }];
}


// hide the keyboard while scrolling
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    UISearchBar *searchBar = (UISearchBar *)self.navigationItem.titleView;
    [searchBar resignFirstResponder];
}

// add one history record, the same one will be avoied
- (void)addHistoryRecord:(NSDictionary *)dic {
    if (dic[kErrorKey]) {
        return;
    }
    
    NSInteger index = NSNotFound;
    for (NSMutableDictionary *history in _historyArray) {
        if ([dic[kNameKey] isEqualToString:history[kNameKey]]) {
            index = [_historyArray indexOfObject:history];
        }
    }
    
    if (index != NSNotFound) {
        [_historyArray removeObjectAtIndex:index];
    }
    
    [_historyArray insertObject:dic.mutableCopy atIndex:0];
    
    [self synchronizeHistory];
}

#pragma mark - UISearchBarDelegate
//find proper result while editing, ignore the upperCase of character
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    NSMutableArray *resultArray = [NSMutableArray array];
    for (NSDictionary *classInfo in _finalArray) {
        NSString *className = classInfo[kNameKey];
        NSString *classTitle = classInfo[kTitleKey];
        
        NSString *upperClassName = [className uppercaseString];
        NSString *upperSearchText = [searchText uppercaseString];
        
        NSRange rangeName = [upperClassName rangeOfString:upperSearchText];
        NSRange rangeTitle = [classTitle rangeOfString:searchText];
        
        BOOL isNameCompare = rangeName.location != NSNotFound;
        BOOL isTitleCompare = rangeTitle.location != NSNotFound;
        
        if (isNameCompare || isTitleCompare) {
            [resultArray addObject:classInfo];
        }
    }
    
    _tempArray = searchText.length ? resultArray : _finalArray;
    
    [self.tableView reloadData];
}

//click search just to hide the keyboard
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
}

#pragma mark - Picker

+ (void)activateWhenDebug {
    [self activateWithClassPrefixesWhenDebug:nil except:nil];
}

+ (void)activateWithClassPrefixesWhenDebug:(NSArray <NSString *> *)prefixes {
    [self activateWithClassPrefixesWhenDebug:prefixes except:nil];
}

+ (void)activateWithClassPrefixesWhenDebug:(NSArray *)prefixes except:(NSArray *)exceptArray {
    _isActivated = YES;
    [self showFinderWithClassPrefix:prefixes except:exceptArray];
}

/**
 *  获取当前工程内所有带有特定前缀prefix的控制器，在Release模式下该方法失效
 *
 *  @param prefixArray 前缀数组，比如 @[@"AB",@"ABC"]，可为nil
 */
+ (void)showFinderWithClassPrefix:(NSArray<NSString *> *)prefixArray except:(NSArray *)exceptArray {
#ifdef DEBUG
    if (_isActivated) {
        UIWindow *keyWindow = [self getMainWindow];
        if(!_hasShown && keyWindow) {
            _hasShown = YES;
            _prefixArray = prefixArray;
            _exceptArray = exceptArray;
            
            _floatingView = [[FloatingView alloc] initWithFrame:CGRectMake(CGRectGetWidth(keyWindow.frame) - 80 ,
                                                                           keyWindow.frame.size.height - 190,
                                                                           60,
                                                                           60)];
            _floatingView.backgroundColor = [UIColor clearColor];
            _floatingView.floatingBlock = ^{
                [self setCircleHidden:YES];
                [self showPickerController];
            };
        }
        
        [keyWindow addSubview:_floatingView];
    }
#endif
}

/**
 *  show VC picker 显示选择器
 */
+ (void)showPickerController {
    UIViewController *rootVC = [self getMainWindow].rootViewController;
    UIViewController *selfVC = [self new];
    UINavigationController *naviedPickerVC = [[UINavigationController alloc] initWithRootViewController:selfVC];
    naviedPickerVC.navigationBar.barStyle = UIBarStyleBlack;
    
    if (rootVC.presentedViewController) {
        [rootVC dismissViewControllerAnimated:YES completion:^{
            [rootVC presentViewController:naviedPickerVC animated:YES completion:nil];
        }];
    }else {
        [rootVC presentViewController:naviedPickerVC animated:YES completion:nil];
    }
}

- (void)dismissController {
    UIViewController *rootVC = [[self class] getMainWindow].rootViewController;
    [rootVC dismissViewControllerAnimated:YES completion:nil];
}

/**
 *  hide floatingView or not 设置是否隐藏悬浮球
 */
+ (void)setCircleHidden:(BOOL)hidden {
    _floatingView.hidden = hidden;
}


+ (UIWindow *)getMainWindow {
    id delegate = [UIApplication sharedApplication].delegate;
    
    return [delegate valueForKey:@"window"];
}

/**
 *  show some Controller 显示控制器页面
 *
 *  @param showType 显示类型
 */
- (void)showViewController:(NSString *)controllerName showType:(VCShowType)showType
{
    UIViewController *controller = [[NSClassFromString(controllerName) alloc] init];
    
    switch (showType) {
        case VCShowTypePush: {
            UIViewController *rootVC = [[self class] getMainWindow].rootViewController;
            
            if ([rootVC isKindOfClass:[UITabBarController class]]) {
                UITabBarController *tabbarVC = (UITabBarController *)rootVC;
                UINavigationController *naviVC = tabbarVC.selectedViewController;
                if ([naviVC isKindOfClass:[UINavigationController class]]) {
                    [naviVC pushViewController:controller animated:YES];
                }else {
                    UINavigationController *aNaviVC = [[UINavigationController alloc] initWithRootViewController:controller];
                    [naviVC presentViewController:aNaviVC animated:YES completion:nil];
                }
                
            }else if ([rootVC isKindOfClass:[UINavigationController class]]) {
                [((UINavigationController *)rootVC) pushViewController:controller animated:YES];
                
            }else {
                UINavigationController *reulstNavi = [[UINavigationController alloc] initWithRootViewController:controller];
                [rootVC presentViewController:reulstNavi animated:YES completion:nil];
            }
            break;
        }
            
        case VCShowTypePresent: {
            UIViewController *rootVC = [[self class] getMainWindow].rootViewController;
            [rootVC presentViewController:controller animated:YES completion:nil];
            break;
        }
            
        case VCShowTypePresentNavi: {
            UIViewController *rootVC = [[self class] getMainWindow].rootViewController;
            UIBarButtonItem *left = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                                  target:self
                                                                                  action:@selector(dismissController)];
            controller.navigationItem.leftBarButtonItem = left;
            UINavigationController *naviVC = [[UINavigationController alloc] initWithRootViewController:controller];
            [rootVC presentViewController:naviVC animated:YES completion:nil];
            break;
        }
    }
}

/**
 *  查找工程内的所有相关ViewController，浙江
 *  find all viewcontrollers, this will block the main thread
 *
 *  @return 控制器名字数组
 */
- (NSArray *)findViewControllers {
    Class *classes = NULL;
    int numClasses = objc_getClassList(NULL, 0);
    
    NSMutableArray *unSortedArray = [NSMutableArray array];
    if (numClasses > 0) {
        classes = (__unsafe_unretained Class *)malloc(sizeof(Class) * numClasses);
        numClasses = objc_getClassList(classes, numClasses);
        for (int i = 0; i < numClasses; i++) {
            Class theClass = classes[i];
            
            if (theClass == [self class]) continue;
            
            if (_prefixArray.count) {
                for (NSString *classPrefix in _prefixArray) {
                    NSString *className = [NSString stringWithUTF8String:class_getName(theClass)];
                    if ([className hasPrefix:classPrefix]) {
                        if ([theClass isSubclassOfClass:[UIViewController class]]) {
                            BOOL isExcept = NO;
                            for (NSString *except in _exceptArray) {
                                if ([className containsString:except]) {
                                    isExcept = YES;
                                    break;
                                }
                            }
                            if (!isExcept) [unSortedArray addObject:className];
                        }
                    }
                }
                
            }else {
                NSString *className = [NSString stringWithUTF8String:class_getName(theClass)];
                if ([className hasPrefix:@"UI"]) continue;
                if ([className hasPrefix:@"_UI"]) continue;
                if ([className hasPrefix:@"NS"]) continue;
                if ([className hasPrefix:@"_NS"]) continue;
                if ([className hasPrefix:@"__"]) continue;
                if ([className hasPrefix:@"_"]) continue;
                if ([className hasPrefix:@"CMKApplication"]) continue;
                if ([className hasPrefix:@"CMKCamera"]) continue;
                if ([className hasPrefix:@"DeferredPU"]) continue;
                if ([className hasPrefix:@"AB"]) continue; // 通讯录
                if ([className hasPrefix:@"MK"]) continue; // 地图
                if ([className hasPrefix:@"MF"]) continue; // Messag
                if ([className hasPrefix:@"CN"]) continue; // Messag
                if ([className hasPrefix:@"SSDK"]) continue; // Messag
                if ([className hasPrefix:@"SSP"]) continue; //
                if ([className hasPrefix:@"QL"]) continue; // AIRPlay
                if ([className hasPrefix:@"GSAuto"]) continue; // GS AutoMap
                
                BOOL isExcept = NO;
                for (NSString *except in _exceptArray) {
                    if ([className containsString:except]) {
                        isExcept = YES;
                        break;
                    }
                }
                if (isExcept) continue;
                
                if ([self isSpecialClass:className]) continue;
                
                if ([self getRootClassOfClass:theClass] == [NSObject class]) {
                    if ([theClass isSubclassOfClass:[UIViewController class]]) {
                        [unSortedArray addObject:className];
                    }
                }
            }
        }
        free(classes);
    }
    
    NSArray *finalArray = [unSortedArray sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [obj1 compare:obj2 options:NSForcedOrderingSearch];
    }];
    
    return finalArray;
}

/**
 *  判断是否为特殊的系统类
 *
 *  @param className 传入类名进行判断
 *
 *  @return YES为特殊类，NO不是
 */
- (BOOL)isSpecialClass:(NSString *)className {
    for (NSString *aClass in [self specialClassArray]) {
        if ([className isEqualToString:aClass]) {
            return YES;
        }
    }
    
    return NO;
}

/**
 *  一些特殊的系统类，不支持NSObject协议，需要手动剔除
 *
 */
- (NSArray *)specialClassArray {
    return @[@"JSExport", @"__NSMessageBuilder", @"Object", @"__ARCLite__", @"__NSAtom",
             @"__NSGenericDeallocHandler", @"_NSZombie_", @"CLTilesManagerClient",
             @"FigIrisAutoTrimmerMotionSampleExport", @"CNZombie", @"_CNZombie_",
             @"ABContactViewController", @"ABLabelPickerViewController",
             @"ABStarkContactViewController", @"CNContactContentViewController",
             @"CNContactViewServiceViewController", @"CNStarkContactViewController",
             @"MKActivityViewController", @"MKPlaceInfoViewController",
             @"CNUI", @"UISearchController"]; // UI的类在子线程访问有问题
}

/**
 *  获取类的根类
 *
 *  @param aClass 传入一个类
 *
 *  @return 获取根类
 */
- (Class)getRootClassOfClass:(Class)aClass {
    Class superClass = nil;
    if (aClass) {
        if ([aClass respondsToSelector:@selector(superclass)]) {
            superClass = [aClass superclass];
        }
        if (superClass == nil) {
            return aClass;
        }
    }else {
        return nil;
    }
    
    return [self getRootClassOfClass:superClass];
}

@end

#pragma mark - swizzle

@interface UIWindow (swizzle)
@end
@implementation UIWindow (swizzle)

#ifdef DEBUG
+ (void)load {
    [super load];
    
    [self swizzleSel:@selector(makeKeyAndVisible) withSel:@selector(swizzle_makeKeyAndVisiable)];
    [self swizzleSel:@selector(setRootViewController:) withSel:@selector(swizzle_setRootViewController:)];
}

+ (void)swizzleSel:(SEL)sel withSel:(SEL)swizzleSel {
    Method fromMethod = class_getInstanceMethod(self, sel);
    Method toMethod = class_getInstanceMethod(self, swizzleSel);
    method_exchangeImplementations(fromMethod, toMethod);
}

- (void)swizzle_makeKeyAndVisiable {
    [self swizzle_makeKeyAndVisiable];
    
    if (self == [VCPicker getMainWindow]) {
        [VCPicker showFinderWithClassPrefix:_exceptArray except:_exceptArray];
    }
}

- (void)swizzle_setRootViewController:(UIViewController *)rootViewController {
    [self swizzle_setRootViewController:rootViewController];
    
    if (self == [VCPicker getMainWindow]) {
        [VCPicker showFinderWithClassPrefix:_exceptArray except:_exceptArray];
    }
}
#endif

@end



