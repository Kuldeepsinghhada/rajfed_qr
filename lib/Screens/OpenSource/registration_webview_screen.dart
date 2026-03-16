import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class RegistrationWebViewScreen extends StatefulWidget {
  static const routeName = '/registration-webview';
  const RegistrationWebViewScreen({Key? key}) : super(key: key);

  @override
  State<RegistrationWebViewScreen> createState() =>
      _RegistrationWebViewScreenState();
}

class _RegistrationWebViewScreenState extends State<RegistrationWebViewScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;
  final String initialUrl =
      'https://rajfed.rajasthan.gov.in/rajfed/RegistrationHome.aspx';

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (url) {
            if (mounted) setState(() => _isLoading = false);
          },
          onPageStarted: (url) {
            if (mounted) setState(() => _isLoading = true);
          },
          onWebResourceError: (err) {
            // ignore for now; could show a snackbar
          },
        ),
      )
      ..loadRequest(Uri.parse(initialUrl));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registration')),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            const LinearProgressIndicator(
              minHeight: 3,
            ),
        ],
      ),
    );
  }
}
