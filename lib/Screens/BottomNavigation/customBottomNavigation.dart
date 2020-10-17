import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sixtyseconds/Screens/BottomNavigation/tab_items.dart';

class CustomBottomNavigation extends StatelessWidget {
  const CustomBottomNavigation(
      {Key key,
      @required this.currentTab,
      @required this.onSelectedTab,
      @required this.pageGenerator,
      @required this.navigatorsKeys})
      : super(key: key);

  final TabItem currentTab;
  final ValueChanged<TabItem> onSelectedTab;
  final Map<TabItem, Widget> pageGenerator;
  final Map<TabItem, GlobalKey<NavigatorState>> navigatorsKeys;

  @override
  Widget build(BuildContext context) {
    return CupertinoTabScaffold(
      tabBar: CupertinoTabBar(
        items: [
          _navItemOlustur(TabItem.Kullanicilar),
          _navItemOlustur(TabItem.Konusmalarim),
          _navItemOlustur(TabItem.Profil)
        ],
        onTap: (index) => onSelectedTab(TabItem.values[index]),
      ),
      tabBuilder: (context, index) {
        final gosterilecekItem = TabItem.values[index];
        return CupertinoTabView(
            navigatorKey: navigatorsKeys[gosterilecekItem],
            builder: (context) {
              return pageGenerator[gosterilecekItem];
            });
      },
    );
  }

  BottomNavigationBarItem _navItemOlustur(TabItem tabItem) {
    final olusturulacakTab = TabItemData.tumTablar[tabItem];
    return BottomNavigationBarItem(
        icon: Icon(olusturulacakTab.icon), label: olusturulacakTab.title);
  }
}
