//
//  ChatViewController.m
//  HaierOven
//
//  Created by 刘康 on 15/1/9.
//  Copyright (c) 2015年 edaysoft. All rights reserved.
//

#import "ChatViewController.h"
#import "MessagesModel.h"
#import "Message.h"

@interface ChatViewController () <UIActionSheetDelegate>

/**
 *  留言
 */
@property (strong, nonatomic) NSMutableArray* messages;

@property (strong, nonatomic) MessagesModel* messagesModel;

@property (nonatomic) NSInteger pageIndex;

@property (strong, nonatomic) NSDate* lastChatTime;

@end

@implementation ChatViewController

#pragma mark - 获取聊天记录

- (void)loadMessages
{
    //统计页面加载耗时
    UInt64 startTime=[[NSDate date]timeIntervalSince1970]*1000;
    
    [super showProgressHUDWithLabelText:@"请稍候..." dimBackground:NO];
    
    NSString* userBaseId = CurrentUserBaseId;
    [[InternetManager sharedManager] getChatMessagesFromUser:userBaseId toUser:self.toUserId status:-1 pageIndex:_pageIndex callBack:^(BOOL success, id obj, NSError *error) {
        
        [super hiddenProgressHUD];
        
        if (success) {
            NSArray* arr = obj;
            if (arr.count < PageLimit && _pageIndex != 1) {
                [super showProgressErrorWithLabelText:@"没有更多了..." afterDelay:1];
            }
            if (_pageIndex == 1) {
                if (arr.count == 0)
                    [super showProgressErrorWithLabelText:@"没有更多了..." afterDelay:1];
                self.messages = obj;
            } else {
                [self.messages addObjectsFromArray:arr];
            }
            [self parseMessagesToJSQMessages];
            [self.collectionView reloadData];
            
            UInt64 endTime=[[NSDate date]timeIntervalSince1970]*1000;
            [uAnalysisManager onActivityResumeEvent:((long)(endTime-startTime)) withModuleId:@"给厨神留言页面"];
            
        } else {
            [super showProgressErrorWithLabelText:@"获取失败" afterDelay:1];
        }
        
    }];
    
}

- (void)parseMessagesToJSQMessages
{
    NSString* userBaseId = CurrentUserBaseId;
    for (Message* message in self.messages) {
 
        long long seconds = [message.createdTime longLongValue]/1000;
        NSDate* date = [NSDate dateWithTimeIntervalSince1970:seconds];
        
        if ([message.fromUser.userBaseId isEqualToString:userBaseId]) {
            JSQMessage* jsqMessage =  [[JSQMessage alloc] initWithSenderId:userBaseId
                                                         senderDisplayName:@"刘康"
                                                                      date:date
                                                                      text:message.content];
            [self.messagesModel.messages insertObject:jsqMessage atIndex:0];
        } else {
            long long seconds = [message.createdTime longLongValue]/1000;
            NSDate* date = [NSDate dateWithTimeIntervalSince1970:seconds];
            JSQMessage* jsqMessage =  [[JSQMessage alloc] initWithSenderId:self.toUserId
                                                         senderDisplayName:message.toUser.userName
                                                                      date:date
                                                                      text:message.content];
            [self.messagesModel.messages insertObject:jsqMessage atIndex:0];
            
        }
        
    }
}

#pragma mark - 加载和初始化

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super init]) {
        self.pageIndex = 1;
        self.isBackButton = YES;
        self.messages = [NSMutableArray array];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // This screen name value will remain set on the tracker and sent with hits until it is set to a new value or to nil.
    [[GAI sharedInstance].defaultTracker set:@"给厨神留言页面" value:@"给厨神留言页面"];
    [[GAI sharedInstance].defaultTracker send:[[GAIDictionaryBuilder createAppView] build]];
    
    [self setupSubviews];
    
    [self loadMessages];
//    [self parseMessagesToJSQMessages];
    
    self.title = self.toUserName;
    
    [MobClick event:@"leave_message"];
}

