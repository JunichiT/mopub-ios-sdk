//
//  MPAdConfiguration.m
//  MoPub
//
//  Copyright (c) 2012 MoPub, Inc. All rights reserved.
//

#import "MPAdConfiguration.h"

#import "MPConstants.h"
#import "MPLogging.h"
#import "math.h"
#import "NSJSONSerialization+MPAdditions.h"
#import "MPRewardedVideoReward.h"
#import "MOPUBExperimentProvider.h"
#import "MPViewabilityTracker.h"
#import "NSString+MPAdditions.h"

#if MP_HAS_NATIVE_PACKAGE
#import "MPVASTTrackingEvent.h"
#endif

NSString * const kMPAdTypeHeaderKey = @"X-Adtype";
NSString * const kMPAdUnitWarmingUpHeaderKey = @"X-Warmup";
NSString * const kMPClickthroughHeaderKey = @"X-Clickthrough";
NSString * const kMPCreativeIdHeaderKey = @"X-CreativeId";
NSString * const kMPCustomSelectorHeaderKey = @"X-Customselector";
NSString * const kMPCustomEventClassNameHeaderKey = @"X-Custom-Event-Class-Name";
NSString * const kMPCustomEventClassDataHeaderKey = @"X-Custom-Event-Class-Data";
NSString * const kMPFailUrlHeaderKey = @"X-Failurl";
NSString * const kMPHeightHeaderKey = @"X-Height";
NSString * const kMPImpressionTrackerHeaderKey = @"X-Imptracker";
NSString * const kMPInterceptLinksHeaderKey = @"X-Interceptlinks";
NSString * const kMPLaunchpageHeaderKey = @"X-Launchpage";
NSString * const kMPNativeSDKParametersHeaderKey = @"X-Nativeparams";
NSString * const kMPNetworkTypeHeaderKey = @"X-Networktype";
NSString * const kMPRefreshTimeHeaderKey = @"X-Refreshtime";
NSString * const kMPAdTimeoutHeaderKey = @"X-AdTimeout";
NSString * const kMPScrollableHeaderKey = @"X-Scrollable";
NSString * const kMPWidthHeaderKey = @"X-Width";
NSString * const kMPDspCreativeIdKey = @"X-DspCreativeid";
NSString * const kMPPrecacheRequiredKey = @"X-PrecacheRequired";
NSString * const kMPIsVastVideoPlayerKey = @"X-VastVideoPlayer";

NSString * const kMPInterstitialAdTypeHeaderKey = @"X-Fulladtype";
NSString * const kMPOrientationTypeHeaderKey = @"X-Orientation";

NSString * const kMPNativeImpressionMinVisiblePixelsHeaderKey = @"X-Native-Impression-Min-Px"; // The pixels header takes priority over percentage, but percentage is left for backwards compatibility
NSString * const kMPNativeImpressionMinVisiblePercentHeaderKey = @"X-Impression-Min-Visible-Percent";
NSString * const kMPNativeImpressionVisibleMsHeaderKey = @"X-Impression-Visible-Ms";
NSString * const kMPNativeVideoPlayVisiblePercentHeaderKey = @"X-Play-Visible-Percent";
NSString * const kMPNativeVideoPauseVisiblePercentHeaderKey = @"X-Pause-Visible-Percent";
NSString * const kMPNativeVideoMaxBufferingTimeMsHeaderKey = @"X-Max-Buffer-Ms";
NSString * const kMPNativeVideoTrackersHeaderKey = @"X-Video-Trackers";

NSString * const kMPBannerImpressionVisableMsHeaderKey = @"X-Banner-Impression-Min-Ms";
NSString * const kMPBannerImpressionMinPixelHeaderKey = @"X-Banner-Impression-Min-Pixels";

NSString * const kMPAdTypeHtml = @"html";
NSString * const kMPAdTypeInterstitial = @"interstitial";
NSString * const kMPAdTypeMraid = @"mraid";
NSString * const kMPAdTypeClear = @"clear";
NSString * const kMPAdTypeNative = @"json";
NSString * const kMPAdTypeNativeVideo = @"json_video";

// rewarded video
NSString * const kMPRewardedVideoCurrencyNameHeaderKey = @"X-Rewarded-Video-Currency-Name";
NSString * const kMPRewardedVideoCurrencyAmountHeaderKey = @"X-Rewarded-Video-Currency-Amount";
NSString * const kMPRewardedVideoCompletionUrlHeaderKey = @"X-Rewarded-Video-Completion-Url";
NSString * const kMPRewardedCurrenciesHeaderKey = @"X-Rewarded-Currencies";

