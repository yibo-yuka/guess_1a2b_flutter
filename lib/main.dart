import 'package:flutter/material.dart';
import 'dart:async'; // 這裡應該是為了同時維持計時器功能跟頁面狀態更新功能

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

  // 這是為了要在輸入答案後讓鼠標自動回到輸入框(聚焦)
  final FocusNode _focusNode = FocusNode();
  late String _answer;
  bool _isGameOver = false;
  Timer? _timer;
  int _seconds = 0;
  
  // 新增模式追蹤，預設為 '1A2B'，主要由側邊欄DRAWER控制
  String _currentMode = '1A2B';
  // 切換模式的函式
  void _selectMode(String mode) { // 這裡應該會透過側邊欄觸發
    setState(() {
      _currentMode = mode;
      _generateNewGame(); // 切換模式時自動重置遊戲
    });
    Navigator.pop(context); // 核心：選完後自動關閉側邊欄
  }
  
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

  int get _codeLength {
    switch (_currentMode) {
      case '1A2B+': return 5;
      case '16進位': return 6;
      default: return 4;
    }
  }
  void _generateNewGame() {
    setState(() {
      // 建立候選池：如果是 16 進位模式，加入 A-F
      List<String> pool = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
      if (_currentMode == '16進位') {
        pool.addAll(['A', 'B', 'C', 'D', 'E', 'F']);
      }
      pool.shuffle();
      _answer = pool.sublist(0, _codeLength).join();
      _seconds = 0;
      _history.clear();
      _isGameOver = false;
      _controller.clear();
      _startTimer(); // 重新開始時重置計時器
    });
  }

  void _checkGuess() {
    String guess = _controller.text;
    int requiredLength = _codeLength;
    if (guess.length != requiredLength) {
      _showError("請輸入 $requiredLength 位數字");
      return;
    }
    // 檢查是否有重複數字
    // .split('') 將字串轉為字元清單，.toSet() 會自動過濾掉重複項
    if (guess.split('').toSet().length != guess.length) {
      _showError("數字不能重複，請重新輸入");
      _controller.clear(); // 清空讓玩家重打
      _focusNode.requestFocus();
      return;
    }
    int a = 0;
    int b = 0;
    int c = 0;
    for (int i = 0; i < guess.length; i++) {
      if (guess[i] == _answer[i]) {
        a++;
      } else if (_answer.contains(guess[i])) {
        b++;
      }
    }
    // 計算 C (猜測的數字中，不在答案裡的個數)
    // 邏輯：總長度 - (A + B)
    c = guess.length - (a + b);
    setState(() {
      String resultText;
      switch (_currentMode) {
        case '1A2B':
          resultText = "$guess => ${a}A${b}B ";
          break;
        case '1A2B+':
          resultText = "$guess => ${a}A${b}B${c}C ";
          break;
        case '1A2B3C':
          resultText = "$guess => ${a}A${b}B${c}C ";
          break;
        case '16進位':
          resultText = "$guess => ${a}A${b}B ";
          break;
        default:
          resultText = "$guess => ${a}A${b}B";
      }
      // String result = "$guess => ${a}A${b}B (${_formatTime(_seconds)})";
      _history.insert(0, "$resultText(${_formatTime(_seconds)})");
      if (a == requiredLength) {
        _isGameOver = true;
        _stopTimer(); // 猜對後停止計時
      }
      _controller.clear();
      // 在送出並清空輸入框後，重新請求將鼠標聚焦到輸入框
      _focusNode.requestFocus();
    });
  }

  // 數字按鈕的處理函式
  void _onNumberPress(String char) {
    if (_isGameOver) return;
    if (_controller.text.length < _codeLength) {
      setState(() {
        _controller.text += char;
      });
    }
  }
  // 刪除按鈕的處理函式
  void _onDelete() {
    if (_controller.text.isNotEmpty) {
      setState(() {
        _controller.text = _controller.text.substring(0, _controller.text.length - 1);
      });
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  void dispose() {
    _timer?.cancel(); // 頁面銷毀時釋放計時器資源，防止記憶體洩漏
    _focusNode.dispose(); // 記得要釋放 FocusNode 資源
    super.dispose();
  }

  Widget _buildKeyboard() {
    // 定義所有可能的字元
    List<String> keys = ['1', '2', '3', '4', '5', '6', '7', '8', '9', '0'];
    if (_currentMode == '16進位') {
      keys.addAll(['A', 'B', 'C', 'D', 'E', 'F']);
    }

    return Container(
      color: Colors.grey[200],
      child: SafeArea(
        top: false,
        child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
        child: Column(
          mainAxisSize: MainAxisSize.min, // 讓 Column 只佔用必要的高度
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: keys.map((key) {
                bool isUsed = _controller.text.contains(key);
                return SizedBox(
                  width: 50,
                  height: 45,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isUsed ? Colors.grey : Colors.white,
                      padding: EdgeInsets.zero,
                    ),
                    onPressed: isUsed ? null : () => _onNumberPress(key),
                    child: Text(key),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(icon: const Icon(Icons.backspace), onPressed: _onDelete),
                ElevatedButton(
                  onPressed: _controller.text.length == _codeLength ? _checkGuess : null,
                  child: const Text("確認送出"),
                ),
              ],
            ),
          ],
        ),
      ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('$_currentMode 挑戰'),
        actions: [
          Padding(
            padding: const EdgeInsets.all(16), 
            child: Center(child: Text(_formatTime(_seconds)))
          )
        ],
      ),
      // 實作側邊欄
      drawer: Drawer(
        child: ListView(
          children: [
            const DrawerHeader(decoration: BoxDecoration(color: Colors.indigo), child: Text('遊戲模式', style: TextStyle(color: Colors.white, fontSize: 24))),
            ListTile(title: const Text('標準 1A2B'), onTap: () => _selectMode('1A2B')),
            ListTile(title: const Text('1A2B+ (5碼)'), onTap: () => _selectMode('1A2B+')),
            ListTile(title: const Text('1A2B3C'), onTap: () => _selectMode('1A2B3C')),
            ListTile(title: const Text('16 進位'), onTap: () => _selectMode('16進位')),
          ],
        ),
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 30),
            decoration: BoxDecoration(
              // color: Colors.indigo.withOpacity(0.1),
              border: Border(bottom: BorderSide(color: Colors.indigo.withOpacity(0.2))),
            ),
            child: Center(
              child: Text(
                _controller.text.padRight(_codeLength, '_'),
                style: const TextStyle(
                  fontSize: 42, 
                  letterSpacing: 12, 
                  fontWeight: FontWeight.bold,
                  color: Colors.indigo,
                  fontFamily: 'monospace', // 使用等寬字體讓底線對齊
                ),
              ),
            ),
          ),
          
          Expanded(
            child: _history.isEmpty 
                ? const Center(child: Text("開始挑戰吧！", style: TextStyle(color: Colors.grey)))
                : ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: _history.length,
                    itemBuilder: (context, index) => Card(
                      elevation: 2,
                      child: ListTile(
                        leading: CircleAvatar(child: Text("${_history.length - index}")),
                        title: Text(_history[index], style: const TextStyle(fontSize: 18)),
                      ),
                    ),
                  ),
          ),
          _buildKeyboard(),
        ],
      ),
    );
  }
}