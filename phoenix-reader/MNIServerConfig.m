//
//  MNIServerConfig.m
//  
//
//  Created by Scott Ferwerda on 3/8/16.
//
//

#import "MNIServerConfig.h"


@implementation MNIServerConfig

#pragma mark - getters/setters

- (nullable const MNIServerConfigModel *)mniServerConfigModel
{
    MNIServerConfigModel *result = nil;
    
    // Core Data Transformable is an NSDictionary
    NSDictionary *serverConfigModelDict = self.serverConfigModelDict;
    
    // construct a new Mantle object from the dictionary
    NSError *error = nil;
    @try {
        id newModel = [MTLJSONAdapter modelOfClass:[MNIServerConfigModel class] fromJSONDictionary:serverConfigModelDict error:&error];
        if (error == nil) {
            result = newModel;
        }
        else {
            // FIXME: replace with better logging
            NSLog(@"Error initializing server config object from dictionary: %@", error);
        }
    }
    @catch (NSException *exception) {
        // FIXME: replace with better logging
        NSLog(@"Exception initializing server config object from dictionary: %@", exception);
    }
    
    return result;
}

#pragma mark - public methods

- (BOOL)setMniServerConfigModelFromDictionary:(NSDictionary *)dictionary
{
    // determine if dictionary can produce a valid object
    BOOL dictIsModelable = NO;
    NSError *error = nil;
    @try {
        [MTLJSONAdapter modelOfClass:[MNIServerConfigModel class] fromJSONDictionary:dictionary error:&error];
        if (error == nil) {
            dictIsModelable = YES;
        }
        else {
            // FIXME: replace with better logging
            NSLog(@"Error generating server config object from dictionary: %@", error);
        }
    }
    @catch (NSException *exception) {
        // FIXME: replace with better logging
        NSLog(@"Exception generating server config object from dictionary: %@", exception);
    }
    
    // set the transformable depending on how the test object creation went
    self.serverConfigModelDict = (dictIsModelable ? [NSDictionary dictionaryWithDictionary:dictionary] : nil);
    
    return dictIsModelable;
}

@end
