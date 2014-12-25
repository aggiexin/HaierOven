//
//  DataCenter.m
//  追爱行动
//
//  Created by 刘康 on 14-10-3.
//  Copyright (c) 2014年 origheart. All rights reserved.
//

#import "DataCenter.h"
#import "DataParser.h"
#import <sys/xattr.h>
#import "FCUUID.h"

NSString* const kRecommendProjectsFileName              = @"recommendProjects.plist";

NSString* const kCurrentLoginUserName                = @"Current login user name";


NSString* const kLocalUserInfoFileName          = @"currentUser.data";
NSString* const kLocalTagsFileName              = @"tags.data";
NSString* const kLocalCookbooksFileName         = @"cookbooks.data";

@interface DataCenter ()


@end

@implementation DataCenter


#pragma mark - 单例 实例化

+ (DataCenter *)sharedInstance
{
    static DataCenter* _sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[DataCenter alloc] init];
    });
    return _sharedInstance;
}

- (instancetype)init
{
    if (self = [super init]) {
        [self createDirectories];
        self.clientId = [FCUUID uuidForDevice];
    }
    return self;
}

#pragma mark - 路径相关

- (void)createDirectories
{
    NSFileManager* fileManager = [NSFileManager defaultManager];
    if(![fileManager fileExistsAtPath:USER_DATA_PATH]) {
        [fileManager createDirectoryAtPath:USER_DATA_PATH withIntermediateDirectories:YES attributes:nil error:nil];
        [self addSkipBackupAttributeToPath:USER_DATA_PATH];
    }
    if (![fileManager fileExistsAtPath:DOWNLOAD_DATA_PATH]) {
        [fileManager createDirectoryAtPath:DOWNLOAD_DATA_PATH withIntermediateDirectories:YES attributes:nil error:nil];
        [self addSkipBackupAttributeToPath:DOWNLOAD_DATA_PATH];
    }
}

- (NSString*)getLibraryPath
{
    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    return [paths firstObject];
}

/**
 * 获取plist文件目录
 **/
- (NSString*)getUserDataPath;
{
    return USER_DATA_PATH;
}

/**
 * 获取下载的文件目录
 **/
- (NSString*)getDownloadDataPath
{
    return DOWNLOAD_DATA_PATH;
}

#pragma mark - 备份策略

/**
 * 设置备份策略，所有文件都不进行iCloud备份
 **/
- (BOOL)addSkipBackupAttributeToItemAtURL:(NSURL *)URL
{
    const char* filePath = [[URL path] fileSystemRepresentation];
    
    const char* attrName = "com.apple.MobileBackup";
    u_int8_t attrValue = 1;
    
    int result = setxattr(filePath, attrName, &attrValue, sizeof(attrValue), 0, 0);
    return result == 0;
}

- (void)addSkipBackupAttributeToPath:(NSString*)path
{
    u_int8_t b = 1;
    setxattr([path fileSystemRepresentation], "com.apple.MobileBackup", &b, 1, 0, 0);
}

/**
 * 测试方法，检查某个文件是否会被iCloud备份
 **/
- (void)testFileAttributeWithUrl:(NSURL*)fileUrl
{
    NSError* error = nil;
    id flag = nil;
    [fileUrl getResourceValue: &flag
                       forKey: NSURLIsExcludedFromBackupKey error: &error];
    NSLog (@"NSURLIsExcludedFromBackupKey flag value is %@", flag);
}

#pragma mark - 缓存文件 读取缓存文件

- (void)saveUserInfoWithObject:(id)jsonObj
{
    NSData* data = [NSJSONSerialization dataWithJSONObject:jsonObj options:NSJSONWritingPrettyPrinted error:nil];
    
    NSLog(@"%@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
    
    NSString* filePath = [[self getUserDataPath] stringByAppendingPathComponent:kLocalUserInfoFileName];
    [data writeToFile:filePath atomically:YES];
}

- (id)getUserInfoObject
{
    NSString* filePath = [[self getUserDataPath] stringByAppendingPathComponent:kLocalUserInfoFileName];
    NSData* data = [NSData dataWithContentsOfFile:filePath];
    NSDictionary* jsonObj = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    return jsonObj;
}

- (void)saveTagsWithObject:(id)jsonObj
{
    NSData* data = [NSJSONSerialization dataWithJSONObject:jsonObj options:NSJSONWritingPrettyPrinted error:nil];
    
    NSLog(@"%@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
    
    NSString* filePath = [[self getUserDataPath] stringByAppendingPathComponent:kLocalTagsFileName];
    [data writeToFile:filePath atomically:YES];
    
}

- (id)getTagsObject
{
    NSString* filePath = [[self getUserDataPath] stringByAppendingPathComponent:kLocalTagsFileName];
    NSData* data = [NSData dataWithContentsOfFile:filePath];
    NSDictionary* jsonObj = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    return jsonObj;
}

- (void)saveCookbooksWithObject:(id)jsonObj
{
    NSData* data = [NSJSONSerialization dataWithJSONObject:jsonObj options:NSJSONWritingPrettyPrinted error:nil];
    
    NSLog(@"%@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
    
    NSString* filePath = [[self getUserDataPath] stringByAppendingPathComponent:kLocalCookbooksFileName];
    [data writeToFile:filePath atomically:YES];
}

- (id)getCookbooksObject
{
    NSString* filePath = [[self getUserDataPath] stringByAppendingPathComponent:kLocalCookbooksFileName];
    NSData* data = [NSData dataWithContentsOfFile:filePath];
    NSDictionary* jsonObj = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    return jsonObj;
}


#pragma mark - setters

//- (void)setCurrentUser:(User *)currentUser
//{
//    _currentUser = currentUser;
////    NSLog(@"保存用户的信息：\n用户名：%@\n是否登录：%d\ncookieValue:%@\n", currentUser.userName, currentUser.hadLogin, currentUser.cookieValue);
//    NSLog(@"---------");
//    [[NSUserDefaults standardUserDefaults] setValue:currentUser.userName forKey:kCurrentLoginUserName];
//    [[NSUserDefaults standardUserDefaults] synchronize];
//    
//    // 对象->NSData
//    
//    // 1. 准备Data
//    NSMutableData * data = [NSMutableData data];
//    // 2. 准备工具
//    NSKeyedArchiver* keyedArchiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
//    // 3. encode
//    [keyedArchiver encodeObject:currentUser forKey:@"currentUser"];
//    // 4. 结束encode
//    [keyedArchiver finishEncoding];
//    
//    // 保存Data到Keychain
//    UICKeyChainStore* keyChainStore = [UICKeyChainStore keyChainStoreWithService:self.serviceForUser];
//    [keyChainStore setData:data forKey:@"currentUserData"];
//    [keyChainStore synchronize];
//}

#pragma mark - getters

//- (User *)currentUser
//{
//    // NSData -> 对象
//    
//    // 1. 准备Data
//    UICKeyChainStore* keyChainStore = [UICKeyChainStore keyChainStoreWithService:self.serviceForUser];
//    NSMutableData* data = [[keyChainStore dataForKey:@"currentUserData"] mutableCopy];
//    // 2. 准备工具
//    NSKeyedUnarchiver* keyedUnarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
//    // 3. decode
//    _currentUser = [keyedUnarchiver decodeObjectForKey:@"currentUser"];
//    // 4. 结束decode
//    [keyedUnarchiver finishDecoding];
//    
//    if (data.bytes<=0) {
//        NSLog(@"本地没有存储用户信息，创建一个空的User对象返回");
//        _currentUser = [[User alloc] init];
//    }
//    
//    return _currentUser;
//}


@end
