import 'package:web/web.dart' as web;

/// The app's base URL (`<base href>`), whatever route is showing.
Uri pageBase() => Uri.parse(web.document.baseURI);

/// Loads the page again, picking up a newly deployed version.
void reloadPage() => web.window.location.reload();
