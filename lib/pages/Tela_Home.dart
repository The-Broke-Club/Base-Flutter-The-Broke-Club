import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../models/auth_state.dart';
import '../models/item_data.dart';
import '../models/user.dart';

class HomePage extends StatefulWidget {
  final User user;
  final List<ItemData> recentItems;

  const HomePage({
    super.key,
    required this.user,
    required this.recentItems,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    final authState = Provider.of<AuthState>(context, listen: false);
    if (!authState.isAuthenticated) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.go('/login');
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userPreferences = Provider.of<UserPreferences>(context);
    final headerStyle = _getTextStyle(context, userPreferences, true);
    final contentStyle = _getTextStyle(context, userPreferences, false);

    return Scaffold(
      appBar: _buildAppBar(context),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildOverviewTab(headerStyle, contentStyle),
                _buildExpensesTab(headerStyle, contentStyle),
                _buildSavingsTab(headerStyle, contentStyle),
              ],
            ),
      bottomNavigationBar: _buildBottomNavigation(context),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      title: const Text('The Broke Club'),
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).colorScheme.primary,
              Theme.of(context).colorScheme.secondary,
            ],
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.person),
          onPressed: () => context.push('/profile', extra: widget.user),
          tooltip: 'Perfil',
        ),
        IconButton(
          icon: const Icon(Icons.settings),
          onPressed: () => context.push('/settings'),
          tooltip: 'Configurações',
        ),
      ],
      bottom: TabBar(
        controller: _tabController,
        tabs: const [
          Tab(text: 'Visão Geral'),
          Tab(text: 'Despesas'),
          Tab(text: 'Poupança'),
        ],
      ),
    );
  }

  BottomNavigationBar _buildBottomNavigation(BuildContext context) {
    return BottomNavigationBar(
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Faturas'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
      ],
      currentIndex: _tabController.index,
      onTap: (index) {
        switch (index) {
          case 0:
            _tabController.animateTo(0);
            break;
          case 1:
            context.push('/invoices');
            break;
          case 2:
            context.push('/profile', extra: widget.user);
            break;
        }
      },
    );
  }

  Widget _buildOverviewTab(TextStyle headerStyle, TextStyle contentStyle) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Bem-vindo, ${widget.user.displayName ?? 'Usuário'}!', style: headerStyle),
          const SizedBox(height: 16),
          _buildBalanceCard(contentStyle),
          const SizedBox(height: 16),
          Text('Atividade Recente', style: headerStyle),
          const SizedBox(height: 8),
          _buildRecentActivityList(contentStyle),
        ],
      ),
    );
  }

  Widget _buildBalanceCard(TextStyle contentStyle) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Saldo Atual', style: contentStyle.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('R\$ 1.234,56', style: contentStyle.copyWith(fontSize: 24, color: Colors.green)),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Receitas: R\$ 2.000,00', style: contentStyle.copyWith(color: Colors.green)),
                Text('Despesas: R\$ 765,44', style: contentStyle.copyWith(color: Colors.red)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivityList(TextStyle contentStyle) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: widget.recentItems.length,
      itemBuilder: (context, index) {
        final item = widget.recentItems[index];
        return ListTile(
          leading: Icon(item.icon, color: Theme.of(context).primaryColor),
          title: Text(item.name, style: contentStyle),
          subtitle: Text('${item.date} - R\$ ${item.amount.toStringAsFixed(2)}', style: contentStyle.copyWith(color: Colors.grey)),
          onTap: () => context.push('/item-details', extra: item),
        );
      },
    );
  }

  Widget _buildExpensesTab(TextStyle headerStyle, TextStyle contentStyle) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Despesas', style: headerStyle),
          const SizedBox(height: 16),
          _buildPieChart(),
          const SizedBox(height: 16),
          Text('Detalhes', style: headerStyle),
          const SizedBox(height: 8),
          _buildExpenseDetails(contentStyle),
        ],
      ),
    );
  }

  Widget _buildPieChart() {
    return SizedBox(
      height: 200,
      child: PieChart(
        PieChartData(
          sections: [
            PieChartSectionData(value: 40, color: Colors.red, title: 'Moradia'),
            PieChartSectionData(value: 30, color: Colors.blue, title: 'Alimentação'),
            PieChartSectionData(value: 20, color: Colors.green, title: 'Transporte'),
            PieChartSectionData(value: 10, color: Colors.yellow, title: 'Outros'),
          ],
        ),
      ),
    );
  }

  Widget _buildExpenseDetails(TextStyle contentStyle) {
    return Column(
      children: [
        ListTile(
          title: Text('Moradia', style: contentStyle),
          trailing: Text('R\$ 800,00', style: contentStyle.copyWith(color: Colors.red)),
        ),
        ListTile(
          title: Text('Alimentação', style: contentStyle),
          trailing: Text('R\$ 600,00', style: contentStyle.copyWith(color: Colors.blue)),
        ),
        ListTile(
          title: Text('Transporte', style: contentStyle),
          trailing: Text('R\$ 400,00', style: contentStyle.copyWith(color: Colors.green)),
        ),
        ListTile(
          title: Text('Outros', style: contentStyle),
          trailing: Text('R\$ 200,00', style: contentStyle.copyWith(color: Colors.yellow)),
        ),
      ],
    );
  }

  Widget _buildSavingsTab(TextStyle headerStyle, TextStyle contentStyle) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Poupança', style: headerStyle),
          const SizedBox(height: 16),
          _buildSavingsProgress(contentStyle),
          const SizedBox(height: 16),
          Text('Metas', style: headerStyle),
          const SizedBox(height: 8),
          _buildSavingsGoals(contentStyle),
        ],
      ),
    );
  }

  Widget _buildSavingsProgress(TextStyle contentStyle) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Progresso de Poupança', style: contentStyle.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: 0.65,
              backgroundColor: Colors.grey[300],
              color: Colors.green,
            ),
            const SizedBox(height: 8),
            Text('R\$ 650,00 de R\$ 1.000,00', style: contentStyle),
          ],
        ),
      ),
    );
  }

  Widget _buildSavingsGoals(TextStyle contentStyle) {
    return Column(
      children: [
        ListTile(
          title: Text('Férias', style: contentStyle),
          subtitle: Text('R\$ 300,00 / R\$ 500,00', style: contentStyle.copyWith(color: Colors.grey)),
          trailing: const Icon(Icons.beach_access, color: Colors.blue),
        ),
        ListTile(
          title: Text('Carro Novo', style: contentStyle),
          subtitle: Text('R\$ 350,00 / R\$ 2.000,00', style: contentStyle.copyWith(color: Colors.grey)),
          trailing: const Icon(Icons.directions_car, color: Colors.red),
        ),
      ],
    );
  }

  TextStyle _getTextStyle(BuildContext context, UserPreferences preferences, bool isHeader) {
    final baseStyle = isHeader
        ? Theme.of(context).textTheme.titleLarge ?? const TextStyle(fontSize: 20)
        : Theme.of(context).textTheme.bodyMedium ?? const TextStyle(fontSize: 16);

    double fontSizeFactor;
    switch (preferences.fontSize) {
      case FontSize.small:
        fontSizeFactor = isHeader ? 1.0 : 0.9;
        break;
      case FontSize.medium:
        fontSizeFactor = isHeader ? 1.2 : 1.0;
        break;
      case FontSize.large:
        fontSizeFactor = isHeader ? 1.4 : 1.2;
        break;
      case FontSize.extraLarge:
        fontSizeFactor = isHeader ? 1.6 : 1.4;
        break;
    }

    return baseStyle.copyWith(
      fontSize: baseStyle.fontSize! * fontSizeFactor,
      fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
    );
  }
}