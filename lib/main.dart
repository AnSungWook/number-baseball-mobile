import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:webview_flutter/webview_flutter.dart';

const String _defaultUrl = String.fromEnvironment(
  'WEB_APP_URL',
  defaultValue: 'https://nagarago.com',
);

void main() {
  runApp(const MiniGameHubApp());
}

class GameDefinition {
  const GameDefinition({
    required this.title,
    required this.description,
    required this.icon,
    required this.builder,
  });

  final String title;
  final String description;
  final IconData icon;
  final WidgetBuilder builder;
}

class MiniGameHubApp extends StatelessWidget {
  const MiniGameHubApp({super.key});

  static final List<GameDefinition> _games = [
    GameDefinition(
      title: '숫자 야구',
      description: '네 자리 숫자를 추리하는 클래식 게임',
      icon: Icons.casino,
      builder: (_) => const WebViewShell(
        title: '숫자 야구',
        initialUrl: _defaultUrl,
      ),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.fromSeed(seedColor: Colors.indigo);
    final baseTheme = ThemeData(
      colorScheme: colorScheme,
      useMaterial3: true,
    );
    final textTheme = GoogleFonts.juaTextTheme(baseTheme.textTheme);
    return MaterialApp(
      title: '미니게임 모음',
      theme: baseTheme.copyWith(
        textTheme: textTheme,
        appBarTheme: baseTheme.appBarTheme.copyWith(
          centerTitle: true,
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          titleTextStyle: GoogleFonts.jua(
            textStyle: textTheme.titleLarge?.copyWith(
              color: colorScheme.onPrimary,
            ),
            fontSize: 22,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      home: HomeScreen(games: _games),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.games});

  final List<GameDefinition> games;

  void _openGame(BuildContext context, GameDefinition game) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: game.builder),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('오늘은 어떤 게임?'),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: games.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final game = games[index];
          return _GameCard(
            icon: game.icon,
            title: game.title,
            description: game.description,
            onTap: () => _openGame(context, game),
          );
        },
      ),
    );
  }
}

class _GameCard extends StatelessWidget {
  const _GameCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String description;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Ink(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: theme.colorScheme.primaryContainer.withAlpha(235),
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: theme.colorScheme.primary.withAlpha(36),
              ),
              child: Icon(icon, size: 30, color: theme.colorScheme.primary),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    description,
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right),
          ],
        ),
      ),
    );
  }
}

class WebViewShell extends StatefulWidget {
  const WebViewShell({
    super.key,
    required this.title,
    required this.initialUrl,
  });

  final String title;
  final String initialUrl;

  @override
  State<WebViewShell> createState() => _WebViewShellState();
}

class _WebViewShellState extends State<WebViewShell> {
  late final WebViewController _controller;
  bool _isLoading = true;
  bool _hasError = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) => setState(() {
            _isLoading = true;
            _hasError = false;
            _errorMessage = null;
          }),
          onPageFinished: (_) => setState(() => _isLoading = false),
          onWebResourceError: (error) {
            setState(() {
              _hasError = true;
              _isLoading = false;
              _errorMessage = error.description;
            });
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.initialUrl));
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) {
          return;
        }
        final navigator = Navigator.of(context);
        if (await _controller.canGoBack()) {
          await _controller.goBack();
        } else if (mounted && navigator.canPop()) {
          navigator.pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
          actions: [
            IconButton(
              tooltip: '새로고침',
              onPressed: () {
                setState(() {
                  _isLoading = true;
                  _hasError = false;
                  _errorMessage = null;
                });
                _controller.reload();
              },
              icon: const Icon(Icons.refresh),
            ),
          ],
        ),
        body: Stack(
          children: [
            if (!_hasError)
              WebViewWidget(controller: _controller)
            else
              _ErrorView(
                message: _errorMessage ?? '페이지를 불러오지 못했습니다.',
                onRetry: () {
                  setState(() {
                    _isLoading = true;
                    _hasError = false;
                    _errorMessage = null;
                  });
                  _controller.loadRequest(Uri.parse(widget.initialUrl));
                },
              ),
            if (_isLoading)
              const ColoredBox(
                color: Color(0x11000000),
                child: Center(child: CircularProgressIndicator()),
              ),
          ],
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off, size: 64),
            const SizedBox(height: 12),
            Text(
              '연결 오류',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('다시 시도'),
            ),
          ],
        ),
      ),
    );
  }
}
