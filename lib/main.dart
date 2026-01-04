import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:async'; // 1. 必須導入此庫

void main() => runApp(const GuessGameApp());

class GuessGameApp extends StatelessWidget {
  const GuessGameApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.indigo, useMaterial3: true),
      home: const GamePage(),
    );
  }
}

class GamePage extends StatefulWidget {
  const GamePage({super.key});

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  final TextEditingController _controller = TextEditingController();
  final List<String> _history = [];
  late String _answer;
  bool _isGameOver = false;

  // 2. 計時器相關變數
  Timer? _timer;
  int _seconds = 0;

  @override
  void initState() {
    super.initState();
    _generateNewGame();
  }

  // 啟動計時器
  void _startTimer() {
    _timer?.cancel(); // 確保不會有重複的計時器
    _seconds = 0;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _seconds++;
      });
    });
  }

  // 停止計時器
  void _stopTimer() {
    _timer?.cancel();
  }

  // 將秒數轉換為 mm:ss 格式
  String _formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  void _generateNewGame() {
    setState(() {
      var nums = List.generate(10, (i) => i.toString());
      nums.shuffle();
      _answer = nums.sublist(0, 4).join();
      _history.clear();
      _isGameOver = false;
      _controller.clear();
      _startTimer(); // 3. 重新開始時重置計時器
    });
  }

  void _checkGuess() {
    String guess = _controller.text;
    if (guess.length != 4 || int.tryParse(guess) == null) {
      _showError("請輸入 4 位數字");
      return;
    }

    int a = 0, b = 0;
    for (int i = 0; i < 4; i++) {
      if (guess[i] == _answer[i]) {
        a++;
      } else if (_answer.contains(guess[i])) {
        b++;
      }
    }

    setState(() {
      String result = "$guess => ${a}A${b}B (${_formatTime(_seconds)})";
      _history.insert(0, result);
      if (a == 4) {
        _isGameOver = true;
        _stopTimer(); // 4. 猜對後停止計時
      }
      _controller.clear();
    });
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  void dispose() {
    _timer?.cancel(); // 5. 頁面銷毀時釋放計時器資源，防止記憶體洩漏
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('1A2B 挑戰'),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 20.0),
              child: Text(
                "耗時: ${_formatTime(_seconds)}",
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (_isGameOver)
              Container(
                padding: const EdgeInsets.all(10),
                color: Colors.yellow[100],
                child: Text(
                  "破關成功！總耗時: ${_formatTime(_seconds)}",
                  style: const TextStyle(fontSize: 20, color: Colors.blueAccent, fontWeight: FontWeight.bold),
                ),
              ),
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                labelText: '輸入 4 個不重複數字',
                hintText: '例如: 1234',
                counterText: "", // 隱藏右下角字數統計
              ),
              keyboardType: TextInputType.number,
              maxLength: 4,
              enabled: !_isGameOver,
              onSubmitted: (_) => _checkGuess(),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: _isGameOver ? null : _checkGuess,
                  icon: const Icon(Icons.send),
                  label: const Text("送出"),
                ),
                OutlinedButton.icon(
                  onPressed: _generateNewGame,
                  icon: const Icon(Icons.refresh),
                  label: const Text("重新開始"),
                ),
              ],
            ),
            const Divider(height: 40),
            const Text("猜測紀錄 (時間)", style: TextStyle(fontWeight: FontWeight.bold)),
            Expanded(
              child: ListView.builder(
                itemCount: _history.length,
                itemBuilder: (context, index) => Card(
                  child: ListTile(
                    leading: CircleAvatar(child: Text("${_history.length - index}")),
                    title: Text(_history[index], style: const TextStyle(fontSize: 18)),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}