//
//  WALocation.h
//  Wahmbulance
//
//  Created by Jonathan Uy on 10/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface WALocation : NSObject <MKAnnotation>

@property (copy) NSString *name;
@property (copy) NSString *street_address;
@property (copy) NSString *city;
@property (copy) NSString *state;
@property (copy) NSString *zip;
@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;

- (id)initWithName:(NSString *)_name
           address:(NSString *)_address
              city:(NSString *)_city
             state:(NSString *)_state
               zip:(NSString *)_zip;

- (id)initWithName:(NSString *)_name
           address:(NSString *)_address
              city:(NSString *)_city
             state:(NSString *)_state
               zip:(NSString *)_zip
        coordinate:(CLLocationCoordinate2D)_coordinate;

@end
