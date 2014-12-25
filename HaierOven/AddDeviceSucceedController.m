//
//  AddDeviceSucceedController.m
//  HaierOven
//
//  Created by dongl on 14/12/23.
//  Copyright (c) 2014年 edaysoft. All rights reserved.
//

#import "AddDeviceSucceedController.h"

@interface AddDeviceSucceedController ()
@property (strong, nonatomic) IBOutlet UITextField *deviceTextFailed;
@property (strong, nonatomic) IBOutlet UIButton *chickBtn;

@end

@implementation AddDeviceSucceedController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    [self SetUpSubViews];
    // Do any additional setup after loading the view.
}
-(void)SetUpSubViews{
    
    [[NSNotificationCenter defaultCenter] addObserver:self
     
                                             selector:@selector(keyboardWillShow:)
     
                                                 name:UIKeyboardWillShowNotification
     
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
     
                                             selector:@selector(keyboardWillHide:)
     
                                                 name:UIKeyboardWillHideNotification
     
                                               object:nil];
    
    self.deviceTextFailed.delegate = self;
    self.chickBtn.layer.masksToBounds = YES;
    self.chickBtn.layer.cornerRadius = 15;
}

//当键盘出现或改变时调用

- (void)keyboardWillShow:(NSNotification *)aNotification

{
    //获取键盘的高度
    NSDictionary *userInfo = [aNotification userInfo];
    NSValue *aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [aValue CGRectValue];
    int height = keyboardRect.size.height;
    int y = PageH - self.chickBtn.bottom;
    if (y<height) {
        self.view.frame = CGRectMake(0,-(height - y), PageW, PageH);
    }
}


//当键退出时调用

- (void)keyboardWillHide:(NSNotification *)aNotification

{
    self.view.frame = CGRectMake(0,64, PageW, PageH);
 
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    return [textField resignFirstResponder];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (IBAction)TurnBack:(UIButton*)sender {
    switch (sender.tag) {
        case 1:
            [self.navigationController popViewControllerAnimated:YES];
            break;
        case 2:
            [self.navigationController popToRootViewControllerAnimated:YES];
            break;
        default:
            break;
    }
}

@end
