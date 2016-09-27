//
//  NSString+helper.m
//  phoenix-reader
//
//  Created by Dibya Pattanaik on 6/20/16.
//  Copyright © 2016 The McClatchy Company. All rights reserved.
//

#import "NSString+helper.h"

@implementation NSString (helper)

+ (NSString *)replaceStringCapitalHtmlEncoding:(NSString*)sourceString
{
    NSMutableString* mutableString = [sourceString mutableCopy];
    
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"(&.)(.*;)"
                                                                           options:NSRegularExpressionCaseInsensitive
                                                                             error:nil];
    
    NSArray *matches = [regex matchesInString:sourceString options:0 range:NSMakeRange(0,[sourceString length])];
    for (NSTextCheckingResult *result in matches) {
        NSRange resultRange = NSMakeRange(result.range.location + 2, result.range.length - 2); // keeping the first 2 chars
        NSString *match = [regex replacementStringForResult:result
                                                   inString:sourceString
                                                     offset:0
                                                   template:@"$2"];
        
        NSString *replacement = match.lowercaseString;
        
        [mutableString replaceCharactersInRange:resultRange withString:replacement];
    }
    
    return mutableString;
}


@end
