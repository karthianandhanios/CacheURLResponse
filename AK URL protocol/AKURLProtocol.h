//
//  MyURLProtocol.h
//  CacheURLResponse
//
//  Created by Karthi A on 21/01/18.
//  Copyright © 2018 Karthi A. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AKURLProtocol : NSURLProtocol
@property (nonatomic, strong) NSMutableData *mutableData;
@property (nonatomic, strong) NSURLResponse *response;
@end
