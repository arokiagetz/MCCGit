//
//  testDetailViewModel.m
//  phoenix-reader
//
//  Created by Dibya Pattanaik on 6/14/16.
//  Copyright © 2016 The McClatchy Company. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "DetailViewModel.h"
#import "MNIStoryCellViewModel.h"
#import "NSDate+helper.h"

@interface testDetailViewModel : XCTestCase
@property(strong, nonatomic) MNIStoryModel *storyModel;
@property(strong, nonatomic) MasterViewModelItem *masterViewModelItem;
@end

@implementation testDetailViewModel

- (void)setUp {
    [super setUp];
    _storyModel = [[MNIStoryModel alloc] init];
    self.masterViewModelItem = [[MasterViewModelItem alloc] init];
    self.masterViewModelItem.storyModel = self.storyModel;
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testDetailViewModels {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.

    // Test Data ---Starts
    _storyModel.topic = @"MIAMI-DADE County";
    _storyModel.title= @"Mystery solved? Australian says he's Bitcoin founder";
    NSArray *topLineArray = [NSArray arrayWithObjects:@"HEAD Line 1",@"HEAD Line 2", @"HEAD Line 3", nil];
    
    MNIStoryLeadtextModel *topLine1 = [[MNIStoryLeadtextModel alloc]init];
    topLine1.text = topLineArray[0];
    MNIStoryLeadtextModel *topLine2 = [[MNIStoryLeadtextModel alloc]init];
    topLine2.text = topLineArray[1];
    MNIStoryLeadtextModel *topLine3 = [[MNIStoryLeadtextModel alloc]init];
    topLine3.text = topLineArray[2];
    _storyModel.leadtext = [NSArray arrayWithObjects:topLine1,topLine2,topLine3, nil];
    
    _storyModel.author = @"By Peter Sam peter.sam@gmail.com";
    _storyModel.publication = @"Sacbee";
    // **** Published date testing
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *referenceDate = [dateFormatter dateFromString: @"2016-06-19 12:23:00"];
    _storyModel.published_date = referenceDate;
    _storyModel.content = @"<div xmlns=\"http://www.w3.org/1999/xhtml\"><p>Body MT_02052016_1 story to test link text in export feeds.</p>\n<p>Sprint’s top financial officer speaks Thursday at an industry conference, continuing his <a href=\"http://www.kansascity.com/news/business/technology/article47153765.html\" target=\"_blank\" title=\"\">string of public presentations</a>.</p><p>Tarek Robbiati, who joined Sprint as chief financial officer in late August, will speak at the Citi 2016 Internet, Media &amp; Telecommunications Conference in Las Vegas. His address is set to begin at 4 p. m. Central and will be <a href=\"http://investors.sprint.com/?ECID=vanity:investors\" target=\"_blank\" title=\"\">available live online</a> from Sprint and as a replay.</p><p>The Overland Park-based wireless carrier enters 2016 amid a $2.5 billion cost cutting effort that already has led to job cuts, though the company has not said how many jobs will be lost among its more than 30,000 employees nationwide.</p><p>Robbiati, in his few months at Sprint, helped boost the company’s cash holdings by $1.1 billion through <a href=\"http://www.kansascity.com/news/business/technology/article45608394.html\" target=\"_blank\" title=\"\">an innovative sale and lease back of cellphones </a>its customers lease from Sprint. He expects to repeat the transaction on a regular basis this year as a source of funding for Sprint’s transformation plan. </p></div>";
    // *****

    // --- Test Data --- ENDS
    
    DetailViewModel *storyDetailViewModel = [[DetailViewModel alloc] init];
    NSString *htmlStr = [storyDetailViewModel buildStoryContentStringFromStoryModel:self.masterViewModelItem withTraitCollection:[[UITraitCollection alloc] init] andNextStory:nil];
    
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"<div .*=\".*\">([^<]*)</div>"
                                                                            options:NSRegularExpressionCaseInsensitive
                                                                              error:nil];
    
    NSArray *matches = [regex matchesInString:htmlStr options:0 range:NSMakeRange(0, [htmlStr length])];
    NSMutableArray *compareString = [[NSMutableArray alloc] init];;
    for (int i =0; i<=[matches count]-1; i++)
    {
        NSRange range = [[matches objectAtIndex:i] rangeAtIndex:1];
        NSString *str =[htmlStr substringWithRange:range];
        NSString *str1 = [str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        [compareString addObject:str1];
    }
    
    XCTAssertNotNil(htmlStr, @"should not be nil");
    
    XCTAssertEqualObjects ([compareString objectAtIndex:0], _storyModel.topic ,@"topic is wrong");
    XCTAssertEqualObjects ([compareString objectAtIndex:1], _storyModel.title ,@"title wrong mapping");
    XCTAssertEqualObjects ([compareString objectAtIndex:2],  [_storyModel.leadtext objectAtIndex:0],@"Lead text wrong mapping");
    XCTAssertEqualObjects ([compareString objectAtIndex:3],  [_storyModel.leadtext objectAtIndex:1],@"Lead text wrong mapping");
    XCTAssertEqualObjects ([compareString objectAtIndex:4],  [_storyModel.leadtext objectAtIndex:2],@"Lead text wrong mapping");
    XCTAssertEqualObjects ([compareString objectAtIndex:5], [ _storyModel.author uppercaseString],@"author wrong mapping");
    XCTAssertEqualObjects ([compareString objectAtIndex:6], [_storyModel.publication uppercaseString],@"publication wrong mapping");
    XCTAssertEqualObjects ([compareString objectAtIndex:7], @"Sunday" ,@"Date is mapping");
    
    XCTAssertEqual(_storyModel.leadtext.count, 3);//checking top line count.

}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

-(void)testFaceBookCommentCount{
    
    self.masterViewModelItem.storyModel.url = [NSURL URLWithString:@"http://www.miamiherald.com/news/local/community/miami-dade/homestead/article101231282.html"];
    NSString *storyGraphUrl = [NSString stringWithFormat:@"https://graph.facebook.com/?ids=%@",self.masterViewModelItem.storyModel.url.absoluteString];
    NSData *fbGraphData = [NSData dataWithContentsOfURL:[NSURL URLWithString:storyGraphUrl]];
    if (fbGraphData) {
        NSError *error = nil;
        id result = [NSJSONSerialization JSONObjectWithData:fbGraphData options:NSJSONReadingMutableContainers error:&error];
        if (!error) {
            self.masterViewModelItem.storyModel.facebookCommentCount = [[[[result objectForKey:self.masterViewModelItem.storyModel.url.absoluteString] objectForKey:@"share"] objectForKey:@"comment_count"] integerValue];
        }
    }

     XCTAssertEqual(self.masterViewModelItem.storyModel.facebookCommentCount, 5);//checking facebook count.
}

@end
