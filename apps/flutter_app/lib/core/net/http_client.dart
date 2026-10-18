import 'package:http/http.dart' as http;

import 'http_client_native.dart'
    if (dart.library.js_interop) 'http_client_web.dart'
    as impl;

/// An HTTP client that streams response bodies on every platform. On the
/// web the default client buffers whole responses, which would turn the
/// AI's streamed reply into one late block; fetch streams it.
http.Client newHttpClient() => impl.newHttpClient();
