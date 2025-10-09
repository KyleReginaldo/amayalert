import 'package:amayalert/core/widgets/text/custom_text.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:webview_flutter/webview_flutter.dart';

@RoutePage()
class WebViewScreen extends StatefulWidget {
  final String url;
  final String? title;

  const WebViewScreen({super.key, required this.url, this.title});

  @override
  State<WebViewScreen> createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;
  String? _pageTitle;
  String? _currentUrl;
  double _loadingProgress = 0.0;
  bool _hasError = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeWebView();
  }

  void _initializeWebView() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            setState(() {
              _loadingProgress = progress / 100.0;
            });
          },
          onPageStarted: (String url) {
            setState(() {
              _isLoading = true;
              _hasError = false;
              _currentUrl = url;
            });
          },
          onPageFinished: (String url) {
            setState(() {
              _isLoading = false;
              _currentUrl = url;
            });
            _getPageTitle();
          },
          onWebResourceError: (WebResourceError error) {
            setState(() {
              _isLoading = false;
              _hasError = true;
              _errorMessage = error.description;
            });
          },
          onNavigationRequest: (NavigationRequest request) {
            // Allow all navigation requests
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  Future<void> _getPageTitle() async {
    try {
      final title = await _controller.getTitle();
      if (mounted && title != null) {
        setState(() {
          _pageTitle = title;
        });
      }
    } catch (e) {
      debugPrint('Error getting page title: $e');
    }
  }

  void _reload() {
    setState(() {
      _isLoading = true;
      _hasError = false;
      _errorMessage = null;
    });
    _controller.reload();
  }

  void _goBack() async {
    if (await _controller.canGoBack()) {
      await _controller.goBack();
    }
  }

  void _goForward() async {
    if (await _controller.canGoForward()) {
      await _controller.goForward();
    }
  }

  void _shareUrl() {
    if (_currentUrl != null) {
      Clipboard.setData(ClipboardData(text: _currentUrl!));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const CustomText(
            text: 'URL copied to clipboard',
            color: Colors.white,
          ),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: CustomText(
          text: widget.title ?? _pageTitle ?? 'Web View',
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.white,
          maxLines: 1,
        ),
        backgroundColor: Colors.blue,
        elevation: 0,
        surfaceTintColor: Colors.white,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            onPressed: _reload,
            icon: const Icon(LucideIcons.refreshCw, size: 20),
            tooltip: 'Reload',
          ),
          IconButton(
            onPressed: _shareUrl,
            icon: const Icon(LucideIcons.share, size: 20),
            tooltip: 'Share URL',
          ),
        ],
      ),
      body: Column(
        children: [
          // Loading Progress Bar
          if (_isLoading)
            LinearProgressIndicator(
              value: _loadingProgress,
              backgroundColor: Colors.grey.shade200,
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
            ),

          // Navigation Controls
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                bottom: BorderSide(color: Colors.grey.shade200, width: 1),
              ),
            ),
            child: Row(
              children: [
                // Back Button
                FutureBuilder<bool>(
                  future: _controller.canGoBack(),
                  builder: (context, snapshot) {
                    return IconButton(
                      onPressed: snapshot.data == true ? _goBack : null,
                      icon: Icon(
                        LucideIcons.chevronLeft,
                        color: snapshot.data == true
                            ? Colors.blue
                            : Colors.grey.shade400,
                      ),
                      tooltip: 'Back',
                    );
                  },
                ),

                // Forward Button
                FutureBuilder<bool>(
                  future: _controller.canGoForward(),
                  builder: (context, snapshot) {
                    return IconButton(
                      onPressed: snapshot.data == true ? _goForward : null,
                      icon: Icon(
                        LucideIcons.chevronRight,
                        color: snapshot.data == true
                            ? Colors.blue
                            : Colors.grey.shade400,
                      ),
                      tooltip: 'Forward',
                    );
                  },
                ),

                const SizedBox(width: 16),

                // URL Display
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          LucideIcons.globe,
                          size: 16,
                          color: Colors.grey.shade600,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: CustomText(
                            text: _currentUrl ?? widget.url,
                            fontSize: 12,
                            color: Colors.grey.shade700,
                            maxLines: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // WebView Content
          Expanded(
            child: _hasError
                ? _buildErrorView()
                : WebViewWidget(controller: _controller),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(LucideIcons.wifiOff, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 24),
            const CustomText(
              text: 'Failed to Load Page',
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
            const SizedBox(height: 8),
            CustomText(
              text: _errorMessage ?? 'Unable to load the requested page.',
              fontSize: 14,
              color: Colors.grey.shade600,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _reload,
              icon: const Icon(LucideIcons.refreshCw, size: 18),
              label: const CustomText(
                text: 'Try Again',
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
