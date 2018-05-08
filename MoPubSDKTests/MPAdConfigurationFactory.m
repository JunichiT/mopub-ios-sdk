//
//  MPAdConfigurationFactory.m
//  MoPub
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import "MPAdConfigurationFactory.h"
#import "MPNativeAd.h"

#define kImpressionTrackerURLsKey   @"imptracker"
#define kClickTrackerURLKey         @"clktracker"
#define kDefaultActionURLKey        @"clk"


@implementation MPAdConfigurationFactory

#pragma mark - Native

+ (NSMutableDictionary *)defaultNativeAdHeaders
{
    return [@{
              kMPAdTypeHeaderKey: kMPAdTypeNative,
              kMPFailUrlHeaderKey: @"http://ads.mopub.com/m/failURL",
              kMPRefreshTimeHeaderKey: @"61",
              } mutableCopy];
}

+ (NSMutableDictionary *)defaultNativeProperties
{
    return [@{@"ctatext":@"Download",
              @"iconimage":@"image_url",
              @"mainimage":@"image_url",
              @"text":@"This is an ad",
              @"title":@"Sample Ad Title",
              kClickTrackerURLKey:@"http://ads.mopub.com/m/clickThroughTracker?a=1",
              kImpressionTrackerURLsKey:@[@"http://ads.mopub.com/m/impressionTracker"],
              kDefaultActionURLKey:@"http://mopub.com"
              } mutableCopy];
}

+ (MPAdConfiguration *)defaultNativeAdConfiguration
{
    return [self defaultNativeAdConfigurationWithHeaders:nil properties:nil];
}

+ (MPAdConfiguration *)defaultNativeAdConfigurationWithNetworkType:(NSString *)type
{
    return [self defaultNativeAdConfigurationWithHeaders:@{kMPAdTypeHeaderKey: type}
                                              properties:nil];
}

+ (MPAdConfiguration *)defaultNativeAdConfigurationWithCustomEventClassName:(NSString *)eventClassName
{
    return [MPAdConfigurationFactory defaultNativeAdConfigurationWithHeaders:@{
                                                                               kMPCustomEventClassNameHeaderKey: eventClassName,
                                                                               kMPAdTypeHeaderKey: @"custom"}
                                                                  properties:nil];
}


+ (MPAdConfiguration *)defaultNativeAdConfigurationWithHeaders:(NSDictionary *)dictionary
                                                    properties:(NSDictionary *)properties
{
    NSMutableDictionary *headers = [self defaultBannerHeaders];
    [headers addEntriesFromDictionary:dictionary];

    NSMutableDictionary *allProperties = [self defaultNativeProperties];
    if (properties) {
        [allProperties addEntriesFromDictionary:properties];
    }

    return [[MPAdConfiguration alloc] initWithHeaders:headers data:[NSJSONSerialization dataWithJSONObject:allProperties options:NSJSONWritingPrettyPrinted error:nil]];
}

#pragma mark - Banners

+ (NSMutableDictionary *)defaultBannerHeaders
{
    return [@{
              kMPAdTypeHeaderKey: kMPAdTypeHtml,
              kMPClickthroughHeaderKey: @"http://ads.mopub.com/m/clickThroughTracker?a=1",
              kMPFailUrlHeaderKey: @"http://ads.mopub.com/m/failURL",
              kMPHeightHeaderKey: @"50",
              kMPImpressionTrackerHeaderKey: @"http://ads.mopub.com/m/impressionTracker",
              kMPInterceptLinksHeaderKey: @"1",
              kMPLaunchpageHeaderKey: @"http://publisher.com",
              kMPRefreshTimeHeaderKey: @"30",
              kMPWidthHeaderKey: @"320"
              } mutableCopy];
}

+ (MPAdConfiguration *)defaultBannerConfiguration
{
    return [self defaultBannerConfigurationWithHeaders:nil HTMLString:nil];
}

