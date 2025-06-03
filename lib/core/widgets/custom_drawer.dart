import 'package:flutter/material.dart';

import '../../app/routes/routes.dart';


class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF2196F3), Color(0xFF21CBF3)],
              ),
            ),
            child: Text(
              'Calculator App',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Home'),
            onTap: () => _navigateTo(context, RouteNames.home),
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            onTap: () => _navigateTo(context, RouteNames.settings),
          ),
          const Divider(),
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'My Favorites',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.calculate),
            title: const Text('Basic Calculator'),
            onTap: () => _navigateTo(context, RouteNames.basicCalculator),
          ),
          ListTile(
            leading: const Icon(Icons.swap_horiz),
            title: const Text('Unit Calculator'),
            onTap: () => _navigateTo(context, RouteNames.unitCalculator),
          ),
          ListTile(
            leading: const Icon(Icons.currency_exchange),
            title: const Text('Currency Converter'),
            onTap: () => _navigateTo(context, RouteNames.currencyConverter),
          ),
          const Divider(),
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Others',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.discount),
            title: const Text('Discount Calculator'),
            onTap: () => _navigateTo(context, RouteNames.discountCalculator),
          ),
          ListTile(
            leading: const Icon(Icons.receipt_long),
            title: const Text('Tip Calculator'),
            onTap: () => _navigateTo(context, RouteNames.tipCalculator),
          ),
          ListTile(
            leading: const Icon(Icons.storage),
            title: const Text('Data Calculator'),
            onTap: () => _navigateTo(context, RouteNames.dataCalculator),
          ),
          ListTile(
            leading: const Icon(Icons.fitness_center),
            title: const Text('Load Calculator'),
            onTap: () => _navigateTo(context, RouteNames.loadCalculator),
          ),
          ListTile(
            leading: const Icon(Icons.school),
            title: const Text('GPA Calculator'),
            onTap: () => _navigateTo(context, RouteNames.gpaCalculator),
          ),
          ListTile(
            leading: const Icon(Icons.monitor_weight),
            title: const Text('BMI Calculator'),
            onTap: () => _navigateTo(context, RouteNames.bmiCalculator),
          ),
        ],
      ),
    );
  }

  void _navigateTo(BuildContext context, String routeName) {
    Navigator.pop(context);
    Navigator.pushNamed(context, routeName);
  }
}