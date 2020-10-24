import 'package:firebase_admob/firebase_admob.dart';

const String testDevice = 'ca-app-pub-2252311700273533~4947397745';

class Ads {
  static BannerAd _bannerAd;

  static void initialize() {
    FirebaseAdMob.instance.initialize(appId: FirebaseAdMob.testAppId);
  }

  static const MobileAdTargetingInfo targetingInfo = MobileAdTargetingInfo(
    testDevices: testDevice != null ? <String>[testDevice] : null,
    nonPersonalizedAds: true,
    keywords: ["Bedroom", "Football", "Clothing"]
  );

  static BannerAd _createBannerAd() {
    return BannerAd(
      adUnitId: 'ca-app-pub-2252311700273533/4755826050',
      size: AdSize.banner,
      targetingInfo: targetingInfo,
      listener: (MobileAdEvent event) {
        print("BannerAd event $event");
      },
    );
  }

  static void showBannerAd() {
    if (_bannerAd == null) _bannerAd = _createBannerAd();
    _bannerAd
      ..load()
      ..show(anchorOffset: 0.0, anchorType: AnchorType.bottom);
  }

  static void hideBannerAd() async {
    await _bannerAd.dispose();
    _bannerAd = null;
  }
}