+ (MPAdConfiguration *)defaultBannerConfigurationWithNetworkType:(NSString *)type
{
    return [self defaultBannerConfigurationWithHeaders:@{kMPAdTypeHeaderKey: type}
                                            HTMLString:nil];
}

+ (MPAdConfiguration *)defaultBannerConfigurationWithCustomEventClassName:(NSString *)eventClassName
{
    return [MPAdConfigurationFactory defaultBannerConfigurationWithHeaders:@{
                                                                             kMPCustomEventClassNameHeaderKey: eventClassName,
                                                                             kMPAdTypeHeaderKey: @"custom"}
                                                                HTMLString:nil];
}


+ (MPAdConfiguration *)defaultBannerConfigurationWithHeaders:(NSDictionary *)dictionary
                                                  HTMLString:(NSString *)HTMLString
{
    NSMutableDictionary *headers = [self defaultBannerHeaders];
    [headers addEntriesFromDictionary:dictionary];

    HTMLString = HTMLString ? HTMLString : @"Publisher's Ad";

    return [[MPAdConfiguration alloc] initWithHeaders:headers
                                                 data:[HTMLString dataUsingEncoding:NSUTF8StringEncoding]];
}

#pragma mark - Interstitials

+ (NSMutableDictionary *)defaultInterstitialHeaders
{
    return [@{
              kMPAdTypeHeaderKey: kMPAdTypeInterstitial,
              kMPClickthroughHeaderKey: @"http://ads.mopub.com/m/clickThroughTracker?a=1",
              kMPFailUrlHeaderKey: @"http://ads.mopub.com/m/failURL",
              kMPImpressionTrackerHeaderKey: @"http://ads.mopub.com/m/impressionTracker",
              kMPInterceptLinksHeaderKey: @"1",
              kMPLaunchpageHeaderKey: @"http://publisher.com",
              kMPInterstitialAdTypeHeaderKey: kMPAdTypeHtml,
              kMPOrientationTypeHeaderKey: @"p"
              } mutableCopy];
}

+ (MPAdConfiguration *)defaultInterstitialConfiguration
{
    return [self defaultInterstitialConfigurationWithHeaders:nil HTMLString:nil];
}

+ (MPAdConfiguration *)defaultMRAIDInterstitialConfiguration
{
    NSDictionary *headers = @{
                              kMPAdTypeHeaderKey: @"mraid",
                              kMPOrientationTypeHeaderKey: @"p"
                              };

    return [self defaultInterstitialConfigurationWithHeaders:headers
                                                  HTMLString:nil];
}

+ (MPAdConfiguration *)defaultChartboostInterstitialConfigurationWithLocation:(NSString *)location
{
    MPAdConfiguration *configuration = [MPAdConfigurationFactory defaultInterstitialConfigurationWithCustomEventClassName:@"ChartboostInterstitialCustomEvent"];
    NSMutableDictionary *data = [@{@"appId": @"myAppId",
                                   @"appSignature": @"myAppSignature"} mutableCopy];

    if (location) {
        data[@"location"] = location;
    }

    configuration.customEventClassData = data;
    return configuration;
}

+ (MPAdConfiguration *)defaultFakeInterstitialConfiguration
{
    return [self defaultInterstitialConfigurationWithNetworkType:@"fake"];
}

+ (MPAdConfiguration *)defaultInterstitialConfigurationWithNetworkType:(NSString *)type
{
    return [self defaultInterstitialConfigurationWithHeaders:@{kMPInterstitialAdTypeHeaderKey: type}
                                                  HTMLString:nil];
}

+ (MPAdConfiguration *)defaultInterstitialConfigurationWithCustomEventClassName:(NSString *)eventClassName
{
    return [MPAdConfigurationFactory defaultInterstitialConfigurationWithHeaders:@{
                                                                                   kMPCustomEventClassNameHeaderKey: eventClassName,
                                                                                   kMPInterstitialAdTypeHeaderKey: @"custom"}
                                                                      HTMLString:nil];
}

