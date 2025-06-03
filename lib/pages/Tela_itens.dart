import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:intl/intl.dart';
import '../models/auth_state.dart';
import '../utils/validators.dart';
import '../utils/constants.dart';
import '../models/user.dart';
import '../models/invoice.dart';
import '../template_page.dart';
import '../blocs/invoice/invoice_bloc.dart';
import '../blocs/invoice/invoice_event.dart';
import '../blocs/invoice/invoice_state.dart';

class TelaItens extends StatefulWidget {
  const TelaItens({super.key});

  @override
  State<TelaItens> createState() => _TelaItensState();
}

class _TelaItensState extends State<TelaItens> {
  bool _showPaid = true;
  bool _showPending = true;

  @override
  void initState() {
    super.initState();
    _checkAuthentication();
    _loadInvoices();
  }

  void _checkAuthentication() {
    final authState = Provider.of<AuthState>(context, listen: false);
    if (!authState.isAuthenticated) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.go('/login');
      });
    }
  }

  void _loadInvoices() {
    context.read<InvoiceBloc>().add(LoadInvoices());
  }

  void _showAddEditInvoiceDialog({Invoice? invoice}) {
    showDialog(
      context: context,
      builder: (context) => InvoiceFormDialog(
        invoice: invoice,
        onSave: (updatedInvoice) {
          if (invoice == null) {
            context.read<InvoiceBloc>().add(AddInvoice(updatedInvoice));
          } else {
            context.read<InvoiceBloc>().add(UpdateInvoice(updatedInvoice));
          }
        },
      ),
    );
  }

  void _deleteInvoice(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Exclusão'),
        content: const Text('Deseja realmente excluir esta fatura?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      context.read<InvoiceBloc>().add(DeleteInvoice(id));
    }
  }

  @override
  Widget build(BuildContext context) {
    final userPreferences = context.watch<UserPreferences>();
    final headerStyle = _getTextStyle(context, userPreferences, true);
    final contentStyle = _getTextStyle(context, userPreferences, false);

    return TemplatePage(
      title: 'Gerenciar Faturas',
      routes: const {'/home': 'Voltar para Home'},
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEditInvoiceDialog(),
        backgroundColor: Constants.primaryColor,
        tooltip: 'Adicionar fatura',
        child: const Icon(Icons.add),
      ),
      body: BlocConsumer<InvoiceBloc, InvoiceState>(
        listener: (context, state) {
          if (state is InvoiceOperationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
              ),
            );
          } else if (state is InvoiceError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is InvoiceLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final invoices = state is InvoiceLoaded ? state.invoices : <Invoice>[];
          final filteredInvoices = invoices.where((invoice) {
            if (_showPaid && invoice.isPaid) return true;
            if (_showPending && !invoice.isPaid) return true;
            return false;
          }).toList();

          return Padding(
            padding: const EdgeInsets.all(Constants.defaultPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Faturas', style: headerStyle),
                    Row(
                      children: [
                        FilterChip(
                          label: const Text('Pagas'),
                          selected: _showPaid,
                          onSelected: (value) {
                            setState(() {
                              _showPaid = value;
                            });
                          },
                          selectedColor: Colors.green.withOpacity(0.2),
                        ),
                        const SizedBox(width: 8),
                        FilterChip(
                          label: const Text('Pendentes'),
                          selected: _showPending,
                          onSelected: (value) {
                            setState(() {
                              _showPending = value;
                            });
                          },
                          selectedColor: Colors.red.withOpacity(0.2),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: filteredInvoices.isEmpty
                      ? Center(
                          child: Text(
                            'Nenhuma fatura encontrada',
                            style: contentStyle.copyWith(color: Colors.grey),
                          ),
                        )
                      : ListView.builder(
                          itemCount: filteredInvoices.length,
                          itemBuilder: (context, index) {
                            final invoice = filteredInvoices[index];
                            return Card(
                              elevation: 2,
                              margin: const EdgeInsets.only(bottom: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(Constants.defaultBorderRadius),
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.all(16),
                                leading: CircleAvatar(
                                  backgroundColor: invoice.isPaid ? Colors.green : Colors.red,
                                  child: Icon(
                                    invoice.isPaid ? Icons.check : Icons.warning,
                                    color: Colors.white,
                                  ),
                                ),
                                title: Text(
                                  invoice.title,
                                  style: contentStyle.copyWith(fontWeight: FontWeight.bold),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Valor: R\$ ${invoice.amount.toStringAsFixed(2)}',
                                      style: contentStyle,
                                    ),
                                    Text(
                                      'Vencimento: ${_formatDate(invoice.dueDate)}',
                                      style: contentStyle.copyWith(color: Colors.grey),
                                    ),
                                  ],
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit),
                                      onPressed: () => _showAddEditInvoiceDialog(invoice: invoice),
                                      tooltip: 'Editar fatura',
                                      color: Constants.primaryColor,
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete),
                                      onPressed: () => _deleteInvoice(invoice.id),
                                      tooltip: 'Excluir fatura',
                                      color: Colors.red,
                                    ),
                                  ],
                                ),
                                onTap: () => context.push('/item-details', extra: invoice),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  String _formatDate(DateTime date) {
    final formatter = DateFormat('dd/MM/yyyy');
    return formatter.format(date);
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

// Classe de serviço movida para fora - pode ser criada como arquivo separado
class InvoiceService {
  Future<List<Invoice>> getInvoices() async {
    final prefs = await SharedPreferences.getInstance();
    final invoicesJson = prefs.getString('invoices');
    if (invoicesJson == null) return [];
    try {
      final List<dynamic> invoicesList = jsonDecode(invoicesJson);
      return invoicesList.map((json) => Invoice.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Erro ao carregar faturas: $e');
      return [];
    }
  }

  Future<void> addInvoice(Invoice invoice) async {
    final prefs = await SharedPreferences.getInstance();
    final invoices = await getInvoices();
    invoices.add(invoice);
    await prefs.setString('invoices', jsonEncode(invoices.map((i) => i.toJson()).toList()));
  }

  Future<void> updateInvoice(Invoice invoice) async {
    final prefs = await SharedPreferences.getInstance();
    final invoices = await getInvoices();
    final index = invoices.indexWhere((i) => i.id == invoice.id);
    if (index != -1) {
      invoices[index] = invoice;
      await prefs.setString('invoices', jsonEncode(invoices.map((i) => i.toJson()).toList()));
    }
  }

  Future<void> deleteInvoice(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final invoices = await getInvoices();
    invoices.removeWhere((i) => i.id == id);
    await prefs.setString('invoices', jsonEncode(invoices.map((i) => i.toJson()).toList()));
  }
}

class InvoiceFormDialog extends StatefulWidget {
  final Invoice? invoice;
  final Function(Invoice) onSave;

  const InvoiceFormDialog({super.key, this.invoice, required this.onSave});

  @override
  State<InvoiceFormDialog> createState() => _InvoiceFormDialogState();
}

class _InvoiceFormDialogState extends State<InvoiceFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  DateTime _dueDate = DateTime.now();
  bool _isPaid = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.invoice != null) {
      _titleController.text = widget.invoice!.title;
      _amountController.text = widget.invoice!.amount.toString();
      _descriptionController.text = widget.invoice!.description ?? '';
      _dueDate = widget.invoice!.dueDate;
      _isPaid = widget.invoice!.isPaid;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && mounted) {
      setState(() {
        _dueDate = picked;
      });
    }
  }

  Future<void> _saveInvoice() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final invoice = Invoice(
        id: widget.invoice?.id ?? const Uuid().v4(),
        title: _titleController.text.trim(),
        amount: double.parse(_amountController.text.replaceAll(',', '.')),
        dueDate: _dueDate,
        isPaid: _isPaid,
        description: _descriptionController.text.trim().isEmpty ? null : _descriptionController.text.trim(),
        createdAt: widget.invoice?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await widget.onSave(invoice);
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erro ao salvar fatura'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Constants.defaultBorderRadius)),
      child: Container(
        padding: const EdgeInsets.all(20),
        constraints: const BoxConstraints(maxWidth: 400),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(Constants.defaultBorderRadius),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.invoice == null ? 'Nova Fatura' : 'Editar Fatura',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Constants.primaryColor,
                  ),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    labelText: 'Título',
                    prefixIcon: const Icon(Icons.description),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    filled: true,
                    fillColor: Colors.grey[100],
                  ),
                  validator: Validators.validateName,
                ),
                const SizedBox(height: 15),
                TextFormField(
                  controller: _amountController,
                  decoration: InputDecoration(
                    labelText: 'Valor (R\$)',
                    prefixIcon: const Icon(Icons.attach_money),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    filled: true,
                    fillColor: Colors.grey[100],
                  ),
                  keyboardType: TextInputType.number,
                  validator: Validators.validateAmount,
                ),
                const SizedBox(height: 15),
                TextFormField(
                  controller: _descriptionController,
                  decoration: InputDecoration(
                    labelText: 'Descrição (opcional)',
                    prefixIcon: const Icon(Icons.note),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    filled: true,
                    fillColor: Colors.grey[100],
                  ),
                  maxLines: 3,
                  validator: Validators.validateDescription,
                ),
                const SizedBox(height: 15),
                InkWell(
                  onTap: _selectDate,
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: 'Data de Vencimento',
                      prefixIcon: const Icon(Icons.calendar_today),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      filled: true,
                      fillColor: Colors.grey[100],
                    ),
                    child: Text(
                      _formatDate(_dueDate),
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                SwitchListTile(
                  title: const Text('Pago'),
                  value: _isPaid,
                  onChanged: (value) {
                    setState(() {
                      _isPaid = value;
                    });
                  },
                  activeColor: Constants.primaryColor,
                  contentPadding: EdgeInsets.zero,
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: _isLoading ? null : () => Navigator.pop(context),
                      child: const Text('Cancelar'),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _saveInvoice,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Constants.primaryColor,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('Salvar', style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final formatter = DateFormat('dd/MM/yyyy');
    return formatter.format(date);
  }
}