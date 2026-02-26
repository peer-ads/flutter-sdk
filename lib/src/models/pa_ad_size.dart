class PAAdSize {
  final int width;
  final int height;

  const PAAdSize._(this.width, this.height);

  static const PAAdSize banner = PAAdSize._(320, 50);
  static const PAAdSize largeBanner = PAAdSize._(320, 100);
  static const PAAdSize mediumRectangle = PAAdSize._(300, 250);
  static const PAAdSize fullBanner = PAAdSize._(468, 60);
  static const PAAdSize leaderboard = PAAdSize._(728, 90);
}
