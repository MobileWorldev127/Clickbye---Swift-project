#import <Foundation/Foundation.h>
#import <Analytics/SEGIntegration.h>
#import <Analytics/SEGAnalytics.h>


@interface SEGApptimizeIntegration : NSObject <SEGIntegration>

@property (nonatomic, readonly) NSDictionary *settings;
@property (nonatomic, readonly) SEGAnalytics *analytics;
@property (nonatomic, strong) Class apptimizeClass;

- (instancetype)initWithSettings:(NSDictionary *)settings analytics:(SEGAnalytics *)analytics apptimize:(id)apptimizeClass;

@end
