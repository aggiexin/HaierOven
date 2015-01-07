//
//  CreatMneuController.m
//  HaierOven
//
//  Created by dongl on 14/12/29.
//  Copyright (c) 2014年 edaysoft. All rights reserved.
//

#import "CreatMneuController.h"
#import "CoverCell.h"
#import "ChooseTagsCell.h"
#import "AutoSizeLabelView.h"
#import "CellOfAddFoodTable.h"
#import "AddFoodAlertView.h"
#import "UseDeviceCell.h"
#import "AddStepCell.h"
#import "ChooseCoverView.h"
#import "YIPopupTextView.h"
#import "BottomCell.h"
@interface CreatMneuController ()<AutoSizeLabelViewDelegate,CellOfAddFoodTableDelegate,AddFoodAlertViewDelegate,AddStepCellDelegate,ChooseCoverViewDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,YIPopupTextViewDelegate,CoverCellDelegate>
@property (strong, nonatomic) NSMutableArray *foods;
@property (strong, nonatomic) UIWindow *myWindow;
@property (strong, nonatomic) AddFoodAlertView *addFoodAlertView;
@property (strong, nonatomic) NSMutableArray *steps;
@property (strong, nonatomic) ChooseCoverView  *chooseCoverView;
@property (strong, nonatomic) UIImageView *tempImageView; //记录 添加步骤 delegate 上来的图片
@property (strong, nonatomic) UILabel *tempLabel; //记录 添加步骤 delegate 上来的图片
@property (strong, nonatomic) NSString *myPs_String;
@property (strong, nonatomic) AutoSizeLabelView *tagsView;
@property float tagsCellHight;
@property float psCellHight;
@property (strong, nonatomic) NSMutableArray*  tagsForTagsView;
@property (strong, nonatomic) NSMutableArray* selectedTags;

@property BOOL ischangeCover;

/**
 *  当前编辑的步骤
 */
@property (strong, nonatomic) Step* edittingStep;

/**
 *  当前编辑的食材
 */
@property (strong, nonatomic) Food* edittingFood;



#pragma mark - outlets


@end
#define PADDING_WIDE    15   //标签左右间距
#define PADDING_HIGHT    8   //标签上下间距
#define LABEL_H    20   //标签high

@implementation CreatMneuController

#pragma mark - 加载系列

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        self.tags = [NSMutableArray array];
        self.selectedTags = [NSMutableArray array];
        
        self.foods = [NSMutableArray new];
        self.steps = [NSMutableArray new];
        
        Step* step = [[Step alloc] init];
        
        [self.steps addObject:step];
        
        step.index = [NSString stringWithFormat:@"%d", self.steps.count];
        
        Food* food = [[Food alloc] init];
        [self.foods addObject:food];
        food.index = [NSString stringWithFormat:@"%d", self.foods.count];
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self SetUpSubviews];
//    [self loadTags];
}



