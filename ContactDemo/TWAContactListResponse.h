//
//  TWANSObject.h
//
//  Created by   on 10/8/14
//  Copyright (c) 2014 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TWAContactPhone.h"

@class TWAContactListResponse;

@interface TWAContactListResponse : NSObject

@property (nonatomic, strong) TWAContactPhone *phone;
@property (nonatomic, strong) NSString *smallImageURL;
@property (nonatomic, strong) NSString *company;
@property (nonatomic, strong) NSString *detailsURL;
@property (nonatomic, strong) NSString *birthdate;
@property (nonatomic, assign) double employeeId;
@property (nonatomic, strong) NSString *name;

@end
