import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'Template_Page.dart';
import 'financial_item.dart';

class ItemDetailsPage extends StatefulWidget {
  final String? itemId;
  
  const ItemDetailsPage({super.key, this.itemId});

  @override
  State<ItemDetailsPage> createState() => _ItemDetailsPageState();
}

class _ItemDetailsPageState extends State<ItemDetailsPage> {
  bool _isLoading = true;
  String? _errorMessage;
  FinancialItem? _item;

  @override
  void initState() {
    super.initState();
    _loadItemDetails();
  }

  Future<void> _loadItemDetails() async {
    if (widget.itemId == null) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'ID do item não fornecido';
      });
      return;
    }

    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      // Carrega os detalhes do item usando o Provider
      await Future.delayed(const Duration(milliseconds: 300)); // Simula carregamento
      
      final itemState = Provider.of<FinancialItemState>(context, listen: false);
      final item = itemState.items.firstWhere(
        (item) => item.id == widget.itemId,
        orElse: () => throw Exception('Item não encontrado'),
      );

      setState(() {
        _item = item;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Erro ao carregar detalhes: ${e.toString()}';
      });
    }
  }

  // Formata o valor para exibição
  String _formatCurrency(double value) {
    final formatter = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    return formatter.format(value);
  }

  // Formata a data para exibição
  String _formatDate(DateTime date) {
    final formatter = DateFormat('dd/MM/yyyy');
    return formatter.format(date);
  }

  // Retorna a cor adequada com base no tipo de transação
  Color _getTypeColor() {
    if (_item == null) return Colors.grey;
    return _item!.getTypeColor();
  }

  @override
  Widget build(BuildContext context) {
    // Se estiver carregando, mostra um indicador
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Detalhes do Item')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    // Se ocorreu um erro, mostra a mensagem
    if (_errorMessage != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Erro')),
        body: Center(child: Text(_errorMessage!)),
      );
    }

    // Se não encontrou o item
    if (_item == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Erro')),
        body: const Center(child: Text('Item não encontrado')),
      );
    }

    // Constrói a página de detalhes
    return TemplatePage(
      title: 'Detalhes do Item',
      routes: {'/edit-item?id=${widget.itemId}': 'Editar Item'},
      body: _buildItemDetails(),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/edit-item?id=${widget.itemId}'),
        backgroundColor: Theme.of(context).primaryColor,
        child: const Icon(Icons.edit),
      ),
    );
  }

  Widget _buildItemDetails() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Card principal com informações básicas
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        _item!.getCategoryIcon(),
                        size: 32,
                        color: _getTypeColor(),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          _item!.description,
                          style: Theme.of(context).textTheme.headlineSmall,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Valor:',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text(
                        _item!.getFormattedAmount(),
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: _getTypeColor(),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Data:',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text(
                        _formatDate(_item!.date),
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Tipo:',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Chip(
                        backgroundColor: _getTypeColor().withOpacity(0.2),
                        label: Text(
                          _item!.getTypeName(),
                          style: TextStyle(
                            color: _getTypeColor(),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),
          Text(
            'Detalhes Adicionais',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const Divider(),

          // Detalhes complementares
          _buildDetailItem('Categoria', _item!.getCategoryName()),
          _buildDetailItem('Status', _item!.getStatusName()),
          _buildDetailItem('Método de Pagamento', _item!.getPaymentMethodName()),

          if (_item!.isRecurring)
            _buildDetailItem('Recorrência', 
                'A cada ${_item!.recurrenceInterval} dias'),

          if (_item!.notes != null && _item!.notes!.isNotEmpty)
            _buildNotesCard(_item!.notes!),

          if (_item!.attachmentUrl != null && _item!.attachmentUrl!.isNotEmpty)
            _buildAttachmentCard(_item!.attachmentUrl!),

          const SizedBox(height: 24),
          Text(
            'Informações do Sistema',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const Divider(),

          _buildDetailItem('ID', _item!.id),
          _buildDetailItem('Criado em', _formatDate(_item!.createdAt)),
          _buildDetailItem('Última atualização', _formatDate(_item!.updatedAt)),

          const SizedBox(height: 24),
          Center(
            child: OutlinedButton.icon(
              icon: const Icon(Icons.delete, color: Colors.red),
              label: const Text('Excluir Item'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              onPressed: () => _confirmDeleteItem(context),
            ),
          ),
          const SizedBox(height: 40), // Espaço adicional no final
        ],
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '$label:',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotesCard(String notes) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 16.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.notes, color: Colors.blueGrey),
                const SizedBox(width: 8),
                Text(
                  'Observações',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.blueGrey,
                      ),
                ),
              ],
            ),
            const Divider(),
            Text(
              notes,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttachmentCard(String attachmentUrl) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 16.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.attach_file, color: Colors.blueGrey),
                const SizedBox(width: 8),
                Text(
                  'Anexo',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.blueGrey,
                      ),
                ),
              ],
            ),
            const Divider(),
            const SizedBox(height: 8),
            Center(
              child: Image.network(
                attachmentUrl,
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => const Text(
                  'Não foi possível carregar o anexo',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: TextButton.icon(
                icon: const Icon(Icons.open_in_new),
                label: const Text('Abrir Anexo'),
                onPressed: () {
                  // Implementar abertura do anexo
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Função ainda não implementada')),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDeleteItem(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirmar Exclusão'),
        content: const Text(
          'Deseja realmente excluir este item? Esta ação não pode ser desfeita.',
        ),
        actions: [
          TextButton(
            child: const Text('Cancelar'),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
          TextButton(
            child: const Text(
              'Excluir',
              style: TextStyle(color: Colors.red),
            ),
            onPressed: () async {
              Navigator.of(ctx).pop();
              await _deleteItem();
            },
          ),
        ],
      ),
    );
  }

  Future<void> _deleteItem() async {
    if (_item == null || widget.itemId == null) return;

    try {
      setState(() {
        _isLoading = true;
      });

      final itemState = Provider.of<FinancialItemState>(context, listen: false);
      final success = await itemState.removeItem(widget.itemId!);

      if (success) {
        // Retorna para a tela anterior após excluir
        if (!mounted) return;
        Navigator.of(context).pop(true); // Retorna true para indicar sucesso
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Item excluído com sucesso')),
        );
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erro ao excluir item')),
        );
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro: ${e.toString()}')),
      );
      setState(() {
        _isLoading = false;
      });
    }
  }
}

