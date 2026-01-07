import 'package:flutter/material.dart';
import 'dart:async';

void main() => runApp(const GuessGameApp());

class GuessGameApp extends StatelessWidget {
  const GuessGameApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
      ),
      home: const MenuPage(), // 對應圖 1：開始畫面
    );
  }
}

// --- 畫面一：開始畫面 (Menu) ---
class MenuPage extends StatelessWidget {
  const MenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("1A2B", style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.indigo)),
            const SizedBox(height: 40),
            Container(
              width: 250,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.indigo, width: 2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  const Text("Menu", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  const Divider(),
                  _menuButton(context, '標準 1A2B', '1A2B'),
                  _menuButton(context, '1A2B+ (5碼)', '1A2B+'),
                  _menuButton(context, '16進位模式', '16進位'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _menuButton(BuildContext context, String label, String mode) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => RulePage(mode: mode))),
          child: Text(label),
        ),
      ),
    );
  }
}

// --- 畫面二：遊戲說明 (Rule Page) ---
class RulePage extends StatelessWidget {
  final String mode;
  const RulePage({super.key, required this.mode});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          width: 300,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("rule", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
              const SizedBox(height: 15),
              Text(
                mode == '16進位' 
                    ? "猜測 6 個不重複字元 (0-9, A-F)。\nA: 位置與數字皆對\nB: 數字對但位置錯"
                    : "猜測 ${mode == '1A2B+' ? '5' : '4'} 個不重複數字。\nA: 位置與數字皆對\nB: 數字對但位置錯",
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo, foregroundColor: Colors.white),
                onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => GamePage(mode: mode))),
                child: const Text("Start"), // 對應圖 2 的 Start 按鈕
              )
            ],
          ),
        ),
      ),
    );
  }
}

// --- 畫面三：遊戲開始 (Game Play) ---
class GamePage extends StatefulWidget {
  final String mode;
  const GamePage({super.key, required this.mode});

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  final List<String> _history = [];
  final TextEditingController _controller = TextEditingController();
  late String _answer;
  bool _isGameOver = false;
  Timer? _timer;
  int _seconds = 0;

  @override
  void initState() {
    super.initState();
    _generateNewGame(); // 初始化遊戲與計時器
  }

  int get _codeLength => widget.mode == '1A2B+' ? 5 : (widget.mode == '16進位' ? 6 : 4);

  void _generateNewGame() {
    List<String> pool = List.generate(10, (i) => i.toString());
    if (widget.mode == '16進位') pool.addAll(['A', 'B', 'C', 'D', 'E', 'F']);
    pool.shuffle();
    _answer = pool.sublist(0, _codeLength).join();
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) => setState(() => _seconds++));
  }
  
  void _resetGame() {
    setState(() {
      _history.clear();
      _controller.clear();
      _isGameOver = false;
      _generateNewGame(); // 這會重置答案與計時器
    });
    // 確保隱藏橫幅
    ScaffoldMessenger.of(context).hideCurrentMaterialBanner();
  }

  void _checkGuess() {
    String guess = _controller.text;
    int a = 0, b = 0;
    for (int i = 0; i < guess.length; i++) {
      if (guess[i] == _answer[i]) a++;
      else if (_answer.contains(guess[i])) b++;
    }

    setState(() {
      _history.insert(0, "$guess => ${a}A${b}B (${_formatTime(_seconds)})");
      if (a == _codeLength) {
        _isGameOver = true;
        _timer?.cancel();
        // 顯示猜對橫幅 (SnackBar)
        ScaffoldMessenger.of(context).showMaterialBanner(
          MaterialBanner(
            content: Text("恭喜猜對！總耗時：${_formatTime(_seconds)}",
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            backgroundColor: Colors.green[50],
            leading: const Icon(Icons.emoji_events, color: Colors.orange, size: 40),
            actions: [
              TextButton(
                onPressed: _resetGame, // 重新開始
                child: const Text("重新開始", style: TextStyle(color: Colors.green)),
              ),
              TextButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).hideCurrentMaterialBanner();
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                child: const Text("回主選單"),
              ),
            ],
          ),
        );
      }
      _controller.clear();
    });
  }

  String _formatTime(int s) => '${(s ~/ 60).toString().padLeft(2, '0')}:${(s % 60).toString().padLeft(2, '0')}';

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    // 當頁面關閉時，確保橫幅跟著消失
    // 使用指令：ScaffoldMessenger.of(context).removeCurrentMaterialBanner();
    // 或者 hideCurrentMaterialBanner()
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ScaffoldMessenger.of(context).clearMaterialBanners();
      }
    });
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.mode),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // 離開前先清空橫幅，避免帶回首頁
            ScaffoldMessenger.of(context).clearMaterialBanners();
            Navigator.of(context).popUntil((route) => route.isFirst);
          },
        ),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16), 
              child: Text(_formatTime(_seconds))
            )
          )
        ],
      ),
      body: Column(
        children: [
          // 頂部輸入框 (對應圖 3 的 0000)
          Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              _controller.text.padRight(_codeLength, '_'),
              style: const TextStyle(fontSize: 40, letterSpacing: 8, fontWeight: FontWeight.bold, fontFamily: 'monospace'),
            ),
          ),
          // 中間紀錄區
          Expanded(
            child: ListView.separated(
              itemCount: _history.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, i) => ListTile(
                leading: Text("#${_history.length - i}"),
                title: Text(_history[i], style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
              ),
            ),
          ),
          // 底部鍵盤 (對應圖 3 的數字圓圈)
          _buildVisualKeyboard(),
        ],
      ),
    );
  }

  Widget _buildVisualKeyboard() {
  List<String> keys = ['1', '2', '3', '4', '5', '6', '7', '8', '9', '0'];
  if (widget.mode == '16進位') keys.addAll(['A', 'B', 'C', 'D', 'E', 'F']);

  return Container(
    // 這裡可以維持底色，讓底色填滿到螢幕最邊緣
    color: Colors.grey[50], 
    child: SafeArea(
      top: false, // 頂部不需要避讓，因為它在螢幕中間
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 10, 10, 15), // 增加底部內邊距
        child: Column(
          mainAxisSize: MainAxisSize.min, // 確保只佔用必要高度
          children: [
            Wrap(
              spacing: 12, runSpacing: 12,
              alignment: WrapAlignment.center,
              children: keys.map((k) {
                bool isUsed = _controller.text.contains(k);
                return GestureDetector(
                  onTap: (isUsed || _isGameOver || _controller.text.length >= _codeLength) 
                      ? null 
                      : () => setState(() => _controller.text += k),
                  child: Container(
                    width: 55, height: 55,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isUsed ? Colors.grey[300] : Colors.white,
                      border: Border.all(color: Colors.indigo, width: 1.5),
                    ),
                    child: Center(child: Text(k, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  onPressed: () => setState(() {
                    if (_controller.text.isNotEmpty) {
                      _controller.text = _controller.text.substring(0, _controller.text.length - 1);
                    }
                  }), 
                  icon: const Icon(Icons.backspace_outlined, size: 30)
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15)),
                  onPressed: (_controller.text.length == _codeLength && !_isGameOver) ? _checkGuess : null,
                  child: const Text("Send", style: TextStyle(fontSize: 18)),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}
}