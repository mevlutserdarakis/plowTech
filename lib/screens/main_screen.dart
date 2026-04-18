import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'kaydedilenler_screen.dart';
import 'settings_screen.dart';
import '../models/settings_model.dart';
import '../services/ayar_deposu.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final OlcumDegerleri _ortakAyarlar = OlcumDegerleri();
  final GlobalKey<HomeScreenState> _homeKey = GlobalKey<HomeScreenState>();
  late final List<Widget> _pages;

  Future<void> _ayarlariYukle() async {
    final kayitliListe = await AyarDeposu().yukle();
    if (kayitliListe != null) {
      setState(() => _ortakAyarlar.ayarListesi = kayitliListe);
    }
  }

  void _girdileriHomeaYukle(double arEn, double arBo, double v1Kmh, double mig) {
    _homeKey.currentState?.girdileriYukle(arEn, arBo, v1Kmh, mig);
    setState(() => _selectedIndex = 0);
  }

  @override
  void initState() {
    super.initState();
    _ayarlariYukle();
    _pages = [
      HomeScreen(key: _homeKey, olcumDegerleri: _ortakAyarlar),
      KaydedilenlerScreen(
        olcumDegerleri: _ortakAyarlar,
        onGirdileriYukle: _girdileriHomeaYukle,
      ),
      SettingsScreen(olcumDegerleri: _ortakAyarlar),
    ];
  }

  @override
  Widget build(BuildContext context) {

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 600) {
          return Scaffold(
            body: Row(
              children: [
                NavigationRail(
                  backgroundColor: const Color.fromARGB(255, 163, 200, 209),
                  selectedIndex: _selectedIndex,
                  onDestinationSelected: (int index) {
                    setState(() => _selectedIndex = index);
                  },
                  labelType: NavigationRailLabelType.all,
                  destinations: const [
                    NavigationRailDestination(
                      icon: Icon(Icons.calculate_outlined),
                      selectedIcon: Icon(Icons.calculate),
                      label: Text('Hesaplama'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.bookmark_border),
                      selectedIcon: Icon(Icons.bookmark),
                      label: Text('Kaydedilenler'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.settings_outlined),
                      selectedIcon: Icon(Icons.settings),
                      label: Text('Ayarlar'),
                    ),
                  ],
                ),
                const VerticalDivider(thickness: 1, width: 1),
                Expanded(child: _pages[_selectedIndex]),
              ],
            ),
          );
        } else {
          return Scaffold(
            body: _pages[_selectedIndex],
            bottomNavigationBar: BottomNavigationBar(
              currentIndex: _selectedIndex,
              onTap: (int index) {
                setState(() => _selectedIndex = index);
              },
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.calculate),
                  label: 'Hesaplama',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.bookmark),
                  label: 'Kaydedilenler',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.settings),
                  label: 'Ayarlar',
                ),
              ],
            ),
          );
        }
      },
    );
  }
}
