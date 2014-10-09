//
//  TWAPhone.h
//
//  Created by   on 10/8/14
//  Copyright (c) 2014 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>



@interface TWAContactPhone : NSObject <NSCoding, NSCopying>

@property (nonatomic, strong) NSString *work;
@property (nonatomic, strong) NSString *home;
@property (nonatomic, strong) NSString *mobile;

+ (instancetype)modelObjectWithDictionary:(NSDictionary *)dict;
- (instancetype)initWithDictionary:(NSDictionary *)dict;
- (NSDictionary *)dictionaryRepresentation;

@end
