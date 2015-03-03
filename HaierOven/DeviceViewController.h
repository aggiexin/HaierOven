//
//  DeviceViewController.h
//  HaierOven
//
//  Created by dongl on 14/12/16.
//  Copyright (c) 2014年 edaysoft. All rights reserved.
//

#import "BaseViewController.h"
#import "DeviceUnconnectController.h"

@interface DeviceViewController : BaseViewController <DeviceUnconnectControllerDelegate>
@property (strong, nonatomic) NSArray *myDevices;
@property (nonatomic) BOOL addDeviceFlag;
@end
