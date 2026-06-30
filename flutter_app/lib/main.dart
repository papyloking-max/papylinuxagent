import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'core/theme.dart';
import 'screens/login_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/chat_screen.dart';
import 'screens/agents_screen.dart';
import 'screens/terminal_screen.dart';
import 'screens/ollama_screen.dart';
import 'screens/workflow_editor_screen.dart';
import 'screens/knowledge_upload_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox('papylinux');
  runApp(const ProviderScope(child: PapylinuxAgentApp()));
}

class PapylinuxAgentApp extends StatelessWidget {
  const PapylinuxAgentApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PapylinuxAgent',
      theme: AppTheme.darkTheme,
      debugShowCheckedModeBanner: false,
      initialRoute: '/login',
      routes: {
        '/login': (_) => const LoginScreen(),
        '/home': (_) => const MainScaffold(),
      },
    );
  }
}

class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});
  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    DashboardScreen(),
    ChatScreen(),
    AgentsScreen(),
    TerminalScreen(),
    OllamaScreen(),
    WorkflowEditorScreen(),
    KnowledgeUploadScreen(),
  ];

  final List<String> _titles = ['Dashboard', 'Chat', 'Agents', 'Terminal', 'Ollama', 'Workflows', 'Knowledge'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_currentIndex]),
        backgroundColor: const Color(0xFF1E1E2E),
        actions: [
          IconButton(icon: const Icon(Icons.logout), onPressed: () => Navigator.pushReplacementNamed(context, '/login')),
        ],
      ),
      body: _screens[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (i) => setState(() => _currentIndex = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.dashboard), label: 'Dash'),
          NavigationDestination(icon: Icon(Icons.chat), label: 'Chat'),
          NavigationDestination(icon: Icon(Icons.smart_toy), label: 'Agents'),
          NavigationDestination(icon: Icon(Icons.terminal), label: 'Term'),
          NavigationDestination(icon: Icon(Icons.memory), label: 'Ollama'),
          NavigationDestination(icon: Icon(Icons.autorenew), label: 'Flows'),
          NavigationDestination(icon: Icon(Icons.menu_book), label: 'KB'),
        ],
      ),
    );
  }
}