// rewarded playables
NSString * const kMPRewardedPlayableDurationHeaderKey = @"X-Rewarded-Duration";
NSString * const kMPRewardedPlayableRewardOnClickHeaderKey = @"X-Should-Reward-On-Click";

// native video
NSString * const kMPNativeVideoTrackerUrlMacro = @"%%VIDEO_EVENT%%";
NSString * const kMPNativeVideoTrackerEventsHeaderKey = @"events";
NSString * const kMPNativeVideoTrackerUrlsHeaderKey = @"urls";
NSString * const kMPNativeVideoTrackerEventDictionaryKey = @"event";
NSString * const kMPNativeVideoTrackerTextDictionaryKey = @"text";

// clickthrough experiment
NSString * const kMPClickthroughExperimentBrowserAgent = @"X-Browser-Agent";
static const NSInteger kMPMaximumVariantForClickthroughExperiment = 2;

// viewability
NSString * const kMPViewabilityDisableHeaderKey = @"X-Disable-Viewability";


@interface MPAdConfiguration ()

@property (nonatomic, copy) NSString *adResponseHTMLString;
@property (nonatomic, strong, readwrite) NSArray *availableRewards;
@property (nonatomic) MOPUBDisplayAgentType clickthroughExperimentBrowserAgent;

- (MPAdType)adTypeFromHeaders:(NSDictionary *)headers;
- (NSString *)networkTypeFromHeaders:(NSDictionary *)headers;
- (NSTimeInterval)refreshIntervalFromHeaders:(NSDictionary *)headers;
- (NSDictionary *)dictionaryFromHeaders:(NSDictionary *)headers forKey:(NSString *)key;
- (NSURL *)URLFromHeaders:(NSDictionary *)headers forKey:(NSString *)key;
- (Class)setUpCustomEventClassFromHeaders:(NSDictionary *)headers;

@end

////////////////////////////////////////////////////////////////////////////////////////////////////

@implementation MPAdConfiguration