// Classe adaptadora opcional para compatibilidade com a implementação alternativa
// de FinancialItem caso necessário
class FinancialItemAdapter {
  static FinancialItem fromAlternativeModel(dynamic alternativeItem) {
    // Converte do modelo alternativo para o modelo utilizado nesta tela
    return FinancialItem(
      id: alternativeItem.id,
      userId: alternativeItem.ownerId,
      description: alternativeItem.name,
      amount: alternativeItem.value,
      date: alternativeItem.date,
      type: alternativeItem.isExpense 
          ? TransactionType.expense 
          : TransactionType.income,
      category: _mapCategoryFromString(alternativeItem.category),
      status: PaymentStatus.completed,
      paymentMethod: PaymentMethod.other,
    );
  }

  static TransactionCategory _mapCategoryFromString(String category) {
    switch (category.toLowerCase()) {
      case 'alimentação':
        return TransactionCategory.food;
      case 'moradia':
        return TransactionCategory.housing;
      case 'transporte':
        return TransactionCategory.transportation;
      case 'serviços públicos':
        return TransactionCategory.utilities;
      case 'saúde':
        return TransactionCategory.healthcare;
      case 'entretenimento':
        return TransactionCategory.entertainment;
      case 'educação':
        return TransactionCategory.education;
      case 'compras':
        return TransactionCategory.shopping;
      case 'salário':
        return TransactionCategory.salary;
      case 'investimento':
        return TransactionCategory.investment;
      case 'empréstimos':
        return TransactionCategory.loans;
      default:
        return TransactionCategory.other;
    }
  }
}