import 'dart:ui';
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
  final bool _isLoading = false;

  // Valores para o blur effect (mesmo conceito do login)
  final double _sigmaX = 5;
  final double _sigmaY = 5;
  final double _opacity = 0.2;

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
      backgroundColor: Colors.grey[800], // Background escuro como no login
      body: Stack(
        children: [
          // Background com gradiente
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.grey[800]!,
                  Colors.grey[900]!,
                  Colors.black,
                ],
              ),
            ),
          ),
          
          // Conteúdo principal
          SafeArea(
            child: Column(
              children: [
                _buildModernAppBar(context),
                Expanded(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator(
                          color: Color.fromARGB(255, 71, 233, 133),
                        ))
                      : TabBarView(
                          controller: _tabController,
                          children: [
                            _buildOverviewTab(headerStyle, contentStyle),
                            _buildExpensesTab(headerStyle, contentStyle),
                            _buildSavingsTab(headerStyle, contentStyle),
                          ],
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildModernBottomNavigation(context),
    );
  }

  Widget _buildModernAppBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Header com informações do usuário
          Row(
            children: [
              CircleAvatar(
                radius: 25,
                backgroundColor: const Color.fromARGB(255, 71, 233, 133),
                child: Text(
                  (widget.user.displayName?.isNotEmpty == true) 
                      ? widget.user.displayName![0].toUpperCase()
                      : 'U',
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Olá, ${widget.user.displayName ?? 'Usuário'}!',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text(
                      'Bem-vindo ao The Broke Club',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.settings, color: Colors.white),
                onPressed: () => context.push('/settings'),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // TabBar personalizada
          Container(
            decoration: BoxDecoration(
              color: Colors.grey[850],
              borderRadius: BorderRadius.circular(25),
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                color: const Color.fromARGB(255, 71, 233, 133),
                borderRadius: BorderRadius.circular(25),
              ),
              labelColor: Colors.black,
              unselectedLabelColor: Colors.white70,
              dividerColor: Colors.transparent,
              tabs: const [
                Tab(text: 'Visão Geral'),
                Tab(text: 'Despesas'),
                Tab(text: 'Poupança'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernBottomNavigation(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: _sigmaX, sigmaY: _sigmaY),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(_opacity),
            border: Border(
              top: BorderSide(color: Colors.grey[700]!, width: 0.5),
            ),
          ),
          child: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.transparent,
            selectedItemColor: const Color.fromARGB(255, 71, 233, 133),
            unselectedItemColor: Colors.grey,
            elevation: 0,
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
              BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Faturas'),
              BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
            ],
            currentIndex: 0,
            onTap: (index) {
              switch (index) {
                case 0:
                  // Já está na home
                  break;
                case 1:
                  context.push('/invoices');
                  break;
                case 2:
                  context.push('/profile', extra: widget.user);
                  break;
              }
            },
          ),
        ),
      ),
    );
  }

  Widget _buildOverviewTab(TextStyle headerStyle, TextStyle contentStyle) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildModernBalanceCard(contentStyle),
          const SizedBox(height: 24),
          Text('Atividade Recente', 
            style: headerStyle.copyWith(color: Colors.white)),
          const SizedBox(height: 12),
          _buildModernRecentActivityList(contentStyle),
        ],
      ),
    );
  }

  Widget _buildModernBalanceCard(TextStyle contentStyle) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: _sigmaX, sigmaY: _sigmaY),
        child: Container(
          padding: const EdgeInsets.all(24.0),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(_opacity),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: const Color.fromARGB(255, 71, 233, 133).withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Saldo Atual',
                    style: contentStyle.copyWith(
                      color: Colors.white70,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Icon(
                    Icons.visibility,
                    color: Colors.grey[500],
                    size: 20,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'R\$ 1.234,56',
                style: contentStyle.copyWith(
                  fontSize: 32,
                  color: const Color.fromARGB(255, 71, 233, 133),
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildBalanceItem(
                      'Receitas',
                      'R\$ 2.000,00',
                      Colors.green,
                      Icons.arrow_upward,
                      contentStyle,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildBalanceItem(
                      'Despesas',
                      'R\$ 765,44',
                      Colors.red,
                      Icons.arrow_downward,
                      contentStyle,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBalanceItem(String title, String amount, Color color, IconData icon, TextStyle style) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: style.copyWith(color: Colors.white70, fontSize: 12)),
                Text(amount, style: style.copyWith(color: color, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernRecentActivityList(TextStyle contentStyle) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: widget.recentItems.length,
      itemBuilder: (context, index) {
        final item = widget.recentItems[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          child: ClipRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[700]!, width: 0.5),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 71, 233, 133).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        item.icon,
                        color: const Color.fromARGB(255, 71, 233, 133),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.name,
                            style: contentStyle.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            item.date,
                            style: contentStyle.copyWith(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      'R\$ ${item.amount.toStringAsFixed(2)}',
                      style: contentStyle.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
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
          Text('Despesas', style: headerStyle.copyWith(color: Colors.white)),
          const SizedBox(height: 16),
          _buildModernPieChart(),
          const SizedBox(height: 24),
          Text('Detalhes', style: headerStyle.copyWith(color: Colors.white)),
          const SizedBox(height: 12),
          _buildModernExpenseDetails(contentStyle),
        ],
      ),
    );
  }

  Widget _buildModernPieChart() {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: _sigmaX, sigmaY: _sigmaY),
        child: Container(
          height: 250,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(_opacity),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: const Color.fromARGB(255, 71, 233, 133).withOpacity(0.3),
              width: 1,
            ),
          ),
          child: PieChart(
            PieChartData(
              sections: [
                PieChartSectionData(
                  value: 40,
                  color: Colors.red[400]!,
                  title: 'Moradia\n40%',
                  titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  radius: 80,
                ),
                PieChartSectionData(
                  value: 30,
                  color: Colors.blue[400]!,
                  title: 'Alimentação\n30%',
                  titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  radius: 80,
                ),
                PieChartSectionData(
                  value: 20,
                  color: const Color.fromARGB(255, 71, 233, 133),
                  title: 'Transporte\n20%',
                  titleStyle: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                  radius: 80,
                ),
                PieChartSectionData(
                  value: 10,
                  color: Colors.yellow[600]!,
                  title: 'Outros\n10%',
                  titleStyle: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                  radius: 80,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModernExpenseDetails(TextStyle contentStyle) {
    final expenses = [
      {'title': 'Moradia', 'amount': 'R\$ 800,00', 'color': Colors.red[400]!},
      {'title': 'Alimentação', 'amount': 'R\$ 600,00', 'color': Colors.blue[400]!},
      {'title': 'Transporte', 'amount': 'R\$ 400,00', 'color': const Color.fromARGB(255, 71, 233, 133)},
      {'title': 'Outros', 'amount': 'R\$ 200,00', 'color': Colors.yellow[600]!},
    ];

    return Column(
      children: expenses.map((expense) => Container(
        margin: const EdgeInsets.only(bottom: 8),
        child: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[700]!, width: 0.5),
              ),
              child: Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: expense['color'] as Color,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      expense['title'] as String,
                      style: contentStyle.copyWith(color: Colors.white),
                    ),
                  ),
                  Text(
                    expense['amount'] as String,
                    style: contentStyle.copyWith(
                      color: expense['color'] as Color,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      )).toList(),
    );
  }

  Widget _buildSavingsTab(TextStyle headerStyle, TextStyle contentStyle) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Poupança', style: headerStyle.copyWith(color: Colors.white)),
          const SizedBox(height: 16),
          _buildModernSavingsProgress(contentStyle),
          const SizedBox(height: 24),
          Text('Metas', style: headerStyle.copyWith(color: Colors.white)),
          const SizedBox(height: 12),
          _buildModernSavingsGoals(contentStyle),
        ],
      ),
    );
  }

  Widget _buildModernSavingsProgress(TextStyle contentStyle) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: _sigmaX, sigmaY: _sigmaY),
        child: Container(
          padding: const EdgeInsets.all(24.0),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(_opacity),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: const Color.fromARGB(255, 71, 233, 133).withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Progresso de Poupança',
                style: contentStyle.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              
              // Progress indicator personalizado
              Container(
                height: 8,
                decoration: BoxDecoration(
                  color: Colors.grey[800],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: 0.65,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color.fromARGB(255, 71, 233, 133),
                          Color.fromARGB(255, 50, 200, 100),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'R\$ 650,00',
                    style: contentStyle.copyWith(
                      color: const Color.fromARGB(255, 71, 233, 133),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Meta: R\$ 1.000,00',
                    style: contentStyle.copyWith(color: Colors.grey),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModernSavingsGoals(TextStyle contentStyle) {
    final goals = [
      {
        'title': 'Férias',
        'current': 'R\$ 300,00',
        'target': 'R\$ 500,00',
        'progress': 0.6,
        'icon': Icons.beach_access,
        'color': Colors.blue[400]!,
      },
      {
        'title': 'Carro Novo',
        'current': 'R\$ 350,00',
        'target': 'R\$ 2.000,00',
        'progress': 0.175,
        'icon': Icons.directions_car,
        'color': Colors.orange[400]!,
      },
    ];

    return Column(
      children: goals.map((goal) => Container(
        margin: const EdgeInsets.only(bottom: 12),
        child: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey[700]!, width: 0.5),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: (goal['color'] as Color).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          goal['icon'] as IconData,
                          color: goal['color'] as Color,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              goal['title'] as String,
                              style: contentStyle.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              '${goal['current']} de ${goal['target']}',
                              style: contentStyle.copyWith(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '${((goal['progress'] as double) * 100).toInt()}%',
                        style: contentStyle.copyWith(
                          color: goal['color'] as Color,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    height: 6,
                    decoration: BoxDecoration(
                      color: Colors.grey[800],
                      borderRadius: BorderRadius.circular(3),
                    ),
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: goal['progress'] as double,
                      child: Container(
                        decoration: BoxDecoration(
                          color: goal['color'] as Color,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      )).toList(),
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