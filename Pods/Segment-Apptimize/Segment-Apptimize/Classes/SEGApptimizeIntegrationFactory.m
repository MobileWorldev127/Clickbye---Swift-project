#import "SEGApptimizeIntegrationFactory.h"
#import "SEGApptimizeIntegration.h"
#import <Apptimize/Apptimize.h>
#import <Apptimize/Apptimize+Segment.h>


@implementation SEGApptimizeIntegrationFactory

+ (instancetype)instance
{
    static dispatch_once_t once;
    static SEGApptimizeIntegrationFactory *sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init
{
    self = [super init];
    return self;
}

- (id<SEGIntegration>)createWithSettings:(NSDictionary *)settings forAnalytics:(SEGAnalytics *)analytics
{
    return [[SEGApptimizeIntegration alloc] initWithSettings:settings analytics:analytics apptimize:[Apptimize class]];
}

- (NSString *)key
{
    return @"Apptimize";
}

@end