-(void)SetUpSubviews{
    
//    self.tags =  [@[@"烘焙",@"蒸菜",@"微波炉",@"巧克力",@"面包",@"饼干海鲜",@"有五个字呢",@"四个字呢",@"三个字呢",@"没规律呢",@"都能识别的呢",@"鱼",@"零食",@"早点",@"海鲜"] mutableCopy];
    self.tagsForTagsView = [NSMutableArray array];
    for (Tag* tag in self.tags) {
        [self.tagsForTagsView addObject:tag.name];
    }
    
    self.tagsCellHight = [self getHeight];
    self.psCellHight = 210;
    
//    self.tagsView = [AutoSizeLabelView new];
//    self.tagsView.tags = [self.tags copy];
//    
    
    

    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([CellOfAddFoodTable class]) bundle:nil] forCellReuseIdentifier:@"CellOfAddFoodTable"];
    
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([AddStepCell class]) bundle:nil] forCellReuseIdentifier:@"AddStepCell"];
    
    
    self.myWindow = [UIWindow new];
    self.myWindow.frame = CGRectMake(0, 0, PageW, PageH);
    self.myWindow.backgroundColor = [UIColor colorWithRed:0/255 green:0/255 blue:0/255 alpha:0.3];
    self.myWindow.windowLevel = UIWindowLevelAlert;
    [self.myWindow makeKeyAndVisible];
    self.myWindow.userInteractionEnabled = YES;
    self.myWindow.hidden = YES;
    
    self.addFoodAlertView = [[AddFoodAlertView alloc]initWithFrame:CGRectMake(0, 0, PageW-30, 138)];
    self.addFoodAlertView.delegate = self;
    [self.myWindow addSubview:self.addFoodAlertView];
    
    self.chooseCoverView = [[ChooseCoverView alloc]initWithFrame:CGRectMake(0, PageH, PageW, PageW*0.58)];
    self.chooseCoverView.delegate = self;
    [self.myWindow addSubview:self.chooseCoverView];

}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - 显示系列

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 6;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
        if (indexPath.row ==0) {
            CoverCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CoverCell" forIndexPath:indexPath];
            cell.delegate = self;
            cell.coverImage = self.cookbookCoverPhoto;
            return cell;
            
        }else if(indexPath.row ==1)  {
            ChooseTagsCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ChooseTagsCell" forIndexPath:indexPath];
            cell.tagsView.delegate = self;
            cell.cookName.text = self.cookbookDetail.name;
            if (!self.tagsView) {
                cell.tagsView.tags = self.tagsForTagsView;
                self.tagsView = cell.tagsView;
            }
//            cell.tagsView = self.tagsView;
            return cell;
            
        }else if(indexPath.row == 2){
            CellOfAddFoodTable *cell = [tableView dequeueReusableCellWithIdentifier:@"CellOfAddFoodTable" forIndexPath:indexPath];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.foods = [self.foods mutableCopy];
            cell.delegate = self;

            return cell;
        }else if(indexPath.row ==3){
            UseDeviceCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UseDeviceCell" forIndexPath:indexPath];
            return cell;
        }else if(indexPath.row == 4){
            AddStepCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AddStepCell" forIndexPath:indexPath];
            cell.steps = self.steps;
            cell.delegate = self;
            return cell;
        }else {
            BottomCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BottomCell" forIndexPath:indexPath];
            if (self.myPs_String.length >0 )
                cell.myPS_String = self.myPs_String;
            
            return cell;
        }
    // Configure the cell...    
}




-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    switch (indexPath.row) {
        case 0:
            return PageW*0.598;
            break;
        case 1:
            return self.tagsCellHight;
            break;
        case 2:
            return (PageW-16)*0.13*(self.foods.count+1)+51;
            break;
        case 3:
            return 80;
            break;
        case 4:
            return (PageW - 60)*0.58*(self.steps.count)+80;
            break;
            
        default:

            return self.psCellHight;
            break;
    }
}




#pragma mark- 添加食材cell delegate
-(void)reloadMainTableView:(NSMutableArray *)arr{
    self.foods = [arr mutableCopy];
    CGPoint point = self.tableView.contentOffset;

    [UIView animateWithDuration:0.3 animations:^{self.tableView.contentOffset = CGPointMake(0, point.y+(PageW-16)*0.13);
    }completion:nil];
    [self.tableView reloadData];
}
-(void)ImportAlertView:(UILabel *)label withFoodIndex:(NSInteger)foodIndex
{
    self.edittingFood = self.foods[foodIndex];
    self.addFoodAlertView.addFoodAlertType = label.tag;
    self.addFoodAlertView.label = label;
    self.myWindow.hidden = NO;
}
#pragma mark - 

- (IBAction)TurnBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - 添加步骤cell delegate
-(void)AddStepOfMainTableView:(NSMutableArray *)arr{
    
    self.steps = [arr mutableCopy];
    CGPoint point = self.tableView.contentOffset;
    
    [UIView animateWithDuration:0.6 animations:^{self.tableView.contentOffset = CGPointMake(0, point.y+(PageW - 60)*0.58);
    }completion:nil];
    [self.tableView reloadData];
    
}
-(void)DeleteStepOfMainTableView:(NSMutableArray *)arr
{
    self.steps = [arr mutableCopy];
    CGPoint point = self.tableView.contentOffset;
    
    [UIView animateWithDuration:0.6 animations:^{self.tableView.contentOffset = CGPointMake(0, point.y-(PageW - 60)*0.58);
    }completion:nil];
    [self.tableView reloadData];
}


