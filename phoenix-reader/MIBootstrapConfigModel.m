//
//  MIConfigModels.m
//  Reader
//
//  Created by Yann Duran on 10/19/15.
//  Copyright © 2015 McClatchy Interactive. All rights reserved.
//

#import "MIBootstrapConfigModel.h"

#pragma mark - UI / BootStrap

@implementation MIBootstrapConfigModel

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"server_config_url": @"server_config_url",
             @"barTintColor": @"UI.BarTintColor",
             @"barTitleColor": @"UI.BarTitleColor",
             @"tintColor": @"UI.TintColor",
             @"statusBarColorLight": @"UI.StatusBarColorLight",
             @"sectionsMenuColor": @"UI.SectionsMenuColor",
             @"sectionsMenuTintColor": @"UI.SectionsMenuTintColor",
             @"sectionsMenuTextColor": @"UI.SectionsMenuTextColor",
             @"sectionsMenuHighlightColor": @"UI.SectionsMenuHighlightColor",
             @"sectionsMenuHighlightTextColor": @"UI.SectionsMenuHighlightTextColor",
             @"cellSelectionColor": @"UI.CellSelectionColor"
             };
}

@end

