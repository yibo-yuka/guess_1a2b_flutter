import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';

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
      home: const MenuPage(),
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
                  _menuButton(context, '挑戰 1A2B3C', '1A2B3C'), // 新模式
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
    String ruleText = "";
    if (mode == '16進位') {
      ruleText = "猜測 6 個不重複字元 (0-9, A-F)。\nA: 位置與數字皆對\nB: 數字對但位置錯";
    } else if (mode == '1A2B3C') {
      ruleText = "猜測 4 個數字 (最多含一組重複)。\nA: 位置與數字皆對\nB: 數字對但位置錯\nC: 猜測中完全不含於答案的數字個數 (Set 邏輯)\n\n※ 觀察 A+B+C 是否小於 4 來推斷重複！";
    } else {
      ruleText = "猜測 ${mode == '1A2B+' ? '5' : '4'} 個不重複數字。\nA: 位置與數字皆對\nB: 數字對但位置錯";
    }

    return Scaffold(
      body: Center(
        child: Container(
          width: 320,
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
              Text(ruleText, textAlign: TextAlign.center, style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 30),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo, foregroundColor: Colors.white),
                onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => GamePage(mode: mode))),
                child: const Text("Start"),
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
    _generateNewGame();
  }

  int get _codeLength => (widget.mode == '1A2B+' ? 5 : (widget.mode == '16進位' ? 6 : 4));

  void _generateNewGame() {
    List<String> pool = List.generate(10, (i) => i.toString());
    if (widget.mode == '16進位') pool.addAll(['A', 'B', 'C', 'D', 'E', 'F']);

    if (widget.mode == '1A2B3C') {
      bool shouldRepeat = Random().nextBool();
      pool.shuffle();
      List<String> selected;
      if (shouldRepeat) {
        selected = pool.sublist(0, _codeLength - 1); // 取前 n-1 數字
        selected.add(selected[Random().nextInt(selected.length)]); // 隨機重複一個
      } else {
        selected = pool.sublist(0, _codeLength);
      }
      selected.shuffle(); // 再次 shuffle
      _answer = selected.join();
    } else {
      pool.shuffle();
      _answer = pool.sublist(0, _codeLength).join();
    }
    _seconds = 0;
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) => setState(() => _seconds++));
  }

  void _checkGuess() {
    String guess = _controller.text;
    int a = 0, b = 0, c = 0;

    List<String> answerList = _answer.split('');
    List<String> guessList = guess.split('');
    List<bool> answerUsed = List.filled(_codeLength, false);
    List<bool> guessUsed = List.filled(_codeLength, false);

    // 第一遍：計算 A (消耗配對)
    for (int i = 0; i < _codeLength; i++) {
      if (guessList[i] == answerList[i]) {
        a++;
        answerUsed[i] = true;
        guessUsed[i] = true;
      }
    }

    // 第二遍：計算 B (消耗剩餘配對)
    for (int i = 0; i < _codeLength; i++) {
      if (!guessUsed[i]) {
        for (int j = 0; j < _codeLength; j++) {
          if (!answerUsed[j] && guessList[i] == answerList[j]) {
            b++;
            answerUsed[j] = true;
            break; 
          }
        }
      }
    }

    // 第三遍：計算 C (Set 邏輯)
    // 將答案與猜測都轉為集合，計算「不在答案集合中」的「猜測數字種類」
    Set<String> answerSet = _answer.split('').toSet();
    Set<String> guessSet = guess.split('').toSet();
    for (var char in guessSet) {
      if (!answerSet.contains(char)) {
        c++;
      }
    }

    setState(() {
      String result = widget.mode == '1A2B3C' ? "${a}A${b}B${c}C" : "${a}A${b}B";
      _history.insert(0, "$guess => $result (${_formatTime(_seconds)})");
      
      if (a == _codeLength) {
        _isGameOver = true;
        _timer?.cancel();
        _showWinBanner();
      }
      _controller.clear();
    });
  }

  void _showWinBanner() {
    ScaffoldMessenger.of(context).showMaterialBanner(
      MaterialBanner(
        content: Text("恭喜猜對！總耗時：${_formatTime(_seconds)}", style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.green[50],
        leading: const Icon(Icons.emoji_events, color: Colors.orange, size: 40),
        actions: [
          TextButton(onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentMaterialBanner();
            _generateNewGame();
            setState(() { _history.clear(); _isGameOver = false; _controller.clear(); });
          }, child: const Text("重新開始")),
          TextButton(
            onPressed: () {
              ScaffoldMessenger.of(context).clearMaterialBanners();
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            child: const Text("回主選單"),
          ),
        ],
      ),
    );
  }

  String _formatTime(int s) => '${(s ~/ 60).toString().padLeft(2, '0')}:${(s % 60).toString().padLeft(2, '0')}';

  @override
  void dispose() { _timer?.cancel(); _controller.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.mode),
        actions: [Center(child: Padding(padding: const EdgeInsets.only(right: 16), child: Text(_formatTime(_seconds))))],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              _controller.text.padRight(_codeLength, '_'),
              style: const TextStyle(fontSize: 40, letterSpacing: 8, fontWeight: FontWeight.bold, fontFamily: 'monospace'),
            ),
          ),
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
          _buildVisualKeyboard(),
        ],
      ),
    );
  }

  Widget _buildVisualKeyboard() {
    List<String> keys = ['1', '2', '3', '4', '5', '6', '7', '8', '9', '0'];
    if (widget.mode == '16進位') keys.addAll(['A', 'B', 'C', 'D', 'E', 'F']);

    // 檢查目前輸入框中是否有任何數字重複
    bool hasRepeat = false;
    Map<String, int> counts = {};
    for (var char in _controller.text.split('')) {
      counts[char] = (counts[char] ?? 0) + 1;
      if (counts[char]! > 1) hasRepeat = true;
    }

    return Container(
      color: Colors.grey[50],
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10, 10, 10, 15),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Wrap(
                spacing: 12, runSpacing: 12,
                alignment: WrapAlignment.center,
                children: keys.map((k) {
                  bool isDisabled = false;
                  int kCount = counts[k] ?? 0;

                  if (widget.mode == '1A2B3C') {
                    if (hasRepeat) {
                      // 1. 只要已經有重複數字了，所有填過的數字都不能再按
                      if (kCount >= 1) isDisabled = true;
                    } else {
                      // 2. 還沒重複時，填過的數字可以按第二次，但不能按第三次
                      if (kCount >= 2) isDisabled = true;
                    }
                  } else {
                    // 標準模式：填過就禁用
                    if (kCount >= 1) isDisabled = true;
                  }

                  return GestureDetector(
                    onTap: (isDisabled || _isGameOver || _controller.text.length >= _codeLength) 
                        ? null 
                        : () => setState(() => _controller.text += k),
                    child: Container(
                      width: 55, height: 55,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isDisabled ? Colors.grey[300] : Colors.white,
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
                      if (_controller.text.isNotEmpty) _controller.text = _controller.text.substring(0, _controller.text.length - 1);
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