-(void)ImportStepDescription:(UILabel *)label withStepIndex:(NSInteger)index{
    self.edittingStep = self.steps[index];
    //添加表述
    YIPopupTextView* popupTextView =
    [[YIPopupTextView alloc] initWithPlaceHolder:nil
                                        maxCount:120
                                     buttonStyle:YIPopupTextViewButtonStyleRightCancelAndDone];
    popupTextView.delegate = self;
    popupTextView.caretShiftGestureEnabled = YES;       // default = NO. using YISwipeShiftCaret is recommended.
    popupTextView.editable = YES;                  // set editable=NO to show without keyboard
    popupTextView.outerBackgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
    [popupTextView showInViewController:self];
    popupTextView.tag = 1;
    popupTextView.text = [label.text isEqualToString:@"文字说明"]?@"":label.text;
    self.tempLabel = label;
    NSLog(@"添加步骤描述");
}

- (void)popupTextView:(YIPopupTextView *)textView didDismissWithText:(NSString *)text cancelled:(BOOL)cancelled
{
    if (cancelled) {
        NSLog(@"取消评论了");
    } else {
        if (text.length == 0) {
            return;
        }else{
            if (textView.tag ==1) {
                self.tempLabel.text = text;
                self.tempLabel.textColor = [UIColor blackColor];
                self.edittingStep.desc = text;
            }else if (textView.tag==2){
                self.myPs_String = text;
                CGSize size = CGSizeZero;
                size = [MyUtils getTextSizeWithText:self.myPs_String andTextAttribute:@{NSFontAttributeName :[UIFont fontWithName:GlobalTitleFontName size:15]} andTextWidth:self.tableView.width-100];
                size.height = size.height<18?18:size.height;
                self.psCellHight =size.height+145;
            
                [self.tableView reloadData];
                
            }
        }
    }
}

-(void)AddStepImage:(UIImageView *)imageView withStepIndex:(NSInteger)index{
    self.edittingStep = self.steps[index];
    NSLog(@"添加图片");
    self.myWindow.hidden = NO;
    self.addFoodAlertView.hidden = YES;
    self.tempImageView = imageView;
    [UIView animateWithDuration:0.3 animations:^{[self.chooseCoverView setFrame:CGRectMake(0, PageH-PageW*0.58, PageW, PageW*0.58)];
    }completion:nil];
}

-(void)TakeCover:(NSInteger)tag{
    [UIView animateWithDuration:0.3 animations:^{[self.chooseCoverView setFrame:CGRectMake(0, PageH, PageW, PageW*0.58)];
    }completion:^(BOOL finished) {
        self.myWindow.hidden = YES;
        self.addFoodAlertView.hidden = NO;
        if (tag == 1) {
            if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
                UIImagePickerController * picker = [[UIImagePickerController alloc]init];
                picker.sourceType=UIImagePickerControllerSourceTypeCamera;
                picker.allowsEditing = YES;  //是否可编辑
                picker.delegate = self;
                picker.videoQuality = UIImagePickerControllerQualityTypeHigh;
                //摄像头
                picker.sourceType = UIImagePickerControllerSourceTypeCamera;
                [self presentViewController:picker animated:YES completion:nil];
                
            }else{
                //如果没有提示用户
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"你没有摄像头" delegate:nil cancelButtonTitle:@"Drat!" otherButtonTitles:nil];
                [alert show];
            }
            
        }else if (tag == 2) {
            UIImagePickerController *pickerImage = [[UIImagePickerController alloc] init];
            if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
                pickerImage.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                //pickerImage.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
                pickerImage.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:pickerImage.sourceType];
                
            }
            pickerImage.delegate = self;
            pickerImage.allowsEditing = NO;
            [self presentViewController:pickerImage animated:YES completion:nil];
        }
        
    }];
}


- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    
    UIImage *image =[info objectForKey:UIImagePickerControllerOriginalImage];
    [picker dismissViewControllerAnimated:YES completion:nil];
    NSData* imageData = UIImageJPEGRepresentation(image, 0.6);
    
    [super showProgressHUDWithLabelText:@"请稍后..." dimBackground:NO];
    
    if (self.ischangeCover) {
        self.cookbookCoverPhoto = image;
        
        [self.tableView reloadData];
    }else {
        self.tempImageView.image = image;
        [[InternetManager sharedManager] uploadFile:imageData callBack:^(BOOL success, id obj, NSError *error) {
            [super hiddenProgressHUD];
            if (success) {
                NSDictionary* objDict = [obj firstObject];
                self.edittingStep.photo = objDict[@"name"];
                
            } else {
                if (error.code == InternetErrorCodeConnectInternetFailed) {
                    [super showProgressErrorWithLabelText:@"网络连接失败" afterDelay:1];
                } else {
                    [super showProgressErrorWithLabelText:@"上传失败，请重试" afterDelay:1];
                }
            }
        }];
    }
    

}

