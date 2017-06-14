#import "SEGApptimizeIntegration.h"
#import <Apptimize/Apptimize.h>
#import <Apptimize/Apptimize+Segment.h>

@implementation SEGApptimizeIntegration

static NSString *const APPKEY_SEG_KEY = @"appkey";
static NSString *const LISTEN_SEG_KEY = @"listen";
static NSString *const USER_ID_TAG = @"user_id";
static NSString *const VIEWED_TAG_FORMAT = @"Viewed %@ screen";

- (instancetype)initWithSettings:(NSDictionary *)settings analytics:(SEGAnalytics *)analytics apptimize:(id)apptimizeClass
{
    if (self = [super init]) {
        _settings = settings;
        _analytics = analytics;
        _apptimizeClass = apptimizeClass;

        NSString *appKey = [self.settings objectForKey:APPKEY_SEG_KEY];
        if( appKey == nil ) {
            NSLog( @"no appKey found in settings, thus Apptimize integration will not be active" );
            return nil;
        }
        NSDictionary *options = [self buildApptimizeOptions];
        void(^start_block)(void) = ^{
            [_apptimizeClass startApptimizeWithApplicationKey:appKey options:options];
            [self setupExperimentTracking];
        };
        static dispatch_once_t segPredicate;
        dispatch_once( &segPredicate, ^{
            if( [NSThread isMainThread] ) {
                start_block();
            } else {
                dispatch_async( dispatch_get_main_queue(), start_block );
            }
        } );
    }
    return self;
}

- (nonnull NSDictionary*)buildApptimizeOptions
{
    NSMutableDictionary *options = [NSMutableDictionary new];
    [options setObject:[NSNumber numberWithBool:FALSE] forKey:ApptimizeEnableThirdPartyEventImportingOption];
    return options;
}

- (void) setupExperimentTracking
{
    BOOL enable = ((NSNumber*)[self.settings objectForKey:LISTEN_SEG_KEY]).boolValue;
    if( enable ) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(experimentDidGetViewed:)
                                                     name:ApptimizeTestRunNotification
                                                   object:nil];
    }
}

- (void)experimentDidGetViewed:(NSNotification *)notification
{
    if (!notification.userInfo[ApptimizeTestFirstRunUserInfoKey]) {
        return;
    }

    // Apptimize doesn't notify with IDs, so we iterate over all experiments to find the matching one.
    NSString *name = notification.userInfo[ApptimizeTestNameUserInfoKey];
    NSString *variant = notification.userInfo[ApptimizeVariantNameUserInfoKey];
    [[_apptimizeClass testInfo] enumerateKeysAndObjectsUsingBlock:^(id key, id<ApptimizeTestInfo> experiment, BOOL *stop) {
        BOOL match = [experiment.testName isEqualToString:name] && [experiment.enrolledVariantName isEqualToString:variant];
        if (!match) {
            return;
        }
        [self.analytics track:@"Experiment Viewed"
                   properties:@{
                       @"experimentId" : [experiment testID],
                       @"experimentName" : [experiment testName],
                       @"variationId" : [experiment enrolledVariantID],
                       @"variationName" : [experiment enrolledVariantName]
                   }];
        *stop = YES;
    }];
}

- (void)identify:(SEGIdentifyPayload *)payload
{
    if (payload.userId != nil) {
        [_apptimizeClass setUserAttributeString:payload.userId forKey:USER_ID_TAG];
    }

    if (payload.traits) {
        [_apptimizeClass SEG_setUserAttributesFromDictionary:payload.traits];
    }
}

- (void)track:(SEGTrackPayload *)payload
{
    [_apptimizeClass SEG_track:payload.event attributes:payload.properties];
}

- (void)screen:(SEGScreenPayload *)payload
{
    NSString *screenEvent = [NSString stringWithFormat:VIEWED_TAG_FORMAT, payload.name];
    [_apptimizeClass SEG_track:screenEvent attributes:payload.properties];
}

@end
