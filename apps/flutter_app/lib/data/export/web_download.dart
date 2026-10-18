// Native builds never download through a browser.
void downloadInBrowser(String name, String content) =>
    throw UnsupportedError('browser download');