- (void)setupSubviews
{
    self.title = @"给厨神留言";
    
    /**
     *  设置聊天信息
     */
    self.senderId = CurrentUserBaseId;
    self.senderDisplayName = @"刘康";
    
    /**
     *  设置聊天数据
     */
    self.messagesModel = [[MessagesModel alloc] init];
    
    
    
    JSQMessagesAvatarImage *fromeImage = [JSQMessagesAvatarImageFactory avatarImageWithImage:self.myAvatar == nil ? [UIImage imageNamed:@"default_avatar.png"] : self.myAvatar
                                                                                 diameter:kJSQMessagesCollectionViewAvatarSizeDefault];
    
    JSQMessagesAvatarImage *toImage = [JSQMessagesAvatarImageFactory avatarImageWithImage:self.myAvatar == nil ? [UIImage imageNamed:@"default_avatar.png"] : self.toUserAvatar
                                                                                  diameter:kJSQMessagesCollectionViewAvatarSizeDefault];
    
    User* currentUser = [[User alloc] init];
    currentUser.userId = CurrentUserBaseId;
    currentUser.userName = @"我";
    User* her = [[User alloc] init];
    her.userName = self.toUserName;
    her.userId = self.toUserId;
 
    [self parseMessagesToJSQMessages];
    
    self.messagesModel.avatars = @{ currentUser.userId : fromeImage,
                      her.userId : toImage };
    
    
    self.messagesModel.users = @{ currentUser.userId  : currentUser.userName,
                    self.toUserId : her.userName };
    
    /**
     *  设置头像大小
     */
    self.collectionView.collectionViewLayout.incomingAvatarViewSize = CGSizeMake(27, 27);
    self.collectionView.collectionViewLayout.outgoingAvatarViewSize = CGSizeMake(27, 27);
    
    //    self.showLoadEarlierMessagesHeader = YES;
    self.collectionView.collectionViewLayout.messageBubbleFont = [UIFont fontWithName:GlobalTextFontName size:12];
    
}

#pragma mark - 显示系列

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    /**
     *  Enable/disable springy bubbles, default is NO.
     */
    self.collectionView.collectionViewLayout.springinessEnabled = NO;
}

#pragma mark - JSQMessagesViewController method overrides

- (void)didPressSendButton:(UIButton *)button
           withMessageText:(NSString *)text
                  senderId:(NSString *)senderId
         senderDisplayName:(NSString *)senderDisplayName
                      date:(NSDate *)date
{
    if (self.lastChatTime != nil) {
        
        NSTimeInterval inteval = [[NSDate date] timeIntervalSinceDate:self.lastChatTime];
        if (inteval < 3) {
            [super showProgressErrorWithLabelText:@"你可以休息一会" afterDelay:1];
            return;
        }
        
    }
    
    NSString* userBaseId = CurrentUserBaseId;
    [[InternetManager sharedManager] sendMessage:text toUser:self.toUserId fromUser:userBaseId callBack:^(BOOL success, id obj, NSError *error) {
        if (success) {
            NSLog(@"发送成功");
            self.lastChatTime = [NSDate date];
            
            /**
             *  发送信息应该做以下几件事
             *
             *  1. 播放声音 (可选)
             *  2. 添加新消息对象id<JSQMessageData>到MessagesModel数据源
             *  3. 发送网络请求
             *  4. 调用 `finishSendingMessage`
             */
            [JSQSystemSoundPlayer jsq_playMessageSentSound];
            
            JSQMessage *message = [[JSQMessage alloc] initWithSenderId:senderId
                                                     senderDisplayName:senderDisplayName
                                                                  date:date
                                                                  text:text];
            
            [self.messagesModel.messages addObject:message];
            [self finishSendingMessage];
            
        } else {
            NSLog(@"发送失败");
            [super showProgressErrorWithLabelText:@"发送失败" afterDelay:1];
        }
    }];
    
}

- (void)didPressAccessoryButton:(UIButton *)sender
{
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"添加照片"
                                                       delegate:self
                                              cancelButtonTitle:@"取消"
                                         destructiveButtonTitle:nil
                                              otherButtonTitles:@"从相册选取", @"拍照", nil];
    
    [sheet showFromToolbar:self.inputToolbar];
}

