//
//  GFListTableViewController.m
//  Geofences
//
//  Created by Jeff Kibuule on 8/2/14.
//  Copyright (c) 2014 ChaiOne. All rights reserved.
//

#import "GFListTableViewController.h"

#import "GFGeofence.h"
#import "GFMapViewController.h"

#import "GFGeofenceCell.h"

@interface GFListTableViewController ()
@property (nonatomic, weak) GFGeofence *selectedGeofence;

@property (nonatomic, strong) NSMutableArray *geofenceArray;

@property (nonatomic) BOOL verboseContextHubLogging;

@end

@implementation GFListTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    // Grab the geofence array from GFMapViewController
    UINavigationController *navController = (UINavigationController *)[self.tabBarController.childViewControllers objectAtIndex:0];
    
    GFMapViewController* mapVC = navController.viewControllers[0];
    self.geofenceArray = mapVC.geofenceArray;
    self.verboseContextHubLogging = mapVC.verboseContextHubLogging;
    
    [self refreshGeofences];
}

#pragma mark - Geofences

// Refresh all geofences on the map
- (void)refreshGeofences {
    // If you have a location and particular radius of geofences you are interested in, you can fill those parameters to get back a smaller data set
    [[CCHGeofenceService sharedInstance] getGeofencesWithTags:@[GFGeofenceTag] location:nil radius:0 completionHandler:^(NSArray *geofences, NSError *error) {
        
        if (!error) {
            
            if (self.verboseContextHubLogging) {
                NSLog(@"GF: [CCHGeofenceService getGeofencesWithTags: location: radius: completionHandler:] response: %@", geofences);
            }
            
            NSLog(@"GF: Succesfully synced %d new geofences from ContextHub", geofences.count - self.geofenceArray.count);
            
            [self.geofenceArray removeAllObjects];
            
            for (NSDictionary *geofenceDict in geofences) {
                GFGeofence *geofence = [[GFGeofence alloc] initWithDictionary:geofenceDict];
                [self.geofenceArray addObject:geofence];
            }
            
            [self.tableView reloadData];
        } else {
            NSLog(@"GF: Could not sync geofences with ContextHub");
        }
    }];
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
        NSMutableDictionary *geofenceDict = [NSMutableDictionary dictionary];
        [geofenceDict setValue:[NSString stringWithFormat:@"%.6f", self.selectedGeofence.center.latitude] forKey:@"latitude"];
        [geofenceDict setValue:[NSString stringWithFormat:@"%.6f", self.selectedGeofence.center.longitude] forKey:@"longitude"];
        [geofenceDict setValue:[NSString stringWithFormat:@"%.6f", self.selectedGeofence.radius] forKey:@"radius"];
        [geofenceDict setValue:self.selectedGeofence.name forKey:@"name"];
        [geofenceDict setValue:self.selectedGeofence.tags forKey:@"tags"];
        
        NSNumber *geofenceID = [NSNumber numberWithInt:(int)[self.selectedGeofence.geofenceID integerValue]];
        [geofenceDict setValue:geofenceID forKey:@"id"];
        
        [[CCHGeofenceService sharedInstance] updateGeofence:geofenceDict completionHandler:^(NSError *error) {
            
            if (!error) {
                // Synchronize updated geofence with sensor pipeline (this happens automatically if push is configured)
                [[CCHSensorPipeline sharedInstance] synchronize:^(NSError *error) {
                    
                    if (!error) {
                        NSLog(@"GF: Successfully updated and synchronized geofence %@ on ContextHub", self.selectedGeofence.name);
                        [self.tableView reloadData];
                    } else {
                        NSLog(@"GF: Could not synchronize update of geofence %@ on ContextHub", self.selectedGeofence.name);
                    }
                }];
            } else {
                // There was an error updating the geofence
                [[[UIAlertView alloc] initWithTitle:@"Error" message:[NSString stringWithFormat:@"There was a problem updating your %@ geofence in ContextHub", self.selectedGeofence.name] delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Ok", nil] show];
                NSLog(@"GF: Could not update geofence %@ on ContextHub", self.selectedGeofence.name);
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
    return self.geofenceArray.count;
}

// Information for a row
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    GFGeofenceCell *cell = [tableView dequeueReusableCellWithIdentifier:@"GFGeofenceCellIdentifier"];
    GFGeofence *geofence = self.geofenceArray[indexPath.row];
    
    cell.nameLabel.text = geofence.name;
    cell.infoLabel.text = [NSString stringWithFormat:@"Latitude: %.2f, Longitude: %.2f, Radius: %.2f", geofence.center.latitude, geofence.center.longitude, geofence.radius];
    
    return cell;
}

// A row was selected
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Pop an alert view asking for a new name for the geofence
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Update geofence" message:@"Enter the updated name of your geofence:" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Ok", nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    self.selectedGeofence = self.geofenceArray[indexPath.row];
    [alert textFieldAtIndex:0].text = self.selectedGeofence.name;
    [alert show];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

// A row is being updated   
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {

    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete a geofence
        GFGeofence *geofenceToDelete = self.geofenceArray[indexPath.row];
        
        // Delete the geofence
        NSMutableDictionary *geofenceDict = [NSMutableDictionary dictionary];
        [geofenceDict setValue:[NSString stringWithFormat:@"%.6f", geofenceToDelete.center.latitude] forKey:@"latitude"];
        [geofenceDict setValue:[NSString stringWithFormat:@"%.6f", geofenceToDelete.center.longitude] forKey:@"longitude"];
        [geofenceDict setValue:[NSString stringWithFormat:@"%.6f", geofenceToDelete.radius] forKey:@"radius"];
        [geofenceDict setValue:geofenceToDelete.name forKey:@"name"];
        [geofenceDict setValue:geofenceToDelete.tags forKey:@"tags"];
        
        NSNumber *geofenceID = [NSNumber numberWithInt:(int)[geofenceToDelete.geofenceID integerValue]];
        [geofenceDict setValue:geofenceID forKey:@"id"];
        
        // Remove geofence from our array
        if ([self.geofenceArray containsObject:geofenceToDelete]) {
            [self.geofenceArray removeObject:geofenceToDelete];
        }
        
        [[CCHGeofenceService sharedInstance] deleteGeofence:geofenceDict completionHandler:^(NSError *error) {
            if (!error) {
                
                // Synchronize the sensor pipeline with ContextHub (if you have push set up correctly, you can skip this step!)
                [[CCHSensorPipeline sharedInstance] synchronize:^(NSError *error) {
                    
                    if (!error) {
                        NSLog(@"GF: Successfully deleted geofence %@ on ContextHub", geofenceToDelete.name);
                        
                        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
                        
                        // Synchronize geofences (this would not need to be done if push were enabled)
                        [self refreshGeofences];
                    } else {
                        NSLog(@"GF: Could not synchronize deletion of geofence %@ on ContextHub", geofenceToDelete.name);
                    }
                    
                    // Stop table editing
                    [self.tableView setEditing:FALSE animated:YES];
                }];
            } else {
                [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Error deleting geofence from ContextHub" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Ok", nil] show];
                NSLog(@"GF: Could not delete geofence %@ on ContextHub", geofenceToDelete.name);
            }
        }];
    }
}

@end