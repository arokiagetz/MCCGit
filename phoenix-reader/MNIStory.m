//
//  MNIStory.m
//  
//
//  Created by Yann Duran on 3/14/16.
//
//

#import "MNIStory.h"
#import "MILog.h"

@implementation MNIStory

// Insert code here to add functionality to your managed object subclass
- (MNIStoryModel*)modelObjectForStoryContent
{
    NSError *adapterError;
    MNIStoryModel *model = [MTLJSONAdapter modelOfClass:[MNIStoryModel class] fromJSONDictionary:self.storyContentTransformation error:&adapterError];
    if (adapterError) {
        MILogError(@"error in MTLJSONAdapter: %@",adapterError);
        model = nil;
    }
    return model;
}

@end

@implementation MNIStoryContentTransformation

// class of the "output" objects, as returned by transformedValue:
+ (Class)transformedValueClass
{
    return [NSDictionary class];
}

// flag indicating whether transformation is read-only or not
+ (BOOL)allowsReverseTransformation
{
    return YES;
}

// by default returns value
- (NSData*)transformedValue:(NSDictionary*)value
{
    return [NSKeyedArchiver archivedDataWithRootObject:value];
}

// by default raises an exception if +allowsReverseTransformation returns NO and otherwise invokes transformedValue:
- (NSDictionary*)reverseTransformedValue:(NSData*)value
{
    return [NSKeyedUnarchiver unarchiveObjectWithData:value];
}

@end