#pragma mark - UIActionSheet回调，发送照片

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == actionSheet.cancelButtonIndex) {
        return;
    }
    
    switch (buttonIndex) {
        case 0:
            NSLog(@"待完善");
            [self.messagesModel addPhotoMediaMessage];
            break;
            
        case 1:
            NSLog(@"待完善");
            [self.messagesModel addPhotoMediaMessage];
            break;
            
    }
    
    [JSQSystemSoundPlayer jsq_playMessageSentSound];
    [self finishSendingMessage];
}


#pragma mark - JSQMessages CollectionView DataSource

/**
 *  设置消息数据源
 *
 *  @param collectionView
 *  @param indexPath
 *
 *  @return 返回遵守了JSQMessageData协议的消息对象
 */
- (id<JSQMessageData>)collectionView:(JSQMessagesCollectionView *)collectionView messageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return [self.messagesModel.messages objectAtIndex:indexPath.item];
}

/**
 *  设置气泡
 *
 *  @param collectionView
 *  @param indexPath
 *
 *  @return 返回遵守了JSQMessageBubbleImageDataSource协议的ImageData
 */
- (id<JSQMessageBubbleImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView messageBubbleImageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
    /**
     *  You may return nil here if you do not want bubbles.
     *  In this case, you should set the background color of your collection view cell's textView.
     *
     *  Otherwise, return your previously created bubble image data objects.
     */
    
    JSQMessage *message = [self.messagesModel.messages objectAtIndex:indexPath.item];
    
    if ([message.senderId isEqualToString:self.senderId]) {
        return self.messagesModel.outgoingBubbleImageData;
    }
    
    return self.messagesModel.incomingBubbleImageData;
}

/**
 *  设置聊天人头像信息
 *
 *  @param collectionView
 *  @param indexPath
 *
 *  @return 返回遵守了JSQMessageAvatarImageDataSource协议的ImageData
 */
- (id<JSQMessageAvatarImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView avatarImageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
    /**
     *  Return `nil` here if you do not want avatars.
     *  If you do return `nil`, be sure to do the following in `viewDidLoad`:
     *
     *  self.collectionView.collectionViewLayout.incomingAvatarViewSize = CGSizeZero;
     *  self.collectionView.collectionViewLayout.outgoingAvatarViewSize = CGSizeZero;
     *
     *  It is possible to have only outgoing avatars or only incoming avatars, too.
     */
    
    /**
     *  Return your previously created avatar image data objects.
     *
     *  Note: these the avatars will be sized according to these values:
     *
     *  self.collectionView.collectionViewLayout.incomingAvatarViewSize
     *  self.collectionView.collectionViewLayout.outgoingAvatarViewSize
     *
     *  Override the defaults in `viewDidLoad`
     */
    JSQMessage *message = [self.messagesModel.messages objectAtIndex:indexPath.item];
    
    return [self.messagesModel.avatars objectForKey:message.senderId];
}

- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForCellTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    /**
     *  This logic should be consistent with what you return from `heightForCellTopLabelAtIndexPath:`
     *  The other label text delegate methods should follow a similar pattern.
     *
     *  Show a timestamp for every 3rd message
     */
    //if (indexPath.item % 3 == 0) {
        JSQMessage *message = [self.messagesModel.messages objectAtIndex:indexPath.item];
        return [[JSQMessagesTimestampFormatter sharedFormatter] attributedTimestampForDate:message.date];
    //}
    
    //return nil;
}

- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForMessageBubbleTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    JSQMessage *message = [self.messagesModel.messages objectAtIndex:indexPath.item];
    
    /**
     *  iOS7-style sender name labels
     */
    if ([message.senderId isEqualToString:self.senderId]) {
        return nil;
    }
    
    if (indexPath.item - 1 > 0) {
        JSQMessage *previousMessage = [self.messagesModel.messages objectAtIndex:indexPath.item - 1];
        if ([[previousMessage senderId] isEqualToString:message.senderId]) {
            return nil;
        }
    }
    
    /**
     *  Don't specify attributes to use the defaults.
     */
    return [[NSAttributedString alloc] initWithString:message.senderDisplayName];
}

- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForCellBottomLabelAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}

#pragma mark - UICollectionView DataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.messagesModel.messages count];
}

- (UICollectionViewCell *)collectionView:(JSQMessagesCollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    /**
     *  Override point for customizing cells
     */
    JSQMessagesCollectionViewCell *cell = (JSQMessagesCollectionViewCell *)[super collectionView:collectionView cellForItemAtIndexPath:indexPath];
    
    /**
     *  Configure almost *anything* on the cell
     *
     *  Text colors, label text, label colors, etc.
     *
     *
     *  DO NOT set `cell.textView.font` !
     *  Instead, you need to set `self.collectionView.collectionViewLayout.messageBubbleFont` to the font you want in `viewDidLoad`
     *
     *
     *  DO NOT manipulate cell layout information!
     *  Instead, override the properties you want on `self.collectionView.collectionViewLayout` from `viewDidLoad`
     */
    
    JSQMessage *msg = [self.messagesModel.messages objectAtIndex:indexPath.item];
    
    if (!msg.isMediaMessage) {
        
        if ([msg.senderId isEqualToString:self.senderId]) {
            cell.textView.textColor = [UIColor whiteColor];
        }
        else {
            cell.textView.textColor = [UIColor blackColor];
        }
//        cell.textView.font = [UIFont fontWithName:GlobalTextFontName size:12];
        
        
        cell.textView.linkTextAttributes = @{ NSForegroundColorAttributeName : cell.textView.textColor,
                                              NSUnderlineStyleAttributeName : @(NSUnderlineStyleSingle | NSUnderlinePatternSolid)
                                              };
    }
    
    return cell;
}



#pragma mark - JSQMessages collection view flow layout delegate

#pragma mark - Adjusting cell label heights

- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
                   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForCellTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    /**
     *  Each label in a cell has a `height` delegate method that corresponds to its text dataSource method
     */
    
    /**
     *  This logic should be consistent with what you return from `attributedTextForCellTopLabelAtIndexPath:`
     *  The other label height delegate methods should follow similarly
     *
     *  Show a timestamp for every 3rd message
     */
    //if (indexPath.item % 3 == 0) {
        return kJSQMessagesCollectionViewCellLabelHeightDefault;
    //}
    
    //return 0.0f;
}

- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
                   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForMessageBubbleTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    /**
     *  iOS7-style sender name labels
     */
    JSQMessage *currentMessage = [self.messagesModel.messages objectAtIndex:indexPath.item];
    if ([[currentMessage senderId] isEqualToString:self.senderId]) {
        return 0.0f;
    }
    
    if (indexPath.item - 1 > 0) {
        JSQMessage *previousMessage = [self.messagesModel.messages objectAtIndex:indexPath.item - 1];
        if ([[previousMessage senderId] isEqualToString:[currentMessage senderId]]) {
            return 0.0f;
        }
    }
    
    return kJSQMessagesCollectionViewCellLabelHeightDefault;
}

- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
                   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForCellBottomLabelAtIndexPath:(NSIndexPath *)indexPath
{
    return 0.0f;
}

#pragma mark - Responding to collection view tap events

- (void)collectionView:(JSQMessagesCollectionView *)collectionView
                header:(JSQMessagesLoadEarlierHeaderView *)headerView didTapLoadEarlierMessagesButton:(UIButton *)sender
{
    NSLog(@"加载更早的信息!");
}

- (void)collectionView:(JSQMessagesCollectionView *)collectionView didTapAvatarImageView:(UIImageView *)avatarImageView atIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"点击了头像!");
}

- (void)collectionView:(JSQMessagesCollectionView *)collectionView didTapMessageBubbleAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"点击了气泡!");
}

- (void)collectionView:(JSQMessagesCollectionView *)collectionView didTapCellAtIndexPath:(NSIndexPath *)indexPath touchLocation:(CGPoint)touchLocation
{
    NSLog(@"点击了 cell %@!", NSStringFromCGPoint(touchLocation));
}


@end

