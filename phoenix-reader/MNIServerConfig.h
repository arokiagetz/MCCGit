//
//  MNIServerConfig.h
//  
//
//  Created by Scott Ferwerda on 3/8/16.
//
//

#import <Foundation/Foundation.h>
#import "NSManagedObject+Helpers.h"
#import "MNIServerConfigModels.h"

NS_ASSUME_NONNULL_BEGIN

@interface MNIServerConfig : NSManagedObject

@property (nullable, nonatomic, copy, readonly) const MNIServerConfigModel *mniServerConfigModel;

- (BOOL)setMniServerConfigModelFromDictionary:(NSDictionary *)dictionary;

@end

NS_ASSUME_NONNULL_END

#import "MNIServerConfig+CoreDataProperties.h"
