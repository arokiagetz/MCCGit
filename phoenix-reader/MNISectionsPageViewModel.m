//
//  MNISectionsPageViewModel.m
//  phoenix-reader
//
//  Created by Sandeep on 9/2/16.
//  Copyright © 2016 The McClatchy Company. All rights reserved.
//

#import "MNISectionsPageViewModel.h"
#import "MNISuperSectionViewController.h"


@interface MNISectionsPageViewModel ()

@property (strong, nonatomic) NSArray<MNISuperSectionViewController *> *childTableViewControllers;

@end

@implementation MNISectionsPageViewModel

- (instancetype)initWithSections:(NSArray*)sections {
    self = [super init];
    if (self) {
        self.sections = sections;
    }
    return self;
}

- (NSArray<MNISuperSectionViewController *> *)childTableViewControllers {
    if (!_childTableViewControllers) {
        NSMutableArray *childViewControllers = [[NSMutableArray alloc] init];
        for (NSInteger i = 0; i < [self.sections count]; i++) {
            MNISuperSectionViewController *childVc;
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            if (i == [self.sections count]-1) {
                childVc = [storyboard instantiateViewControllerWithIdentifier:@"MNIObitsAndMoreViewController"];
            } else {
                childVc = [storyboard instantiateViewControllerWithIdentifier:@"MNISectionViewController"];
            }
            [childViewControllers addObject:childVc];
        }
        _childTableViewControllers = [NSArray arrayWithArray:childViewControllers];
    }
    return _childTableViewControllers;
}

- (MNISuperSectionViewController *)sectionTableViewControllerAtIndex:(NSUInteger)index {
    if (([self.sections count] == 0) || (index >= [self.sections count])) {
        return nil;
    }

    MNISuperSectionViewController *storyViewController = self.childTableViewControllers[index];
    storyViewController.sectionModel = self.sections[index];
    storyViewController.pageIndex = index;
    return storyViewController;
}

#pragma mark - Page View Controller Data Source

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    NSUInteger index = ((MNISuperSectionViewController*) viewController).pageIndex;
    
    if ((index == 0) || (index == NSNotFound)) {
        return nil;
    }
    
    index--;
    MNISuperSectionViewController *newStoryViewController = [self sectionTableViewControllerAtIndex:index];
    [newStoryViewController setDelegate:((MNISuperSectionViewController*) viewController).delegate];
    return newStoryViewController;
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    NSUInteger index = ((MNISuperSectionViewController*) viewController).pageIndex;
    
    if (index == NSNotFound) {
        return nil;
    }
    
    index++;
    if (index == [self.sections count]) {
        return nil;
    }
    MNISuperSectionViewController *newStoryViewController = [self sectionTableViewControllerAtIndex:index];
    [newStoryViewController setDelegate:((MNISuperSectionViewController*) viewController).delegate];
    return newStoryViewController;}

- (NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController {
    return [self.sections count];
}


- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed{
    
    if (completed) {
        [self.delegate sectionHeaderSelection:((MNISuperSectionViewController*) pageViewController.viewControllers[0]).pageIndex];
    }
}


@end