#pragma mark-


#pragma mark- 自动标签delegate
-(void)chooseTags:(UIButton*)btn{
    
    
    Tag* theTag = [self.tags objectAtIndex:btn.tag];
    
    if (!btn.selected) {
        if (self.selectedTags.count > 2) {
            [super showProgressErrorWithLabelText:@"不能超过三个" afterDelay:1];
            btn.selected = NO;
            return;
        }
        [self.selectedTags addObject:theTag];
        
    } else {
        [self.selectedTags removeObject:theTag];
    }
    btn.selected = btn.selected ==YES?NO:YES;
    NSLog(@"%d",btn.tag);
}
#pragma mark-

-(float)getHeight{
    float leftpadding = 0;
    int line = 1;
    int count = 0;
    for (int i = 0; i<self.tagsForTagsView.count; i++) {
        float wide  =  [AutoSizeLabelView boolLabelLength:self.tagsForTagsView[i] andAttribute:@{NSFontAttributeName: [UIFont fontWithName:GlobalTextFontName size:14]}]+20;
        
        if (leftpadding+wide+PADDING_WIDE*count>PageW-90) {
            leftpadding=0;
            ++line;
            count = 0;
        }
        
        leftpadding +=wide;
        count++;
    }
    
    return (PADDING_HIGHT+LABEL_H)*line+75;
}


#pragma mark- AddFoodAlertView 弹出框delegate
-(void)Cancel{
    self.myWindow.hidden = YES;
}

-(void)ChickAlert:(UILabel *)label andTextFailed:(UITextField *)textfield{
    self.myWindow.hidden = YES;
    [textfield resignFirstResponder];
    
    if (label.tag == 2) {
        self.edittingFood.name = label.text;
    }
    if (label.tag == 1) {
        self.edittingFood.desc = label.text;
    }

    
}
#pragma mark -

#pragma mark - 我使用了烤箱
- (IBAction)UseDevice:(id)sender {
    NSLog(@"我使用了烤箱");
}

#pragma mark -


- (IBAction)AddPS:(id)sender {
    YIPopupTextView* popupTextView =
    [[YIPopupTextView alloc] initWithPlaceHolder:nil
                                        maxCount:120
                                     buttonStyle:YIPopupTextViewButtonStyleRightCancelAndDone];
    popupTextView.delegate = self;
    popupTextView.caretShiftGestureEnabled = YES;       // default = NO. using YISwipeShiftCaret is recommended.
    popupTextView.editable = YES;                  // set editable=NO to show without keyboard
    popupTextView.outerBackgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
    [popupTextView showInViewController:self];
    popupTextView.tag = 2;
    popupTextView.text = self.myPs_String;
}

- (IBAction)SaveToDraft:(id)sender {
    NSLog(@"存存存");
    self.cookbookDetail.status = @"0";
    [self submitCookbook];
}

- (IBAction)Public:(id)sender {
    NSLog(@"发发发布");
    self.cookbookDetail.status = @"1";
    [self submitCookbook];
}

- (void)submitCookbook
{
    self.cookbookDetail.tags = self.selectedTags;
    self.cookbookDetail.steps = self.steps;
//    self.cookbookDetail.foods = self.foods;
//    Food* food = [[Food alloc] init];
//    food.index = @"0";
//    food.name = @"猪肉";
//    food.desc = @"500 g";
//    self.foods = [NSMutableArray array];
//    [self.foods addObject:food];
    self.cookbookDetail.foods = self.foods;
    self.cookbookDetail.cookbookTip = @"用心就好";
    self.cookbookDetail.oven = [[CookbookOven alloc] init];
    self.cookbookDetail.creator = [[Creator alloc] init];
    self.cookbookDetail.creator.ID = @"5";
    
    [[InternetManager sharedManager] addCookbookWithCookbook:self.cookbookDetail callBack:^(BOOL success, id obj, NSError *error) {
        if (success) {
            NSLog(@"发布成功");
        }
    }];
}

#pragma mark- 点击编辑图片
-(void)changeCover{
    self.myWindow.hidden = NO;
    self.addFoodAlertView.hidden = YES;
    self.ischangeCover = YES;
    [UIView animateWithDuration:0.3 animations:^{[self.chooseCoverView setFrame:CGRectMake(0, PageH-PageW*0.58, PageW, PageW*0.58)];
    }completion:nil];
    
}


@end
