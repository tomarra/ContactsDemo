//
//  TWAPhone.m
//
//  Created by   on 10/8/14
//  Copyright (c) 2014 __MyCompanyName__. All rights reserved.
//

#import "TWAContactPhone.h"


NSString *const kTWAPhoneWork = @"work";
NSString *const kTWAPhoneHome = @"home";
NSString *const kTWAPhoneMobile = @"mobile";


@interface TWAContactPhone ()

- (id)objectOrNilForKey:(id)aKey fromDictionary:(NSDictionary *)dict;

@end

@implementation TWAContactPhone

@synthesize work = _work;
@synthesize home = _home;
@synthesize mobile = _mobile;


+ (instancetype)modelObjectWithDictionary:(NSDictionary *)dict
{
    return [[self alloc] initWithDictionary:dict];
}

- (instancetype)initWithDictionary:(NSDictionary *)dict
{
    self = [super init];
    
    // This check serves to make sure that a non-NSDictionary object
    // passed into the model class doesn't break the parsing.
    if(self && [dict isKindOfClass:[NSDictionary class]]) {
            self.work = [self objectOrNilForKey:kTWAPhoneWork fromDictionary:dict];
            self.home = [self objectOrNilForKey:kTWAPhoneHome fromDictionary:dict];
            self.mobile = [self objectOrNilForKey:kTWAPhoneMobile fromDictionary:dict];

    }
    
    return self;
    
}

- (NSDictionary *)dictionaryRepresentation
{
    NSMutableDictionary *mutableDict = [NSMutableDictionary dictionary];
    [mutableDict setValue:self.work forKey:kTWAPhoneWork];
    [mutableDict setValue:self.home forKey:kTWAPhoneHome];
    [mutableDict setValue:self.mobile forKey:kTWAPhoneMobile];

    return [NSDictionary dictionaryWithDictionary:mutableDict];
}

- (NSString *)description 
{
    return [NSString stringWithFormat:@"%@", [self dictionaryRepresentation]];
}

#pragma mark - Helper Method
- (id)objectOrNilForKey:(id)aKey fromDictionary:(NSDictionary *)dict
{
    id object = [dict objectForKey:aKey];
    return [object isEqual:[NSNull null]] ? nil : object;
}


#pragma mark - NSCoding Methods

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];

    self.work = [aDecoder decodeObjectForKey:kTWAPhoneWork];
    self.home = [aDecoder decodeObjectForKey:kTWAPhoneHome];
    self.mobile = [aDecoder decodeObjectForKey:kTWAPhoneMobile];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{

    [aCoder encodeObject:_work forKey:kTWAPhoneWork];
    [aCoder encodeObject:_home forKey:kTWAPhoneHome];
    [aCoder encodeObject:_mobile forKey:kTWAPhoneMobile];
}

- (id)copyWithZone:(NSZone *)zone
{
    TWAContactPhone *copy = [[TWAContactPhone alloc] init];
    
    if (copy) {

        copy.work = [self.work copyWithZone:zone];
        copy.home = [self.home copyWithZone:zone];
        copy.mobile = [self.mobile copyWithZone:zone];
    }
    
    return copy;
}


@end
