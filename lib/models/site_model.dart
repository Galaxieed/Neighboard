class SiteModel {
  late String siteId;
  late String siteName;
  late String siteLocation;
  late String siteHeader;
  late String siteSubheader;
  late String siteAbout;
  late int siteThemeColor;
  late String siteLogo;
  late String siteHomepageImage;
  late String siteAboutImage;

  SiteModel({
    required this.siteId,
    required this.siteName,
    required this.siteLocation,
    required this.siteHeader,
    required this.siteSubheader,
    required this.siteAbout,
    required this.siteThemeColor,
    required this.siteLogo,
    required this.siteHomepageImage,
    required this.siteAboutImage,
  });

  SiteModel.fromJson(Map<String, dynamic> json) {
    siteId = json['site_id'];
    siteName = json['site_name'];
    siteLocation = json['site_location'];
    siteHeader = json['site_header'];
    siteSubheader = json['site_subheader'];
    siteAbout = json['site_about'];
    siteThemeColor = json['site_theme_color'];
    siteLogo = json['site_logo'];
    siteHomepageImage = json['site_homepage_image'];
    siteAboutImage = json['site_about_image'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['site_id'] = siteId;
    data['site_name'] = siteName;
    data['site_location'] = siteLocation;
    data['site_header'] = siteHeader;
    data['site_subheader'] = siteSubheader;
    data['site_about'] = siteAbout;
    data['site_theme_color'] = siteThemeColor;
    data['site_logo'] = siteLogo;
    data['site_homepage_image'] = siteHomepageImage;
    data['site_about_image'] = siteAboutImage;
    return data;
  }
}
