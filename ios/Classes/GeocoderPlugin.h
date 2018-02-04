#import <Flutter/Flutter.h>

#import <CoreLocation/CoreLocation.h>

@interface GeocoderPlugin : NSObject<FlutterPlugin>
@property (nonatomic, strong) CLGeocoder *geocoder;
@end
