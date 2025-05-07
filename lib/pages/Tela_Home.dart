import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:fl_chart/fl_chart.dart';
import 'user.dart';
import 'user_preferences.dart';

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
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Obtém as preferências do usuário com observação para rebuild automático
    final userPreferences = context.watchUserPreferences;
    final TextStyle headerStyle = _getTextStyle(context, userPreferences, true);
    final TextStyle contentStyle = _getTextStyle(context, userPreferences, false);
    
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : NestedScrollView(
              headerSliverBuilder: (context, innerBoxIsScrolled) => [
                _buildAppBar(context, userPreferences),
              ],
              body: _buildBody(context, headerStyle, contentStyle),
            ),
      bottomNavigationBar: _buildBottomNavigation(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Adicionar novo item')),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, UserPreferences preferences) {
    return SliverAppBar(
      expandedHeight: 200.0,
      floating: false,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
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
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      InkWell(
                        onTap: () => context.push('/profile', extra: widget.user),
                        child: CircleAvatar(
                          radius: 30,
                          backgroundColor: Colors.white.withOpacity(0.3),
                          child: Text(
                            _getInitials(),
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: InkWell(
                          onTap: () => context.push('/profile', extra: widget.user),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Olá, ${widget.user.displayName ?? "Usuário"}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Bem-vindo ao seu painel',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.8),
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.settings, color: Colors.white),
                        onPressed: () => context.push('/settings'),
                        tooltip: 'Configurações',
                      ),
                      IconButton(
                        icon: const Icon(Icons.notifications, color: Colors.white),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Notificações')),
                          );
                        },
                        tooltip: 'Notificações',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        title: Text(
          'Início',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: _getFontSize(preferences.fontSize, 20),
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(
            preferences.themeMode == ThemeMode.dark
                ? Icons.light_mode
                : Icons.dark_mode,
            color: Colors.white,
          ),
          onPressed: () {
            // Alterna entre temas claro e escuro
            final newTheme = preferences.themeMode == ThemeMode.dark
                ? ThemeMode.light
                : ThemeMode.dark;
            preferences.setThemeMode(newTheme);
          },
          tooltip: 'Alternar tema',
        ),
      ],
      bottom: TabBar(
        controller: _tabController,
        indicatorColor: Colors.white,
        tabs: const [
          Tab(text: 'Visão Geral'),
          Tab(text: 'Estatísticas'),
          Tab(text: 'Atividades'),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context, TextStyle headerStyle, TextStyle contentStyle) {
    return TabBarView(
      controller: _tabController,
      children: [
        // Tab 1: Visão Geral
        _buildOverviewTab(context, headerStyle, contentStyle),
        
        // Tab 2: Estatísticas
        _buildStatisticsTab(context, headerStyle, contentStyle),
        
        // Tab 3: Atividades
        _buildActivitiesTab(context, headerStyle, contentStyle),
      ],
    );
  }

  Widget _buildOverviewTab(BuildContext context, TextStyle headerStyle, TextStyle contentStyle) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Resumo do Usuário', style: headerStyle),
          const SizedBox(height: 16),
          
          // Card com informações do usuário
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        child: Text(_getInitials(), style: const TextStyle(color: Colors.white)),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(widget.user.displayName ?? 'Usuário', style: contentStyle),
                            Text(widget.user.email, style: contentStyle.copyWith(color: Colors.grey)),
                          ],
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () => context.push('/profile', extra: widget.user),
                        child: const Text('Ver Perfil'),
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildInfoColumn('Status', widget.user.isActive ? 'Ativo' : 'Inativo', contentStyle),
                      _buildInfoColumn('Registrado em', _formatDateShort(widget.user.createdAt), contentStyle),
                      _buildInfoColumn('Itens', '${widget.recentItems.length}', contentStyle),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Card com gráfico de itens
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Distribuição de Itens', style: headerStyle),
                      TextButton.icon(
                        icon: const Icon(Icons.arrow_forward),
                        label: const Text('Detalhes'),
                        onPressed: () => context.push('/item-details'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 200,
                    child: _buildItemsChart(),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Lista de itens recentes
          Text('Itens Recentes', style: headerStyle),
          const SizedBox(height: 8),
          
          ...widget.recentItems.take(5).map((item) => 
            Card(
              elevation: 1,
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: item.color,
                  child: Text(
                    item.name.substring(0, 1),
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                title: Text(item.name, style: contentStyle),
                subtitle: Text(
                  'Quantidade: ${item.quantity} • Atualizado: ${_formatDateShort(item.updatedAt)}',
                  style: contentStyle.copyWith(fontSize: contentStyle.fontSize! * 0.8),
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push('/item-details', extra: item),
              ),
            ),
          ),
          
          if (widget.recentItems.length > 5)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Center(
                child: TextButton.icon(
                  icon: const Icon(Icons.list),
                  label: const Text('Ver Todos os Itens'),
                  onPressed: () => context.push('/item-details'),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatisticsTab(BuildContext context, TextStyle headerStyle, TextStyle contentStyle) {
    // Calcular dados para estatísticas
    final totalItems = widget.recentItems.length;
    final totalQuantity = widget.recentItems.fold<int>(0, (sum, item) => sum + item.quantity);
    final averageQuantity = totalItems > 0 ? totalQuantity / totalItems : 0;
    
    // Encontrar o item mais recente
    widget.recentItems.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    final mostRecentItem = widget.recentItems.isNotEmpty ? widget.recentItems.first : null;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Estatísticas dos Itens', style: headerStyle),
          const SizedBox(height: 16),
          
          // Cards com estatísticas
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  context,
                  'Total de Itens',
                  '$totalItems',
                  Icons.inventory,
                  contentStyle,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  context,
                  'Quantidade Total',
                  '$totalQuantity',
                  Icons.shopping_cart,
                  contentStyle,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  context,
                  'Média por Item',
                  averageQuantity.toStringAsFixed(1),
                  Icons.analytics,
                  contentStyle,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  context,
                  'Item Mais Recente',
                  mostRecentItem?.name ?? 'N/A',
                  Icons.new_releases,
                  contentStyle,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Gráfico de barras para quantidade por item
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Quantidade por Item', style: headerStyle),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 250,
                    child: _buildBarChart(),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Timeline de atividades
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Atividade Recente', style: headerStyle),
                  const SizedBox(height: 16),
                  ...widget.recentItems.take(3).map((item) => 
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            children: [
                              CircleAvatar(
                                radius: 6,
                                backgroundColor: item.color,
                              ),
                              if (item != widget.recentItems.take(3).last)
                                Container(
                                  width: 2,
                                  height: 30,
                                  color: Colors.grey.withOpacity(0.3),
                                ),
                            ],
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Atualização de ${item.name}',
                                  style: contentStyle.copyWith(fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  'Quantidade alterada para ${item.quantity}',
                                  style: contentStyle,
                                ),
                                Text(
                                  _formatDate(item.updatedAt),
                                  style: contentStyle.copyWith(
                                    color: Colors.grey,
                                    fontSize: contentStyle.fontSize! * 0.8,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Center(
                    child: TextButton(
                      onPressed: () {
                        _tabController.animateTo(2); // Vai para a tab de Atividades
                      },
                      child: const Text('Ver Todas as Atividades'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivitiesTab(BuildContext context, TextStyle headerStyle, TextStyle contentStyle) {
    // Ordena os itens pelo mais recente
    final sortedItems = List<ItemData>.from(widget.recentItems)
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: sortedItems.length + 1, // +1 para o cabeçalho
      itemBuilder: (context, index) {
        if (index == 0) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Text('Histórico de Atividades', style: headerStyle),
          );
        }
        
        final item = sortedItems[index - 1];
        return Card(
          margin: const EdgeInsets.only(bottom: 12.0),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: item.color,
                      child: Text(
                        item.name.substring(0, 1),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.name,
                            style: contentStyle.copyWith(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            _formatDate(item.updatedAt),
                            style: contentStyle.copyWith(
                              color: Colors.grey,
                              fontSize: contentStyle.fontSize! * 0.8,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.info_outline),
                      onPressed: () => context.push('/item-details', extra: item),
                      tooltip: 'Ver detalhes',
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Quantidade atual: ${item.quantity}',
                  style: contentStyle,
                ),
                if (item.description != null && item.description!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      item.description!,
                      style: contentStyle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => context.push('/item-details', extra: item),
                      child: const Text('Ver Detalhes'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Editar ${item.name}')),
                        );
                      },
                      child: const Text('Editar'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBottomNavigation() {
    return BottomNavigationBar(
      currentIndex: 0, // Home é a tela atual
      onTap: (index) {
        switch (index) {
          case 0:
            // Já estamos na home
            break;
          case 1:
            context.push('/item-details');
            break;
          case 2:
            context.push('/profile', extra: widget.user);
            break;
          case 3:
            context.push('/settings');
            break;
        }
      },
      type: BottomNavigationBarType.fixed,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Início',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.inventory),
          label: 'Itens',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Perfil',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings),
          label: 'Config.',
        ),
      ],
    );
  }

  // Widgets auxiliares
  Widget _buildInfoColumn(String title, String value, TextStyle style) {
    return Column(
      children: [
        Text(
          title,
          style: style.copyWith(color: Colors.grey, fontSize: style.fontSize! * 0.8),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: style.copyWith(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String title,
    String value,
    IconData iconData,
    TextStyle style,
  ) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              iconData,
              color: Theme.of(context).colorScheme.primary,
              size: 28,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: style.copyWith(
                color: Colors.grey,
                fontSize: style.fontSize! * 0.9,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: style.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: style.fontSize! * 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Gráficos
  Widget _buildItemsChart() {
    // Agrupa itens por categoria para o gráfico de pizza
    final Map<String, int> categoryData = {};
    for (var item in widget.recentItems) {
      final category = item.category ?? 'Sem categoria';
      categoryData[category] = (categoryData[category] ?? 0) + 1;
    }

    // Cria seções para o gráfico de pizza
    final List<PieChartSectionData> sections = [];
    int i = 0;
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.red,
    ];

    categoryData.forEach((category, count) {
      sections.add(
        PieChartSectionData(
          color: colors[i % colors.length],
          value: count.toDouble(),
          title: '${(count / widget.recentItems.length * 100).toStringAsFixed(0)}%',
          radius: 60,
          titleStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      );
      i++;
    });

    return Row(
      children: [
        Expanded(
          child: PieChart(
            PieChartData(
              sections: sections,
              centerSpaceRadius: 40,
              sectionsSpace: 2,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ...categoryData.entries.map((entry) {
                final index = categoryData.keys.toList().indexOf(entry.key);
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        color: colors[index % colors.length],
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '${entry.key} (${entry.value})',
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBarChart() {
    // Limita a 7 itens para o gráfico de barras
    final itemsForChart = widget.recentItems.take(7).toList();
    
    // Cria barras para cada item
    final List<BarChartGroupData> barGroups = [];
    for (int i = 0; i < itemsForChart.length; i++) {
      final item = itemsForChart[i];
      barGroups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: item.quantity.toDouble(),
              color: item.color,
              width: 16,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(6),
                topRight: Radius.circular(6),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        Expanded(
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: itemsForChart.fold<int>(0, (max, item) => 
                  item.quantity > max ? item.quantity : max).toDouble() * 1.2,
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 30,
                    getTitlesWidget: (value, meta) {
                      return Text(
                        value.toInt().toString(),
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 10,
                        ),
                      );
                    },
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      if (value.toInt() >= itemsForChart.length) {
                        return const SizedBox();
                      }
                      return Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          itemsForChart[value.toInt()].name,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 10,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    },
                  ),
                ),
                rightTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                topTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
              ),
              borderData: FlBorderData(show: false),
              gridData: FlGridData(
                show: true,
                horizontalInterval: 20,
                drawVerticalLine: false,
                getDrawingHorizontalLine: (value) {
                  return FlLine(
                    color: Colors.grey.withOpacity(0.2),
                    strokeWidth: 1,
                  );
                },
              ),
              barGroups: barGroups,
            ),
          ),
        ),
      ],
    );
  }

  // Helpers
  String _getInitials() {
    if (widget.user.displayName == null || widget.user.displayName!.isEmpty) {
      return widget.user.email.substring(0, 1).toUpperCase();
    }
    
    final nameParts = widget.user.displayName!.split(' ');
    if (nameParts.length > 1) {
      return '${nameParts.first.substring(0, 1)}${nameParts.last.substring(0, 1)}'.toUpperCase();
    }
    
    return nameParts.first.substring(0, 1).toUpperCase();
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} às ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  String _formatDateShort(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  // Ajusta o estilo de texto conforme as preferências de tamanho de fonte
  TextStyle _getTextStyle(BuildContext context, UserPreferences preferences, bool isHeader) {
    final baseStyle = isHeader 
        ? Theme.of(context).textTheme.titleLarge 
        : Theme.of(context).textTheme.bodyMedium;
    
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
    
    return baseStyle!.copyWith(
      fontSize: baseStyle.fontSize! * fontSizeFactor,
      fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
    );
  }

  double _getFontSize(FontSize size, double baseSize) {
    switch (size) {
      case FontSize.small:
        return baseSize * 0.9;
      case FontSize.medium:
        return baseSize;
      case FontSize.large:
        return baseSize * 1.2;
      case FontSize.extraLarge:
        return baseSize * 1.4;
      default:
        return baseSize;
    }
  }
}

// Modelo de dados para ItemData
class ItemData {
  final String name;
  final int quantity;
  final Color color;
  final DateTime updatedAt;
  final String? category;
  final String? description;

  const ItemData({
    required this.name,
    required this.quantity,
    required this.color,
    required this.updatedAt,
    this.category,
    this.description,
  });

  // Método auxiliar para criar uma lista de itens de exemplo
  static List<ItemData> generateSampleItems() {
    final random = Random();
    final categories = ['Alimentos', 'Eletrônicos', 'Vestuário', 'Outros'];
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.red,
    ];

    final items = [
      'Arroz',
      'Feijão',
      'Smartphone',
      'Notebook',
      'Camiseta',
      'Calça',
      'Livro',
      'Caderno',
      'Caneta',
      'Relógio',
    ];

    final descriptions = [
      'Produto de alta qualidade',
      'Em estoque',
      'Nova chegada',
      'Promoção',
      'Última unidade',
      null,
    ];

    return List.generate(
      10,
      (index) => ItemData(
        name: items[index],
        quantity: random.nextInt(100) + 1,
        color: colors[random.nextInt(colors.length)],
        updatedAt: DateTime.now().subtract(Duration(days: random.nextInt(30))),
        category: categories[random.nextInt(categories.length)],
        description: descriptions[random.nextInt(descriptions.length)],
      ),
    );
  }
}

// Extensão para acessar as preferências do usuário usando o InheritedWidget
extension UserPreferencesExtension on BuildContext {
  UserPreferences get readUserPreferences => 
      UserPreferencesInheritedWidget.of(this);
  
  UserPreferences get watchUserPreferences => 
      UserPreferencesInheritedWidget.of(this, listen: true);
}

// Widget InheritedWidget para gerenciar as preferências do usuário
class UserPreferencesInheritedWidget extends InheritedWidget {
  final UserPreferences userPreferences;

  const UserPreferencesInheritedWidget({
    super.key,
    required this.userPreferences,
    required super.child,
  });

  static UserPreferences of(BuildContext context, {bool listen = false}) {
    if (listen) {
      return context.dependOnInheritedWidgetOfExactType<UserPreferencesInheritedWidget>()!.userPreferences;
    }
    return context.getInheritedWidgetOfExactType<UserPreferencesInheritedWidget>()!.userPreferences;
  }

  @override
  bool updateShouldNotify(UserPreferencesInheritedWidget oldWidget) {
    return userPreferences != oldWidget.userPreferences;
  }
}

// Exemplo de implementação da classe User
class User {
  final String email;
  final String? displayName;
  final bool isActive;
  final DateTime createdAt;

  const User({
    required this.email,
    this.displayName,
    required this.isActive,
    required this.createdAt,
  });

  // Método para criar um usuário de exemplo
  static User createSample() {
    return User(
      email: 'usuario@exemplo.com',
      displayName: 'João Silva',
      isActive: true,
      createdAt: DateTime.now().subtract(const Duration(days: 120)),
    );
  }
}

// Enumeração para tamanhos de fonte
enum FontSize {
  small,
  medium,
  large,
  extraLarge,
}

// Classe para gerenciar as preferências do usuário
class UserPreferences extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  FontSize _fontSize = FontSize.medium;
  bool _useHighContrast = false;
  bool _reduceAnimations = false;

  ThemeMode get themeMode => _themeMode;
  FontSize get fontSize => _fontSize;
  bool get useHighContrast => _useHighContrast;
  bool get reduceAnimations => _reduceAnimations;

  void setThemeMode(ThemeMode mode) {
    if (_themeMode != mode) {
      _themeMode = mode;
      notifyListeners();
    }
  }

  void setFontSize(FontSize size) {
    if (_fontSize != size) {
      _fontSize = size;
      notifyListeners();
    }
  }

  void setUseHighContrast(bool value) {
    if (_useHighContrast != value) {
      _useHighContrast = value;
      notifyListeners();
    }
  }

  void setReduceAnimations(bool value) {
    if (_reduceAnimations != value) {
      _reduceAnimations = value;
      notifyListeners();
    }
  }

  // Método para criar uma instância com valores padrão
  static UserPreferences createDefault() {
    return UserPreferences();
  }
}

// Exemplo de uso da aplicação
void main() {
  final userPreferences = UserPreferences.createDefault();
  
  runApp(
    ChangeNotifierProvider.value(
      value: userPreferences,
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final userPreferences = Provider.of<UserPreferences>(context);
    
    return UserPreferencesInheritedWidget(
      userPreferences: userPreferences,
      child: MaterialApp.router(
        title: 'App de Gerenciamento',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blue,
            brightness: Brightness.light,
          ),
          useMaterial3: true,
        ),
        darkTheme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blue,
            brightness: Brightness.dark,
          ),
          useMaterial3: true,
        ),
        themeMode: userPreferences.themeMode,
        routerConfig: _router,
      ),
    );
  }
}

// Configuração do GoRouter
final _router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => HomePage(
        user: User.createSample(),
        recentItems: ItemData.generateSampleItems(),
      ),
    ),
    GoRoute(
      path: '/profile',
      builder: (context, state) {
        final user = state.extra as User;
        return ProfilePage(user: user);
      },
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsPage(),
    ),
    GoRoute(
      path: '/item-details',
      builder: (context, state) {
        final item = state.extra as ItemData?;
        return ItemDetailsPage(item: item);
      },
    ),
  ],
);

// Páginas adicionais que seriam implementadas
class ProfilePage extends StatelessWidget {
  final User user;

  const ProfilePage({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil do Usuário'),
      ),
      body: Center(
        child: Text('Perfil de ${user.displayName ?? "Usuário"}'),
      ),
    );
  }
}

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final userPreferences = context.watchUserPreferences;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configurações'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          ListTile(
            title: const Text('Tema'),
            subtitle: Text(
              userPreferences.themeMode == ThemeMode.dark
                  ? 'Escuro'
                  : userPreferences.themeMode == ThemeMode.light
                      ? 'Claro'
                      : 'Sistema',
            ),
            trailing: DropdownButton<ThemeMode>(
              value: userPreferences.themeMode,
              onChanged: (value) {
                if (value != null) {
                  userPreferences.setThemeMode(value);
                }
              },
              items: const [
                DropdownMenuItem(
                  value: ThemeMode.system,
                  child: Text('Sistema'),
                ),
                DropdownMenuItem(
                  value: ThemeMode.light,
                  child: Text('Claro'),
                ),
                DropdownMenuItem(
                  value: ThemeMode.dark,
                  child: Text('Escuro'),
                ),
              ],
            ),
          ),
          ListTile(
            title: const Text('Tamanho da Fonte'),
            subtitle: Text(_getFontSizeName(userPreferences.fontSize)),
            trailing: DropdownButton<FontSize>(
              value: userPreferences.fontSize,
              onChanged: (value) {
                if (value != null) {
                  userPreferences.setFontSize(value);
                }
              },
              items: const [
                DropdownMenuItem(
                  value: FontSize.small,
                  child: Text('Pequeno'),
                ),
                DropdownMenuItem(
                  value: FontSize.medium,
                  child: Text('Médio'),
                ),
                DropdownMenuItem(
                  value: FontSize.large,
                  child: Text('Grande'),
                ),
                DropdownMenuItem(
                  value: FontSize.extraLarge,
                  child: Text('Extra Grande'),
                ),
              ],
            ),
          ),
          SwitchListTile(
            title: const Text('Alto Contraste'),
            subtitle: const Text('Melhora a legibilidade'),
            value: userPreferences.useHighContrast,
            onChanged: (value) {
              userPreferences.setUseHighContrast(value);
            },
          ),
          SwitchListTile(
            title: const Text('Reduzir Animações'),
            subtitle: const Text('Melhora o desempenho'),
            value: userPreferences.reduceAnimations,
            onChanged: (value) {
              userPreferences.setReduceAnimations(value);
            },
          ),
        ],
      ),
    );
  }

  String _getFontSizeName(FontSize size) {
    switch (size) {
      case FontSize.small:
        return 'Pequeno';
      case FontSize.medium:
        return 'Médio';
      case FontSize.large:
        return 'Grande';
      case FontSize.extraLarge:
        return 'Extra Grande';
      default:
        return 'Médio';
    }
  }
}

class ItemDetailsPage extends StatelessWidget {
  final ItemData? item;

  const ItemDetailsPage({super.key, this.item});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(item != null ? 'Detalhes do Item' : 'Lista de Itens'),
      ),
      body: Center(
        child: Text(
          item != null 
              ? 'Detalhes de ${item!.name}' 
              : 'Lista de todos os itens',
        ),
      ),
    );
  }
}