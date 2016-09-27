//
//  MNISectionSubmenuTableViewController.m
//  phoenix-reader
//
//  Created by Scott Ferwerda on 5/6/16.
//  Copyright © 2016 The McClatchy Company. All rights reserved.
//

#import "MNISectionSubmenuTableViewController.h"
#import "MNISectionSubmenuTableCell.h"
#import "MILog.h"
#import "MNISectionFrontViewController.h"
@interface MNISectionSubmenuTableViewController ()

@end

@implementation MNISectionSubmenuTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // make this view blur the background
    UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    UIVisualEffectView *blurSubview = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    blurSubview.translatesAutoresizingMaskIntoConstraints = NO;
    blurSubview.frame = CGRectMake(0, 0, self.tableView.frame.size.width, self.tableView.frame.size.height);
    [self.tableView insertSubview:blurSubview atIndex:0];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.subsections count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    MNISectionSubmenuTableCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MNISectionSubmenuTableCell" forIndexPath:indexPath];
    // Configure the cell...
    NSString *allString = indexPath.row == 0 ? NSLocalizedString(@"All ", nil) : @"";
    cell.tag = indexPath.row;
    [cell.title setText:[NSString stringWithFormat:@"%@%@",allString,self.subsections[indexPath.row].name]];
    return cell;
}

// can't set selected state in cellForRowAtIndexPath, must do it here.
- (void)tableView:(UITableView *)tableView willDisplayCell:(nonnull UITableViewCell *)cell forRowAtIndexPath:(nonnull NSIndexPath *)indexPath {

    cell.selected = [self.selectedSectionID isEqualToString:self.subsections[indexPath.row].section_id];
    MILogDebug(@"row %ld selected=%@", (long)indexPath.row, (cell.selected ? @"Y" : @"N"));
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // remember, first row holds the "all sections" option, so use row-1 to get section object
    
    if (self.submenuDelegate != nil) {
        MNIConfigSectionModel *subSection = self.subsections[indexPath.row];
        [self.submenuDelegate sectionSubmenu:self didSelectSubsection:subSection];
    }
}



@end