- (id)initWithHeaders:(NSDictionary *)headers data:(NSData *)data
{
    self = [super init];
    if (self) {
        self.adResponseData = data;

        self.adType = [self adTypeFromHeaders:headers];

        self.adUnitWarmingUp = [[headers objectForKey:kMPAdUnitWarmingUpHeaderKey] boolValue];

        self.networkType = [self networkTypeFromHeaders:headers];
        self.networkType = self.networkType ? self.networkType : @"";

        self.preferredSize = CGSizeMake([[headers objectForKey:kMPWidthHeaderKey] floatValue],
                                        [[headers objectForKey:kMPHeightHeaderKey] floatValue]);

        self.clickTrackingURL = [self URLFromHeaders:headers
                                              forKey:kMPClickthroughHeaderKey];
        self.impressionTrackingURL = [self URLFromHeaders:headers
                                                   forKey:kMPImpressionTrackerHeaderKey];
        self.failoverURL = [self URLFromHeaders:headers
                                         forKey:kMPFailUrlHeaderKey];
        self.interceptURLPrefix = [self URLFromHeaders:headers
                                                forKey:kMPLaunchpageHeaderKey];

        NSNumber *shouldInterceptLinks = [headers objectForKey:kMPInterceptLinksHeaderKey];
        self.shouldInterceptLinks = shouldInterceptLinks ? [shouldInterceptLinks boolValue] : YES;
        self.scrollable = [[headers objectForKey:kMPScrollableHeaderKey] boolValue];
        self.refreshInterval = [self refreshIntervalFromHeaders:headers];
        self.adTimeoutInterval = [self timeIntervalFromHeaders:headers forKey:kMPAdTimeoutHeaderKey];


        self.nativeSDKParameters = [self dictionaryFromHeaders:headers
                                                        forKey:kMPNativeSDKParametersHeaderKey];
        self.customSelectorName = [headers objectForKey:kMPCustomSelectorHeaderKey];

        self.orientationType = [self orientationTypeFromHeaders:headers];

        self.customEventClass = [self setUpCustomEventClassFromHeaders:headers];

        self.customEventClassData = [self customEventClassDataFromHeaders:headers];

        self.dspCreativeId = [headers objectForKey:kMPDspCreativeIdKey];

        self.precacheRequired = [[headers objectForKey:kMPPrecacheRequiredKey] boolValue];

        self.isVastVideoPlayer = [[headers objectForKey:kMPIsVastVideoPlayerKey] boolValue];

        self.creationTimestamp = [NSDate date];

        self.creativeId = [headers objectForKey:kMPCreativeIdHeaderKey];

        self.headerAdType = [headers objectForKey:kMPAdTypeHeaderKey];

        self.nativeVideoPlayVisiblePercent = [self percentFromHeaders:headers forKey:kMPNativeVideoPlayVisiblePercentHeaderKey];

        self.nativeVideoPauseVisiblePercent = [self percentFromHeaders:headers forKey:kMPNativeVideoPauseVisiblePercentHeaderKey];

        self.nativeImpressionMinVisiblePixels = [[self adAmountFromHeaders:headers key:kMPNativeImpressionMinVisiblePixelsHeaderKey] floatValue];

        self.nativeImpressionMinVisiblePercent = [self percentFromHeaders:headers forKey:kMPNativeImpressionMinVisiblePercentHeaderKey];

        self.nativeImpressionMinVisibleTimeInterval = [self timeIntervalFromMsHeaders:headers forKey:kMPNativeImpressionVisibleMsHeaderKey];

        self.nativeVideoMaxBufferingTime = [self timeIntervalFromMsHeaders:headers forKey:kMPNativeVideoMaxBufferingTimeMsHeaderKey];
#if MP_HAS_NATIVE_PACKAGE
        self.nativeVideoTrackers = [self nativeVideoTrackersFromHeaders:headers key:kMPNativeVideoTrackersHeaderKey];
#endif

        self.impressionMinVisibleTimeInSec = [self timeIntervalFromMsHeaders:headers forKey:kMPBannerImpressionVisableMsHeaderKey];
        self.impressionMinVisiblePixels = [[self adAmountFromHeaders:headers key:kMPBannerImpressionMinPixelHeaderKey] floatValue];

        // rewarded video

        // Attempt to parse the multiple currency header first since this will take
        // precedence over the older single currency approach.
        self.availableRewards = [self parseAvailableRewardsFromHeaders:headers];
        if (self.availableRewards != nil) {
            // Multiple currencies exist. We will select the first entry in the list
            // as the default selected reward.
            if (self.availableRewards.count > 0) {
                self.selectedReward = self.availableRewards[0];
            }
            // In the event that the list of available currencies is empty, we will
            // follow the behavior from the single currency approach and create an unspecified reward.
            else {
                MPRewardedVideoReward * defaultReward = [[MPRewardedVideoReward alloc] initWithCurrencyType:kMPRewardedVideoRewardCurrencyTypeUnspecified amount:@(kMPRewardedVideoRewardCurrencyAmountUnspecified)];
                self.availableRewards = [NSArray arrayWithObject:defaultReward];
                self.selectedReward = defaultReward;
            }
        }
        // Multiple currencies are not available; attempt to process single currency
        // headers.
        else {
            NSString *currencyName = [headers objectForKey:kMPRewardedVideoCurrencyNameHeaderKey] ?: kMPRewardedVideoRewardCurrencyTypeUnspecified;

            NSNumber *currencyAmount = [self adAmountFromHeaders:headers key:kMPRewardedVideoCurrencyAmountHeaderKey];
            if (currencyAmount.integerValue <= 0) {
                currencyAmount = @(kMPRewardedVideoRewardCurrencyAmountUnspecified);
            }

            MPRewardedVideoReward * reward = [[MPRewardedVideoReward alloc] initWithCurrencyType:currencyName amount:currencyAmount];
            self.availableRewards = [NSArray arrayWithObject:reward];
            self.selectedReward = reward;
        }

        self.rewardedVideoCompletionUrl = [headers objectForKey:kMPRewardedVideoCompletionUrlHeaderKey];

        // rewarded playables
        self.rewardedPlayableDuration = [self timeIntervalFromHeaders:headers forKey:kMPRewardedPlayableDurationHeaderKey];
        self.rewardedPlayableShouldRewardOnClick = [[headers objectForKey:kMPRewardedPlayableRewardOnClickHeaderKey] boolValue];

        // clickthrough experiment
        self.clickthroughExperimentBrowserAgent = [self clickthroughExperimentVariantFromHeaders:headers forKey:kMPClickthroughExperimentBrowserAgent];
        [MOPUBExperimentProvider setDisplayAgentFromAdServer:self.clickthroughExperimentBrowserAgent];

        // viewability
        NSString * disabledViewabilityValue = [headers objectForKey:kMPViewabilityDisableHeaderKey];
        NSNumber * disabledViewabilityVendors = disabledViewabilityValue != nil ? [disabledViewabilityValue safeIntegerValue] : nil;
        if (disabledViewabilityVendors != nil &&
            [disabledViewabilityVendors integerValue] >= MPViewabilityOptionNone &&
            [disabledViewabilityVendors integerValue] <= MPViewabilityOptionAll) {
            MPViewabilityOption vendorsToDisable = (MPViewabilityOption)([disabledViewabilityVendors integerValue]);
            [MPViewabilityTracker disableViewability:vendorsToDisable];
        }
    }
    return self;
}

