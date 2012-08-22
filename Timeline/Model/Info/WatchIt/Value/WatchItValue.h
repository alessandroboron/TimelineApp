//
//  Copyright 2011-2012 Alessandro Boron
// 
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
// 
//  http://www.apache.org/licenses/LICENSE-2.0
// 
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//
//
//  Value.h
//  CroMAR
//
//  Created by Alessandro Boron on 7/25/12.
//  Copyright (c) 2012 NTNU. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WatchItValue : NSObject

@property (nonatomic, strong) NSString *valueType;
@property (nonatomic, strong) NSString *value;
@property (nonatomic, strong) NSString *unit;

//The designated initializer
- (id)initValueWithType:(NSString *)type value:(NSString *)value unit:(NSString *)unit;

@end
