//
//  WAResultsViewController.h
//  Wahmbulance
//
//  Created by Jonathan Uy on 10/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <MapKit/MapKit.h>
#import <UIKit/UIKit.h>

@interface WAResultsViewController : UIViewController <CLLocationManagerDelegate, MKMapViewDelegate, UISearchBarDelegate>
{
    IBOutlet MKMapView *mapView;
    IBOutlet UIBarButtonItem *filterBtn;
    IBOutlet UIBarButtonItem *mapListBtn;
    IBOutlet UISearchBar *searchBar;
    IBOutlet UITableView *listView;
    IBOutlet UIView *filterView;
    IBOutlet UIButton *filterSubmitBtn;
    
    CLLocationManager *locationManager;
    BOOL didUpdateLocation;
}

@property (nonatomic) CGRect searchBarOriginalFrame;

- (IBAction)toggleMapListView:(id)_sender;
- (IBAction)toggleFilterView:(id)_sender;
- (IBAction)filterSubmit:(id)_sender;
- (void)updateMapToLocation:(CLLocation *)_location;
- (void)executeSearch:(NSString *)_searchTerm;
- (void)plotPoints:(NSString *)_jsonResponse;

@end
