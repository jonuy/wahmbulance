//
//  WAResultsViewController.m
//  Wahmbulance
//
//  Created by Jonathan Uy on 10/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ASIHTTPRequest/ASIHTTPRequest.h"
#import "json-framework/SBJson.h"
#import "MBProgressHUD.h"
#import <QuartzCore/QuartzCore.h>
#import "WALocation.h"
#import "WAResultsViewController.h"

@implementation WAResultsViewController

@synthesize searchBarOriginalFrame;

int LOCATION_ACCURACY_DEFAULT_IN_METERS = 500;
NSTimeInterval SEARCH_BAR_ANIMATION_DURATION = 0.5;

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // UI setup
    if (filterView) {
        filterView.layer.cornerRadius = 6;
        filterView.layer.masksToBounds = YES;
    }
    
    // Location Manager setup
    didUpdateLocation = NO;
    
    locationManager = [[CLLocationManager alloc] init];
    [locationManager setDesiredAccuracy:LOCATION_ACCURACY_DEFAULT_IN_METERS];
    [locationManager startUpdatingLocation];
    [locationManager setDelegate:self];
    
    [searchBar setDelegate:self];
    
    [mapView setDelegate:self];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    [locationManager setDelegate:nil];
    [searchBar setDelegate:nil];
    [mapView setDelegate:nil];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (IBAction)toggleMapListView:(id)_sender
{
    if ([mapView isHidden] && [listView isHidden] == NO) {
        [mapListBtn setTitle:@"List"];
        [mapView setHidden:NO];
        [listView setHidden:YES];
    }
    else if ([mapView isHidden] == NO && [listView isHidden]) {
        [mapListBtn setTitle:@"Map"];
        [mapView setHidden:YES];
        [listView setHidden:NO];
    }
    else {
        NSLog(@"Unable to toggle between map and list views");
    }
    
    if ([filterView isHidden] == NO) {
        [filterView setHidden:YES];
    }
}

////////////////////////////
// Location Manager and Map View
////////////////////////////
- (void)locationManager:(CLLocation *)_manager
    didUpdateToLocation:(CLLocation *)_newLocation
           fromLocation:(CLLocation *)_oldLocation
{
    if (!didUpdateLocation) {
        didUpdateLocation = YES;
        //[locationManager stopUpdatingLocation];
        
        [self updateMapToLocation:_newLocation];
    }
}

- (void)plotPoints:(NSString *)_jsonResponse
{
    // Clear any annotations
    for (id<MKAnnotation> annotation in mapView.annotations) {
        [mapView removeAnnotation:annotation];
    }
    
    NSArray *jsonRoot = [_jsonResponse JSONValue];
    for (NSDictionary *jsonObj in jsonRoot) {
        NSString *name = [jsonObj objectForKey:@"name"];
        NSString *street = [jsonObj objectForKey:@"street"];
        NSString *city = [jsonObj objectForKey:@"city"];
        NSString *state = [jsonObj objectForKey:@"state"];
        NSString *zip = [jsonObj objectForKey:@"zip"];
        NSString *latCoord = [jsonObj objectForKey:@"latCord"];
        NSString *longCoord = [jsonObj objectForKey:@"longCoord"];
        //NSString *type = [jsonObj objectForKey:@"type"];
        
        WALocation *loc = nil;
        if ([latCoord length] > 0 && [longCoord length] > 0) {
            CLLocationCoordinate2D coord;
            coord.latitude = latCoord.doubleValue;
            coord.longitude = longCoord.doubleValue;
            loc = [[WALocation alloc] initWithName:name address:street city:city state:state zip:zip coordinate:coord];
        }
        else {
            loc = [[WALocation alloc] initWithName:name address:street city:city state:state zip:zip];
        }
        
        [mapView addAnnotation:loc];
    }
    
    MKCoordinateRegion region = [mapView region];
    [mapView setRegion:region animated:YES];
}

- (void)updateMapToLocation:(CLLocation *)_location
{
    NSLog(@"updateMapToLocation");
    CLLocationCoordinate2D coord = [_location coordinate];
    
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(coord, LOCATION_ACCURACY_DEFAULT_IN_METERS, LOCATION_ACCURACY_DEFAULT_IN_METERS);
    [mapView setRegion:region animated:YES];
}

