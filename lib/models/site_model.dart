class SiteModel {
  late String siteId;
  late String siteSubdName;
  late String siteLocation;
  late String siteHeader;
  late String siteSubheader;
  late String siteAbout;
  late String siteOfficeAddress;
  late List<String> siteContactNo;
  late List<String> siteStreets;
  late int siteThemeColor;
  late String siteLogo;
  late String siteLogoDark;
  late String siteHomepageImage;
  late String siteAboutImage;

  SiteModel({
    required this.siteId,
    required this.siteSubdName,
    required this.siteLocation,
    required this.siteHeader,
    required this.siteSubheader,
    required this.siteAbout,
    required this.siteOfficeAddress,
    required this.siteContactNo,
    required this.siteStreets,
    required this.siteThemeColor,
    required this.siteLogo,
    required this.siteLogoDark,
    required this.siteHomepageImage,
    required this.siteAboutImage,
  });

  SiteModel.fromJson(Map<String, dynamic> json) {
    siteId = json['site_id'];
    siteSubdName = json['site_subd_name'];
    siteLocation = json['site_location'];
    siteHeader = json['site_header'];
    siteSubheader = json['site_subheader'];
    siteAbout = json['site_about'];
    siteOfficeAddress = json['site_office_address'];
    siteContactNo = json['site_contact_no'].cast<String>();
    siteStreets = json['site_streets'].cast<String>();
    siteThemeColor = json['site_theme_color'];
    siteLogo = json['site_logo'];
    siteLogoDark = json['site_logo_dark'];
    siteHomepageImage = json['site_homepage_image'];
    siteAboutImage = json['site_about_image'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['site_id'] = siteId;
    data['site_subd_name'] = siteSubdName;
    data['site_location'] = siteLocation;
    data['site_header'] = siteHeader;
    data['site_subheader'] = siteSubheader;
    data['site_about'] = siteAbout;
    data['site_office_address'] = siteOfficeAddress;
    data['site_contact_no'] = siteContactNo;
    data['site_streets'] = siteStreets;
    data['site_theme_color'] = siteThemeColor;
    data['site_logo'] = siteLogo;
    data['site_logo_dark'] = siteLogoDark;
    data['site_homepage_image'] = siteHomepageImage;
    data['site_about_image'] = siteAboutImage;
    return data;
  }
}