+ (MPAdConfiguration *)defaultInterstitialConfigurationWithHeaders:(NSDictionary *)dictionary
                                                        HTMLString:(NSString *)HTMLString
{
    NSMutableDictionary *headers = [self defaultInterstitialHeaders];
    [headers addEntriesFromDictionary:dictionary];

    HTMLString = HTMLString ? HTMLString : @"Publisher's Interstitial";

    return [[MPAdConfiguration alloc] initWithHeaders:headers
                                                 data:[HTMLString dataUsingEncoding:NSUTF8StringEncoding]];
}

#pragma mark - Rewarded Video
+ (NSMutableDictionary *)defaultRewardedVideoHeaders
{
    return [@{
              kMPAdTypeHeaderKey: @"custom",
              kMPClickthroughHeaderKey: @"http://ads.mopub.com/m/clickThroughTracker?a=1",
              kMPFailUrlHeaderKey: @"http://ads.mopub.com/m/failURL",
              kMPImpressionTrackerHeaderKey: @"http://ads.mopub.com/m/impressionTracker",
              kMPInterceptLinksHeaderKey: @"1",
              kMPLaunchpageHeaderKey: @"http://publisher.com",
              kMPInterstitialAdTypeHeaderKey: kMPAdTypeHtml,
              } mutableCopy];
}

+ (NSMutableDictionary *)defaultRewardedVideoHeadersWithReward
{
    NSMutableDictionary *dict = [[self defaultRewardedVideoHeaders] mutableCopy];
    dict[kMPRewardedVideoCurrencyNameHeaderKey] = @"gold";
    dict[kMPRewardedVideoCurrencyAmountHeaderKey] = @"12";
    return dict;
}

+ (NSMutableDictionary *)defaultRewardedVideoHeadersServerToServer
{
    NSMutableDictionary *dict = [[self defaultRewardedVideoHeaders] mutableCopy];
    dict[kMPRewardedVideoCompletionUrlHeaderKey] = @"http://ads.mopub.com/m/rewarded_video_completion?req=332dbe5798d644309d9d950321d37e3c&reqt=1460590468.0&id=54c94899972a4d4fb00c9cbf0fd08141&cid=303d4529ee3b42e7ac1f5c19caf73515&udid=ifa%3A3E67D059-6F94-4C88-AD2A-72539FE13795&cppck=09CCC";
    return dict;
}

+ (NSMutableDictionary *)defaultNativeVideoHeadersWithTrackers
{
    NSMutableDictionary *dict = [[self defaultNativeAdHeaders] mutableCopy];
    dict[@"X-Video-Trackers"] = @"{\"urls\": [\"http://mopub.com/%%VIDEO_EVENT%%/foo\", \"http://mopub.com/%%VIDEO_EVENT%%/bar\"],\"events\": [\"start\", \"firstQuartile\", \"midpoint\", \"thirdQuartile\", \"complete\"]}";
    return dict;
}

+ (MPAdConfiguration *)defaultRewardedVideoConfiguration
{
    MPAdConfiguration *adConfiguration = [[MPAdConfiguration alloc] initWithHeaders:[self defaultRewardedVideoHeaders] data:nil];
    return adConfiguration;
}

+ (MPAdConfiguration *)defaultRewardedVideoConfigurationWithReward
{
    MPAdConfiguration *adConfiguration = [[MPAdConfiguration alloc] initWithHeaders:[self defaultRewardedVideoHeadersWithReward] data:nil];
    return adConfiguration;
}

+ (MPAdConfiguration *)defaultRewardedVideoConfigurationServerToServer
{
    MPAdConfiguration *adConfiguration = [[MPAdConfiguration alloc] initWithHeaders:[self defaultRewardedVideoHeadersServerToServer] data:nil];
    return adConfiguration;
}

+ (MPAdConfiguration *)defaultNativeVideoConfigurationWithVideoTrackers
{
    MPAdConfiguration *adConfiguration = [[MPAdConfiguration alloc] initWithHeaders:[self defaultNativeVideoHeadersWithTrackers] data:nil];
    return adConfiguration;
}

@end