// When a map annotation point is added, zoom to it (1500 range)
- (void)mapView:(MKMapView *)mv didAddAnnotationViews:(NSArray *)views
{
    NSLog(@"mapView didAddAnnotationViews");
    MKCoordinateRegion region = [mv region];
	[mv setRegion:region animated:YES];
}

// Override to set a custom image. Called for every annotation added to the map.
- (MKAnnotationView *)mapView:(MKMapView *)_mapView viewForAnnotation:(id<MKAnnotation>)_annotation
{
    NSLog(@"viewForAnnotation");
    
    static NSString *identifier = @"WALocation";
    if ([_annotation isKindOfClass:[WALocation class]]) {
        
        MKPinAnnotationView *annotationView = (MKPinAnnotationView *) [_mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
        if (annotationView == nil) {
            annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:_annotation reuseIdentifier:identifier];
        }
        else {
            annotationView.annotation = _annotation;
        }

        // Setting canShowCallout to NO allows us to create a custom callout
        // instead of using the standard one
        annotationView.canShowCallout = NO;
        
        // Set the image used to mark the annotation
        //annotationView.image = [UIImage imageNamed:@"arrest.png"];

        return annotationView;
    }
    
    return nil;
}

// Called when an annotation view is selected. Override to create a custom callout
- (void)mapView:(MKMapView *)_mapView didSelectAnnotationView:(MKAnnotationView *)_view
{
    NSLog(@"didSelectAnnotationView");
}

// Called when an annotation view is deselected.
- (void)mapView:(MKMapView *)_mapView didDeselectAnnotationView:(MKAnnotationView *)_view
{
    NSLog(@"didDeselectAnnotationView");
}

////////////////////////////
// Search Bar
////////////////////////////
- (void)searchBarCancelButtonClicked:(UISearchBar *)_searchBar
{
    // Resign first responder to dismiss keyboard
    [_searchBar resignFirstResponder];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)_searchBar
{
    // Resign first responder to dismiss keyboard
    [_searchBar resignFirstResponder];
    
    [self executeSearch:[_searchBar text]];
    
    // Show progress HUD
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"Searching...";
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)_searchBar
{
    [UIView animateWithDuration:SEARCH_BAR_ANIMATION_DURATION
                     animations:^ {
                         CGRect screenRect = [[UIScreen mainScreen] bounds];
                         CGFloat screenWidth = screenRect.size.width;
                         
                         [self setSearchBarOriginalFrame:searchBar.frame];
                         CGRect newBounds = [self searchBarOriginalFrame];
                         newBounds.size.width = screenWidth;
                         newBounds.origin.x = 0;
                         searchBar.frame = newBounds;
                         
                         // TODO: not sure which is better/more appropriate to use
                         //[searchBar setNeedsLayout];
                         [searchBar layoutSubviews];
                     }
                     completion:^(BOOL _finished) {
                        [searchBar setShowsCancelButton:YES animated:YES];
                     }];
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)_searchBar
{
    [_searchBar setShowsCancelButton:NO animated:YES];
    
    [UIView animateWithDuration:SEARCH_BAR_ANIMATION_DURATION
                     animations:^ {
                         searchBar.frame = [self searchBarOriginalFrame];
                         [searchBar layoutSubviews];
                     }];
}

- (void)executeSearch:(NSString *)_searchTerm
{
    NSURL *url = [NSURL URLWithString:@"http://localhost/wah.json"];
    
    ASIHTTPRequest *_request = [ASIHTTPRequest requestWithURL:url];
    __weak ASIHTTPRequest *request = _request;
    
    [request startAsynchronous];
    
    [request setCompletionBlock:^ {
        NSString *responseString = [request responseString];
        [self plotPoints:responseString];
        
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    }];
    
    [request setFailedBlock:^ {
        NSLog(@"Search failed");
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    }];
}

////////////////////////////
// Filter
////////////////////////////
- (IBAction)toggleFilterView:(id)_sender
{
    if ([filterView isHidden]) {
        [filterView setHidden:NO];
    }
    else {
        [filterView setHidden:YES];
    }
    NSLog(@"toggleFilterView");
}

- (IBAction)filterSubmit:(id)_sender
{
    [filterView setHidden:YES];
    NSLog(@"filterSubmit");
}

@end
