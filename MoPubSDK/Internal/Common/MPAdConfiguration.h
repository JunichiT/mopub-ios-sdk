//
//  MPAdConfiguration.h
//  MoPub
//
//  Copyright (c) 2012 MoPub, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MPGlobal.h"

@class MPRewardedVideoReward;

enum {
    MPAdTypeUnknown = -1,
    MPAdTypeBanner = 0,
    MPAdTypeInterstitial = 1
};
typedef NSUInteger MPAdType;

extern NSString * const kMPAdTypeHeaderKey;
extern NSString * const kMPAdUnitWarmingUpHeaderKey;
extern NSString * const kMPClickthroughHeaderKey;
extern NSString * const kMPCreativeIdHeaderKey;
extern NSString * const kMPCustomSelectorHeaderKey;
extern NSString * const kMPCustomEventClassNameHeaderKey;
extern NSString * const kMPCustomEventClassDataHeaderKey;
extern NSString * const kMPFailUrlHeaderKey;
extern NSString * const kMPHeightHeaderKey;
extern NSString * const kMPImpressionTrackerHeaderKey;
extern NSString * const kMPInterceptLinksHeaderKey;
extern NSString * const kMPLaunchpageHeaderKey;
extern NSString * const kMPNativeSDKParametersHeaderKey;
extern NSString * const kMPNetworkTypeHeaderKey;
extern NSString * const kMPRefreshTimeHeaderKey;
extern NSString * const kMPAdTimeoutHeaderKey;
extern NSString * const kMPScrollableHeaderKey;
extern NSString * const kMPWidthHeaderKey;
extern NSString * const kMPDspCreativeIdKey;
extern NSString * const kMPPrecacheRequiredKey;
extern NSString * const kMPIsVastVideoPlayerKey;
extern NSString * const kMPRewardedVideoCurrencyNameHeaderKey;
extern NSString * const kMPRewardedVideoCurrencyAmountHeaderKey;
extern NSString * const kMPRewardedVideoCompletionUrlHeaderKey;
extern NSString * const kMPRewardedCurrenciesHeaderKey;
extern NSString * const kMPRewardedPlayableDurationHeaderKey;
extern NSString * const kMPRewardedPlayableRewardOnClickHeaderKey;

extern NSString * const kMPInterstitialAdTypeHeaderKey;
extern NSString * const kMPOrientationTypeHeaderKey;

extern NSString * const kMPAdTypeHtml;
extern NSString * const kMPAdTypeInterstitial;
extern NSString * const kMPAdTypeMraid;
extern NSString * const kMPAdTypeClear;
extern NSString * const kMPAdTypeNative;
extern NSString * const kMPAdTypeNativeVideo;

extern NSString * const kMPClickthroughExperimentBrowserAgent;

extern NSString * const kMPViewabilityDisableHeaderKey;

extern NSString * const kMPBannerImpressionVisableMsHeaderKey;
extern NSString * const kMPBannerImpressionMinPixelHeaderKey;

@interface MPAdConfiguration : NSObject

@property (nonatomic, assign) MPAdType adType;
@property (nonatomic, assign) BOOL adUnitWarmingUp;
@property (nonatomic, copy) NSString *networkType;
@property (nonatomic, assign) CGSize preferredSize;
@property (nonatomic, strong) NSURL *clickTrackingURL;
@property (nonatomic, strong) NSURL *impressionTrackingURL;
@property (nonatomic, strong) NSURL *failoverURL;
@property (nonatomic, strong) NSURL *interceptURLPrefix;
@property (nonatomic, assign) BOOL shouldInterceptLinks;
@property (nonatomic, assign) BOOL scrollable;
@property (nonatomic, assign) NSTimeInterval refreshInterval;
@property (nonatomic, assign) NSTimeInterval adTimeoutInterval;
@property (nonatomic, copy) NSData *adResponseData;
@property (nonatomic, strong) NSDictionary *nativeSDKParameters;
@property (nonatomic, copy) NSString *customSelectorName;
@property (nonatomic, assign) Class customEventClass;
@property (nonatomic, strong) NSDictionary *customEventClassData;
@property (nonatomic, assign) MPInterstitialOrientationType orientationType;
@property (nonatomic, copy) NSString *dspCreativeId;
@property (nonatomic, assign) BOOL precacheRequired;
@property (nonatomic, assign) BOOL isVastVideoPlayer;
@property (nonatomic, strong) NSDate *creationTimestamp;
@property (nonatomic, copy) NSString *creativeId;
@property (nonatomic, copy) NSString *headerAdType;
@property (nonatomic, assign) NSInteger nativeVideoPlayVisiblePercent;
@property (nonatomic, assign) NSInteger nativeVideoPauseVisiblePercent;
@property (nonatomic, assign) CGFloat nativeImpressionMinVisiblePixels;
@property (nonatomic, assign) NSInteger nativeImpressionMinVisiblePercent; // The pixels header takes priority over percentage, but percentage is left for backwards compatibility
@property (nonatomic, assign) NSTimeInterval nativeImpressionMinVisibleTimeInterval;
@property (nonatomic, assign) NSTimeInterval nativeVideoMaxBufferingTime;
@property (nonatomic) NSDictionary *nativeVideoTrackers;
@property (nonatomic, readonly) NSArray *availableRewards;
@property (nonatomic, strong) MPRewardedVideoReward *selectedReward;
@property (nonatomic, copy) NSString *rewardedVideoCompletionUrl;
@property (nonatomic, assign) NSTimeInterval rewardedPlayableDuration;
@property (nonatomic, assign) BOOL rewardedPlayableShouldRewardOnClick;


// viewable impression tracking experiment
@property (nonatomic) NSTimeInterval impressionMinVisibleTimeInSec;
@property (nonatomic) CGFloat impressionMinVisiblePixels;
@property (nonatomic) BOOL visibleImpressionTrackingEnabled;

- (id)initWithHeaders:(NSDictionary *)headers data:(NSData *)data;

- (BOOL)hasPreferredSize;
- (NSString *)adResponseHTMLString;
- (NSString *)clickDetectionURLPrefix;

@end
