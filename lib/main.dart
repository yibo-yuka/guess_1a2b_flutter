import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
// import 'dart:math';

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
      home: const LoginPage(),
    );
  }
}
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _nameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  
  void _enterGame() {
    if (_formKey.currentState!.validate()) {
      // 導向主選單，並攜帶玩家輸入的名稱
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => MenuPage(username: _nameController.text.trim()),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.indigo.shade50, Colors.white],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(30),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.account_circle, size: 100, color: Colors.indigo),
                  const SizedBox(height: 20),
                  const Text(
                    "登錄臨時身分",
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.indigo),
                  ),
                  const SizedBox(height: 10),
                  const Text("名稱將用於排行榜結算", style: TextStyle(color: Colors.grey)),
                  const SizedBox(height: 40),
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: "請輸入玩家名稱",
                      prefixIcon: const Icon(Icons.person),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) return "名稱不能為空";
                      if (value.length > 15) return "名稱太長了 (限15字)";
                      return null;
                    },
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.indigo,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        elevation: 5,
                      ),
                      onPressed: _enterGame,
                      child: const Text("開始挑戰", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }
}

// --- 畫面一：開始畫面 (Menu) ---
class MenuPage extends StatelessWidget {
  final String username; // 新增這行
  const MenuPage({super.key, required this.username}); // 修改這行

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 使用平滑的背景色調
      backgroundColor: Colors.indigo.shade50,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 歡迎區塊
              const Icon(Icons.videogame_asset, size: 80, color: Colors.indigo),
              const SizedBox(height: 10),
              Text("你好, $username!", style: const TextStyle(fontSize: 20, color: Colors.indigo)),
              const Text("1A2B", style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.indigo)),
              const SizedBox(height: 40),
              Container(
                width: 300,
                padding: const EdgeInsets.all(25),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const Text("Menu", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    const Divider(),
                    const SizedBox(height: 10),
                    // 遊戲模式按鈕
                    _menuButton(context, '標準 1A2B', '1A2B', Icons.looks_4),
                    _menuButton(context, '1A2B+ (5碼)', '1A2B+', Icons.looks_5),
                    _menuButton(context, '16進位模式', '16進位', Icons.looks_6),
                  
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      child: Divider(),
                    ),
                    // 排行榜按鈕 (使用不同的顏色區分)
                    _menuButton(context, '全球排行榜', 'LEADERBOARD', Icons.emoji_events, isSpecial: true),
                    
                    // 登出/切換帳號
                    TextButton.icon(
                      onPressed: () => Navigator.pushReplacement(
                        context, 
                        MaterialPageRoute(builder: (context) => const LoginPage())
                      ),
                      icon: const Icon(Icons.logout, size: 18),
                      label: const Text("切換臨時身分"),
                      style: TextButton.styleFrom(foregroundColor: Colors.grey),
                    )
                  ],
                ),
              ),
            ],
          ),
        )
        
      ),
    );
  }

  Widget _menuButton(BuildContext context, String label, String mode, IconData icon, {bool isSpecial = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton.icon(
          icon: Icon(icon, size: 20),
          label: Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          style: ElevatedButton.styleFrom(
            backgroundColor: isSpecial ? Colors.orange.shade700 : Colors.indigo,
            foregroundColor: Colors.white,
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onPressed: () {
            if (mode == 'LEADERBOARD') {
              // 導向排行榜頁面
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const LeaderboardPage()),
              );
            } else {
              // 導向遊戲規則頁面，並攜帶 username 與 mode
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => RulePage(mode: mode, username: username),
                ),
              );
            }
          },
        ),
      ),
    );
  }
}

// --- 畫面二：遊戲說明 (Rule Page) ---
class RulePage extends StatelessWidget {
  final String mode;
  final String username; // 1. 新增變數
  const RulePage({super.key, required this.mode, required this.username});

  @override
  Widget build(BuildContext context) {
    String ruleText = "";
    if (mode == '16進位') {
      ruleText = "猜測 6 個不重複字元 (0-9, A-F)。\nA: 位置與數字皆對\nB: 數字對但位置錯";
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
                onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => GamePage(mode: mode, username: username))),
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
  final String username; // 新增這行
  const GamePage({super.key, required this.mode, required this.username});

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

    pool.shuffle();
    _answer = pool.sublist(0, _codeLength).join();

    _seconds = 0;
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) => setState(() => _seconds++));
  }

  void _checkGuess() {
    String guess = _controller.text;
    int a = 0, b = 0;

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

    setState(() {
      String result = "${a}A${b}B";
      _history.insert(0, "$guess => $result (${_formatTime(_seconds)})");
      
      if (a == _codeLength) {
        _isGameOver = true;
        _timer?.cancel();
        // --- 在這裡觸發 API 上傳 ---
        _submitScore(widget.username);
        _showWinBanner();
      }
      _controller.clear();
    });
  }

  // 實作上傳邏輯
  Future<void> _submitScore(String name) async {
    try {
      // 這裡換成你 GCP VM 的固定 IP 或網域名稱
      final url = Uri.parse('http://35.229.255.125:8000/api/scores/update/'); 
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "username": name,
          "score_increment": 1 // 告訴後端這次要加幾分
        }),
      );

      if (response.statusCode == 200) {
        print("分數登記成功：$name");
      } else {
        print("伺服器回傳錯誤: ${response.body}");
      }
    } catch (e) {
      print("發送分數時發生錯誤: $e");
    }
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
                  bool isDisabled = _controller.text.contains(k);

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

class LeaderboardPage extends StatelessWidget {
  const LeaderboardPage({super.key});

  Future<List<dynamic>> fetchLeaderboard() async {
    final response = await http.get(Uri.parse('http://35.229.255.125:8000/api/scores/'));
    if (response.statusCode == 200) {
      return jsonDecode(utf8.decode(response.bodyBytes)); // 確保中文不亂碼
    }
    throw Exception('無法載入排行榜');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Top Players")),
      body: FutureBuilder<List<dynamic>>(
        future: fetchLeaderboard(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());

          if (snapshot.hasError) {
            // 印出完整錯誤到 console
            print("排行榜錯誤詳情: ${snapshot.error}");
            print("StackTrace: ${snapshot.stackTrace}");
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, color: Colors.red, size: 48),
                  const SizedBox(height: 16),
                  // 顯示完整錯誤在畫面上，方便 debug
                  SelectableText(
                    "錯誤: ${snapshot.error}",
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }
          final players = snapshot.data ?? [];
          return ListView.builder(
            itemCount: players.length,
            itemBuilder: (context, index) {
              return ListTile(
                leading: CircleAvatar(child: Text("${index + 1}")),
                title: Text(players[index]['username']),
                trailing: Text("${players[index]['score']} 點", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              );
            },
          );
        },
      ),
    );
  }
}