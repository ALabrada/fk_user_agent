/// Web fallback for the desktop user agent generator.
///
/// `FkUserAgent.init` is not called on the web, so this implementation only
/// needs to compile and return a sensible value if it ever is.
Map<String, dynamic> generateProperties() {
  return <String, dynamic>{
    'systemName': 'Web',
    'systemVersion': '',
    'userAgent': 'Mozilla/5.0',
    'webViewUserAgent': 'Mozilla/5.0',
    'packageUserAgent': 'Mozilla/5.0',
    'applicationName': '',
    'applicationVersion': '',
    'applicationBuildNumber': 0,
    'architecture': '',
  };
}