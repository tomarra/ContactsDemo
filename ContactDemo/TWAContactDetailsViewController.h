//
//  TWAContactDetailsViewController.h
//  ContactDemo
//
//  Created by Tom Arra on 10/8/14.
//  Copyright (c) 2014 tomarra. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TWAContactListResponse.h"

@interface TWAContactDetailsViewController : UIViewController

@property (nonatomic, strong) TWAContactListResponse *contactListResponse;
@property (weak, nonatomic) IBOutlet UINavigationItem *navBarTitle;

@end
