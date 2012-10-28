//
//  WALocation.m
//  Wahmbulance
//
//  Created by Jonathan Uy on 10/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "WALocation.h"

@implementation WALocation

@synthesize name, street_address, city, state, zip, coordinate;

- (id)initWithName:(NSString *)_name 
           address:(NSString *)_address 
              city:(NSString *)_city 
             state:(NSString *)_state 
               zip:(NSString *)_zip
{
    self = [super init];
    
    if (self) {
        name = [_name copy];
        street_address = [_address copy];
        city = [_city copy];
        state = [_state copy];
        zip = [_zip copy];
        
        // Convert street address into coordinate
        NSString *query = [NSString stringWithFormat:@"%@, %@, %@, %@ %@", name, street_address, city, state, zip];
        NSLog(@"query: %@", query);
        
        CLGeocoder *geocoder = [[CLGeocoder alloc] init];
        [geocoder geocodeAddressString:query
         
            completionHandler:^(NSArray *placemarks, NSError *error) {
                
                bool gotCoordinate = false;
                for (CLPlacemark* aPlacemark in placemarks) {
                    NSLog(@"lat: %f / long: %f", aPlacemark.location.coordinate.latitude, aPlacemark.location.coordinate.longitude);
                    
                    // For now just take the first response
                    if (!gotCoordinate) {
                        coordinate = aPlacemark.location.coordinate;
                        gotCoordinate = true;
                    }
                }
            }
        ];
    }
    
    return self;
}

- (id)initWithName:(NSString *)_name 
           address:(NSString *)_address 
              city:(NSString *)_city 
             state:(NSString *)_state 
               zip:(NSString *)_zip
        coordinate:(CLLocationCoordinate2D)_coordinate
{
    self = [super init];
    
    if (self) {
        name = [_name copy];
        street_address = [_address copy];
        city = [_city copy];
        state = [_state copy];
        zip = [_zip copy];
        coordinate = _coordinate;
    }
    
    return self;
}

- (NSString *)title
{
    return name;
}

- (NSString *)subtitle
{
    return [NSString stringWithFormat:@"%@, %@, %@ %@", street_address, city, state, zip];
}

@end
