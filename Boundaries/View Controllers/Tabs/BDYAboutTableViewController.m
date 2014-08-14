//
//  BDYAboutTableViewController.m
//  Boundaries
//
//  Created by Jeff Kibuule on 8/2/14.
//  Copyright (c) 2014 ChaiOne. All rights reserved.
//

#import "BDYAboutTableViewController.h"

/**
 About table view sections
 */
typedef NS_ENUM(NSUInteger, BDYAboutTableSection) {
    BDYAboutTableVersionSection = 0
};

@interface BDYAboutTableViewController ()

@property (nonatomic, copy) NSString *versionInfoFooterText;

@end

@implementation BDYAboutTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Set the version info string with build verison and number
    NSString *buildVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    NSString *buildNumber = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"];
    self.versionInfoFooterText = [NSString stringWithFormat:@"\nVersion %@ (%@)\nCopyright © 2014 ChaiOne\nAll Rights Reserved\n", buildVersion, buildNumber];
}

- (void)tableView:(UITableView *)tableView willDisplayFooterView:(UIView *)view forSection:(NSInteger)section {
    UITableViewHeaderFooterView *footer = (UITableViewHeaderFooterView *)view;
    
    switch (section) {
        case BDYAboutTableVersionSection:
            footer.textLabel.text = self.versionInfoFooterText;
            
            break;
        default:
            
            break;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    switch (section) {
        case BDYAboutTableVersionSection:
            
            return self.versionInfoFooterText;
        default:
            
            break;
    }
    
    return @"";
}

@end