- (Class)setUpCustomEventClassFromHeaders:(NSDictionary *)headers
{
    NSString *customEventClassName = [headers objectForKey:kMPCustomEventClassNameHeaderKey];

    NSMutableDictionary *convertedCustomEvents = [NSMutableDictionary dictionary];
    if (self.adType == MPAdTypeBanner) {
        [convertedCustomEvents setObject:@"MPGoogleAdMobBannerCustomEvent" forKey:@"admob_native"];
        [convertedCustomEvents setObject:@"MPMillennialBannerCustomEvent" forKey:@"millennial_native"];
        [convertedCustomEvents setObject:@"MPHTMLBannerCustomEvent" forKey:@"html"];
        [convertedCustomEvents setObject:@"MPMRAIDBannerCustomEvent" forKey:@"mraid"];
        [convertedCustomEvents setObject:@"MOPUBNativeVideoCustomEvent" forKey:@"json_video"];
        [convertedCustomEvents setObject:@"MPMoPubNativeCustomEvent" forKey:@"json"];
    } else if (self.adType == MPAdTypeInterstitial) {
        [convertedCustomEvents setObject:@"MPGoogleAdMobInterstitialCustomEvent" forKey:@"admob_full"];
        [convertedCustomEvents setObject:@"MPMillennialInterstitialCustomEvent" forKey:@"millennial_full"];
        [convertedCustomEvents setObject:@"MPHTMLInterstitialCustomEvent" forKey:@"html"];
        [convertedCustomEvents setObject:@"MPMRAIDInterstitialCustomEvent" forKey:@"mraid"];
        [convertedCustomEvents setObject:@"MPMoPubRewardedVideoCustomEvent" forKey:@"rewarded_video"];
        [convertedCustomEvents setObject:@"MPMoPubRewardedPlayableCustomEvent" forKey:@"rewarded_playable"];
    }
    if ([convertedCustomEvents objectForKey:self.networkType]) {
        customEventClassName = [convertedCustomEvents objectForKey:self.networkType];
    }

    Class customEventClass = NSClassFromString(customEventClassName);

    if (customEventClassName && !customEventClass) {
        MPLogWarn(@"Could not find custom event class named %@", customEventClassName);
    }

    return customEventClass;
}



- (NSDictionary *)customEventClassDataFromHeaders:(NSDictionary *)headers
{
    NSDictionary *result = [self dictionaryFromHeaders:headers forKey:kMPCustomEventClassDataHeaderKey];
    if (!result) {
        result = [self dictionaryFromHeaders:headers forKey:kMPNativeSDKParametersHeaderKey];
    }
    return result;
}


- (BOOL)hasPreferredSize
{
    return (self.preferredSize.width > 0 && self.preferredSize.height > 0);
}

- (NSString *)adResponseHTMLString
{
    if (!_adResponseHTMLString) {
        self.adResponseHTMLString = [[NSString alloc] initWithData:self.adResponseData
                                                           encoding:NSUTF8StringEncoding];
    }

    return _adResponseHTMLString;
}

- (NSString *)clickDetectionURLPrefix
{
    return self.interceptURLPrefix.absoluteString ? self.interceptURLPrefix.absoluteString : @"";
}

#pragma mark - Private

