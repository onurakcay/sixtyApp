import 'package:firebase_admob/firebase_admob.dart';

class admob {
  static final String appIdCanli = "ca-app-pub-4769186279890110~2843928256";
  static final String appIdTest = FirebaseAdMob.testAppId;
  static final String mychatsAdCanli = "ca-app-pub-4769186279890110/6747019404";

  static admobInitialize() {
    FirebaseAdMob.instance.initialize(appId: appIdTest);
  }

  static final MobileAdTargetingInfo targetingInfo = MobileAdTargetingInfo(
    keywords: <String>[
      'chatting',
      'friendships',
      'friends',
      'chat',
      'chat app'
    ],
    contentUrl: 'http://ofis91.com/',

    childDirected: false, // or MobileAdGender.female, MobileAdGender.unknown
    testDevices: <String>[], // Android emulators are considered test devices
  );
  static BannerAd buildBannerAd() {
    return BannerAd(
      adUnitId: BannerAd.testAdUnitId,
      size: AdSize.smartBanner,
      targetingInfo: targetingInfo,
      listener: (MobileAdEvent event) {
        if (event == MobileAdEvent.loaded) {
          print("banner yüklendi");
        }
      },
    );
  }

  static InterstitialAd buildInterstitialAd() {
    return InterstitialAd(
      // Replace the testAdUnitId with an ad unit id from the AdMob dash.
      // https://developers.google.com/admob/android/test-ads
      // https://developers.google.com/admob/ios/test-ads
      adUnitId: InterstitialAd.testAdUnitId,
      targetingInfo: targetingInfo,
      listener: (MobileAdEvent event) {
        print("InterstitialAd event is $event");
      },
    );
  }
}
