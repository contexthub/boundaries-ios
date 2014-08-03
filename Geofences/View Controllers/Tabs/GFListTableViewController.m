//
//  GFListTableViewController.m
//  Geofences
//
//  Created by Jeff Kibuule on 8/2/14.
//  Copyright (c) 2014 ChaiOne. All rights reserved.
//

#import "GFListTableViewController.h"

#import "GFGeofence.h"
#import "GFGeofenceStore.h"

#import "GFGeofenceCell.h"

@interface GFListTableViewController ()
@property (nonatomic, weak) GFGeofence *selectedGeofence;
@end

@implementation GFListTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self.tableView reloadData];
}

#pragma mark - Actions

// Edit/Done button was tapped
- (IBAction)toggleEditing:(id)sender {
    [self.tableView setEditing:!self.tableView.editing animated:YES];
    
    // Update button UI
    UIBarButtonSystemItem editButtonType = self.tableView.editing ? UIBarButtonSystemItemDone : UIBarButtonSystemItemEdit;
    UIBarButtonItem *editButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:editButtonType target:self action:@selector(toggleEditing:)];
    self.navigationItem.rightBarButtonItem = editButtonItem;
}

#pragma mark - Alert View Methods

// Add the geofence to the geofence store
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        
        self.selectedGeofence.name = [alertView textFieldAtIndex:0].text;
        
        // Update the geofence
        [[GFGeofenceStore sharedInstance] updateGeofence:self.selectedGeofence completionHandler:^(NSError *error) {
            
            if (!error) {
                [self.tableView reloadData];
            } else {
                // There was an error creating the geofence
                [[[UIAlertView alloc] initWithTitle:@"Error" message:[NSString stringWithFormat:@"There was a problem updating your %@ geofence in ContextHub", self.selectedGeofence.name] delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Ok", nil] show];
            }
        }];
    }
}

#pragma mark - Table View Methods

// Number of sections
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

// Number of rows
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [GFGeofenceStore sharedInstance].geofences.count;
}

// Information for a row
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    GFGeofenceCell *cell = [tableView dequeueReusableCellWithIdentifier:@"GFGeofenceCellIdentifier"];
    GFGeofence *geofence = [GFGeofenceStore sharedInstance].geofences[indexPath.row];
    
    cell.nameLabel.text = geofence.name;
    cell.infoLabel.text = [NSString stringWithFormat:@"Latitude: %.2f, Longitude: %.2f, Radius: %.2f", geofence.center.latitude, geofence.center.longitude, geofence.radius];
    
    return cell;
}

// A row was selected
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Pop an alert view asking for a new name for the geofence
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Update geofence" message:@"Enter the updated name of your geofence:" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Ok", nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    self.selectedGeofence = [GFGeofenceStore sharedInstance].geofences[indexPath.row];
    [alert textFieldAtIndex:0].text = self.selectedGeofence.name;
    [alert show];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

// A row is being updated
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {

    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete a geofence
        GFGeofence *geofenceToDelete = [GFGeofenceStore sharedInstance].geofences[indexPath.row];
        [[GFGeofenceStore sharedInstance] deleteGeofence:geofenceToDelete completionHandler:^(NSError *error) {
            
            if (!error) {
                [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
                
                // Synchronize geofences (this would not need to be done if push were enabled)
                [[GFGeofenceStore sharedInstance] syncGeofences];
            } else {
                [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Error deleting geofence from ContextHub" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Ok", nil] show];
            }
            
            // Stop table editing
            [self.tableView setEditing:FALSE animated:YES];
        }];
    }
}

@end