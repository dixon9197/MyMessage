//
//  Contacts.m
//  MyMessage_OC
//
//  Created by dixon on 16/6/29.
//  Copyright © 2016年 Monaco1. All rights reserved.
//

#import "Contacts.h"

@implementation Contacts
-(instancetype)initWithName:(NSString *)name contactAddress:(NSString *)contactAddress
{
    self = [super init];
    if (self){
        self.name = name;
        self.contactAddress = contactAddress;
        self.isSelect = false;
    }
    return self;
}

-(void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.name forKey:@"name"];
    [aCoder encodeObject:self.contactAddress forKey:@"contactAddress"];
}

-(instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self){
        self.name = [aDecoder decodeObjectForKey:@"name"];
        self.contactAddress = [aDecoder decodeObjectForKey:@"contactAddress"];
        self.isSelect = false;
    }
    return self;
}
@end
