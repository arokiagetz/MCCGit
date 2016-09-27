//
//  MNIPageViewModel.m
//  phoenix-reader
//
//  Created by Sandeep on 7/12/16.
//  Copyright © 2016 The McClatchy Company. All rights reserved.
//

#import "MNIPageViewModel.h"
#import "MNIPageViewController.h"
@interface MNIPageViewModel()

@end

@implementation MNIPageViewModel


- (instancetype)initWithStoris:(NSArray*)stories {
    self = [super init];
    if (self) {
        self.stories = stories;
    }
    return self;
}

- (MNIStoryViewController *)storyViewControllerAtIndex:(NSUInteger)index {
    if (([self.stories count] == 0) || (index >= [self.stories count])) {
        return nil;
    }
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    MNIStoryViewController *storyViewController = [storyboard instantiateViewControllerWithIdentifier:@"StoryViewController"];
    storyViewController.pageIndex = index;
    storyViewController.storyModelItem = self.stories[index];
    storyViewController.nextStoryModelItem = index+1 == self.stories.count ? nil : self.stories[index+1];
    return storyViewController;
}

#pragma mark - Page View Controller Data Source

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    NSUInteger index = ((MNIStoryViewController*) viewController).pageIndex;
    
    if ((index == 0) || (index == NSNotFound)) {
        return nil;
    }
    
    index--;
    MNIStoryViewController *newStoryViewController = [self storyViewControllerAtIndex:index];
    newStoryViewController.delegate = [(MNIStoryViewController*)viewController delegate];
    return newStoryViewController;
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    NSUInteger index = ((MNIStoryViewController*) viewController).pageIndex;
    
    if (index == NSNotFound) {
        return nil;
    }
    
    index++;
    if (index == [self.stories count]) {
        return nil;
    }
    MNIStoryViewController *newStoryViewController = [self storyViewControllerAtIndex:index];
    newStoryViewController.delegate = [(MNIStoryViewController*)viewController delegate];
    return newStoryViewController;}

- (NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController {
    return [self.stories count];
}


- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed{
   
    if (completed){
        //get the current index of pageviewController
        MNIStoryViewController *currentView = [pageViewController.viewControllers objectAtIndex:0];
        MNIPageViewController *pageviewControl = (MNIPageViewController*)pageViewController;
        pageviewControl.currentIndex = (int)currentView.pageIndex;
    }
}

@end
