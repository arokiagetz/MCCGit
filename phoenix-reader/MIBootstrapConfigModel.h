//
//  MIConfigModels.h
//  Reader
//
//  Created by Yann Duran on 10/19/15.
//  Copyright © 2015 McClatchy Interactive. All rights reserved.
//
//  Based on : http://confluence.mcclatchyinteractive.com/display/MOBI/New+Server+Config#NewServerConfig-Ads

#import <Foundation/Foundation.h>
#import <Mantle/Mantle.h>

#pragma mark - UI / BootStrap

@import UIKit;

@interface MIBootstrapConfigModel : MTLModel <MTLJSONSerializing>

@property (nonatomic, strong) NSString *server_config_url;
@property (nonatomic, copy) NSString *barTintColor;
@property (nonatomic, copy) NSString *barTitleColor;
@property (nonatomic, copy) NSString *tintColor;
@property (nonatomic, assign) BOOL statusBarColorLight;
@property (nonatomic, copy) NSString *sectionsMenuColor;
@property (nonatomic, copy) NSString *sectionsMenuTintColor;
@property (nonatomic, copy) NSString *sectionsMenuTextColor;
@property (nonatomic, copy) NSString *sectionsMenuHighlightColor;
@property (nonatomic, copy) NSString *sectionsMenuHighlightTextColor;
@property (nonatomic, copy) NSString *cellSelectionColor;

@end