- (MPAdType)adTypeFromHeaders:(NSDictionary *)headers
{
    NSString *adTypeString = [headers objectForKey:kMPAdTypeHeaderKey];

    if ([adTypeString isEqualToString:@"interstitial"] || [adTypeString isEqualToString:@"rewarded_video"] || [adTypeString isEqualToString:@"rewarded_playable"]) {
        return MPAdTypeInterstitial;
    } else if (adTypeString &&
               [headers objectForKey:kMPOrientationTypeHeaderKey]) {
        return MPAdTypeInterstitial;
    } else if (adTypeString) {
        return MPAdTypeBanner;
    } else {
        return MPAdTypeUnknown;
    }
}

- (NSString *)networkTypeFromHeaders:(NSDictionary *)headers
{
    NSString *adTypeString = [headers objectForKey:kMPAdTypeHeaderKey];
    if ([adTypeString isEqualToString:@"interstitial"]) {
        return [headers objectForKey:kMPInterstitialAdTypeHeaderKey];
    } else {
        return adTypeString;
    }
}

- (NSURL *)URLFromHeaders:(NSDictionary *)headers forKey:(NSString *)key
{
    NSString *URLString = [headers objectForKey:key];
    return URLString ? [NSURL URLWithString:URLString] : nil;
}

- (NSDictionary *)dictionaryFromHeaders:(NSDictionary *)headers forKey:(NSString *)key
{
    NSData *data = [(NSString *)[headers objectForKey:key] dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *JSONFromHeaders = nil;
    if (data) {
        JSONFromHeaders = [NSJSONSerialization mp_JSONObjectWithData:data options:NSJSONReadingMutableContainers clearNullObjects:YES error:nil];
    }
    return JSONFromHeaders;
}

- (NSTimeInterval)refreshIntervalFromHeaders:(NSDictionary *)headers
{
    NSString *intervalString = [headers objectForKey:kMPRefreshTimeHeaderKey];
    NSTimeInterval interval = -1;
    if (intervalString) {
        interval = [intervalString doubleValue];
        if (interval < MINIMUM_REFRESH_INTERVAL) {
            interval = MINIMUM_REFRESH_INTERVAL;
        }
    }
    return interval;
}

- (NSTimeInterval)timeIntervalFromHeaders:(NSDictionary *)headers forKey:(NSString *)key
{
    NSString *intervalString = [headers objectForKey:key];
    NSTimeInterval interval = -1;
    if (intervalString) {
        int parsedInt = -1;
        BOOL isNumber = [[NSScanner scannerWithString:intervalString] scanInt:&parsedInt];
        if (isNumber && parsedInt >= 0) {
            interval = parsedInt;
        }
    }

    return interval;
}

- (NSTimeInterval)timeIntervalFromMsHeaders:(NSDictionary *)headers forKey:(NSString *)key
{
    NSString *msString = [headers objectForKey:key];
    NSTimeInterval interval = -1;
    if (msString) {
        int parsedInt = -1;
        BOOL isNumber = [[NSScanner scannerWithString:msString] scanInt:&parsedInt];
        if (isNumber && parsedInt >= 0) {
            interval = parsedInt / 1000.0f;
        }
    }

    return interval;
}

- (NSInteger)percentFromHeaders:(NSDictionary *)headers forKey:(NSString *)key
{
    NSString *percentString = [headers objectForKey:key];
    NSInteger percent = -1;
    if (percentString) {
        int parsedInt = -1;
        BOOL isNumber = [[NSScanner scannerWithString:percentString] scanInt:&parsedInt];
        if (isNumber && parsedInt >= 0 && parsedInt <= 100) {
            percent = parsedInt;
        }
    }

    return percent;
}

- (NSNumber *)adAmountFromHeaders:(NSDictionary *)headers key:(NSString *)key
{
    NSString *amountString = [headers objectForKey:key];
    NSNumber *amount = @(-1);
    if (amountString) {
        int parsedInt = -1;
        BOOL isNumber = [[NSScanner scannerWithString:amountString] scanInt:&parsedInt];
        if (isNumber && parsedInt >= 0) {
            amount = @(parsedInt);
        }
    }

    return amount;
}

- (MPInterstitialOrientationType)orientationTypeFromHeaders:(NSDictionary *)headers
{
    NSString *orientation = [headers objectForKey:kMPOrientationTypeHeaderKey];
    if ([orientation isEqualToString:@"p"]) {
        return MPInterstitialOrientationTypePortrait;
    } else if ([orientation isEqualToString:@"l"]) {
        return MPInterstitialOrientationTypeLandscape;
    } else {
        return MPInterstitialOrientationTypeAll;
    }
}

#if MP_HAS_NATIVE_PACKAGE
- (NSDictionary *)nativeVideoTrackersFromHeaders:(NSDictionary *)headers key:(NSString *)key
{
    NSDictionary *dictFromHeader = [self dictionaryFromHeaders:headers forKey:key];
    if (!dictFromHeader) {
        return nil;
    }
    NSMutableDictionary *videoTrackerDict = [NSMutableDictionary new];
    NSArray *events = dictFromHeader[kMPNativeVideoTrackerEventsHeaderKey];
    NSArray *urls = dictFromHeader[kMPNativeVideoTrackerUrlsHeaderKey];
    NSSet *supportedEvents = [NSSet setWithObjects:MPVASTTrackingEventTypeStart, MPVASTTrackingEventTypeFirstQuartile, MPVASTTrackingEventTypeMidpoint,  MPVASTTrackingEventTypeThirdQuartile, MPVASTTrackingEventTypeComplete, nil];
    for (NSString *event in events) {
        if (![supportedEvents containsObject:event]) {
            continue;
        }
        [self setVideoTrackers:videoTrackerDict event:event urls:urls];
    }
    if (videoTrackerDict.count == 0) {
        return nil;
    }
    return videoTrackerDict;
}

- (void)setVideoTrackers:(NSMutableDictionary *)videoTrackerDict event:(NSString *)event urls:(NSArray *)urls {
    NSMutableArray *trackers = [NSMutableArray new];
    for (NSString *url in urls) {
        if ([url rangeOfString:kMPNativeVideoTrackerUrlMacro].location != NSNotFound) {
            NSString *trackerUrl = [url stringByReplacingOccurrencesOfString:kMPNativeVideoTrackerUrlMacro withString:event];
            NSDictionary *dict = @{kMPNativeVideoTrackerEventDictionaryKey:event, kMPNativeVideoTrackerTextDictionaryKey:trackerUrl};
            MPVASTTrackingEvent *tracker = [[MPVASTTrackingEvent alloc] initWithDictionary:dict];
            [trackers addObject:tracker];
        }
    }
    if (trackers.count > 0) {
        videoTrackerDict[event] = trackers;
    }
}

#endif

- (NSArray *)parseAvailableRewardsFromHeaders:(NSDictionary *)headers {
    // The X-Rewarded-Currencies header key doesn't exist. This is probably
    // not a rewarded ad.
    NSDictionary * currencies = [self dictionaryFromHeaders:headers forKey:kMPRewardedCurrenciesHeaderKey];
    if (currencies == nil) {
        return nil;
    }

    // Either the list of available rewards doesn't exist or is empty.
    // This is an error.
    NSArray * rewards = [currencies objectForKey:@"rewards"];
    if (rewards.count == 0) {
        MPLogError(@"No available rewards found.");
        return nil;
    }

    // Parse the list of JSON rewards into objects.
    NSMutableArray * availableRewards = [NSMutableArray arrayWithCapacity:rewards.count];
    [rewards enumerateObjectsUsingBlock:^(NSDictionary * rewardDict, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString * name = rewardDict[@"name"] ?: kMPRewardedVideoRewardCurrencyTypeUnspecified;
        NSNumber * amount = rewardDict[@"amount"] ?: @(kMPRewardedVideoRewardCurrencyAmountUnspecified);

        MPRewardedVideoReward * reward = [[MPRewardedVideoReward alloc] initWithCurrencyType:name amount:amount];
        [availableRewards addObject:reward];
    }];

    return availableRewards;
}

- (MOPUBDisplayAgentType)clickthroughExperimentVariantFromHeaders:(NSDictionary *)headers forKey:(NSString *)key
{
    NSString *variantString = [headers objectForKey:key];
    NSInteger variant = 0;
    if (variantString) {
        int parsedInt = -1;
        BOOL isNumber = [[NSScanner scannerWithString:variantString] scanInt:&parsedInt];
        if (isNumber && parsedInt >= 0 && parsedInt <= kMPMaximumVariantForClickthroughExperiment) {
            variant = parsedInt;
        }
    }

    return variant;
}

- (BOOL)visibleImpressionTrackingEnabled
{
    if (self.impressionMinVisibleTimeInSec < 0 || self.impressionMinVisiblePixels <= 0) {
        return NO;
    }
    return YES;
}

@end
