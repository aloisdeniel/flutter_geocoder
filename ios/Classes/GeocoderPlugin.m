#import "GeocoderPlugin.h"

#import <CoreLocation/CoreLocation.h>

@interface NSError (FlutterError)
@property(readonly, nonatomic) FlutterError *flutterError;
@end

@implementation NSError (FlutterError)
- (FlutterError *)flutterError {
  return [FlutterError errorWithCode:[NSString stringWithFormat:@"Error %d", (int)self.code]
                             message:self.domain
                             details:self.localizedDescription];
}
@end

@implementation GeocoderPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  FlutterMethodChannel* channel = [FlutterMethodChannel
      methodChannelWithName:@"github.com/aloisdeniel/geocoder"
            binaryMessenger:[registrar messenger]];
  GeocoderPlugin* instance = [[GeocoderPlugin alloc] init];
  [registrar addMethodCallDelegate:instance channel:channel];
}

- (void) handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
  if ([@"findAddressesFromCoordinates" isEqualToString:call.method]) {
      NSNumber *longitude = call.arguments[@"longitude"];
      NSNumber *latitude = call.arguments[@"latitude"];
      CLLocation * location = [[CLLocation alloc] initWithLatitude:latitude.doubleValue longitude:longitude.doubleValue];
      [self initializeGeocoder];
      [self.geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
          if (error) {
              return result(error.flutterError);
          }
          result([self placemarksToDictionary:placemarks]);
      }];
  }
  else if ([@"findAddressesFromQuery" isEqualToString:call.method]) {
      NSString *address = call.arguments[@"address"];
      [self initializeGeocoder];
      [self.geocoder geocodeAddressString:address completionHandler:^(NSArray *placemarks, NSError *error) {
          if (error) {
              return result(error.flutterError);
          }
          
          result([self placemarksToDictionary:placemarks]);
      }];
  } else {
    result(FlutterMethodNotImplemented);
  }
}

-(void) initializeGeocoder {
    if (!self.geocoder) {
        self.geocoder = [[CLGeocoder alloc] init];
    }
    
    if (self.geocoder.geocoding) {
        [self.geocoder cancelGeocode];
    }
}

- (NSArray *) placemarksToDictionary:(NSArray *)placemarks {
    
    NSMutableArray *results = [[NSMutableArray alloc] init];

    if(!placemarks) {
        return results;
    }

    for (int i = 0; i < placemarks.count; i++) {
        CLPlacemark* placemark = [placemarks objectAtIndex:i];

        NSArray *lines = placemark.addressDictionary[@"FormattedAddressLines"];
        
        NSDictionary *coordinates = nil;

        if(placemark.location) {
            coordinates = @{
                  @"latitude": [NSNumber numberWithDouble:placemark.location.coordinate.latitude],
                  @"longitude": [NSNumber numberWithDouble:placemark.location.coordinate.longitude],
            };
        }

        NSDictionary *address = @{
                                 @"coordinates": coordinates ?: [NSNull null],
                                 @"featureName": placemark.name ?: [NSNull null],
                                 @"countryName": placemark.country ?: [NSNull null],
                                 @"countryCode": placemark.ISOcountryCode ?: [NSNull null],
                                 @"locality": placemark.locality ?: [NSNull null],
                                 @"subLocality": placemark.subLocality ?: [NSNull null],
                                 @"thoroughfare": placemark.thoroughfare ?: [NSNull null],
                                 @"subThoroughfare": placemark.subThoroughfare ?: [NSNull null],
                                 @"postalCode": placemark.postalCode ?: [NSNull null],
                                 @"adminArea": placemark.administrativeArea ?: [NSNull null],
                                 @"subAdminArea": placemark.subAdministrativeArea ?: [NSNull null],
                                 @"addressLine": [lines componentsJoinedByString:@", "] ?: [NSNull null]
        };
        
        [results addObject:address];


    }

    return results;
 }

@end
