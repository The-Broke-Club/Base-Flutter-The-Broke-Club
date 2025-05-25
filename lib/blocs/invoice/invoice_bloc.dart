import 'package:flutter_bloc/flutter_bloc.dart';
import 'invoice_event.dart';
import 'invoice_state.dart';
import '../../services/invoice_service.dart';

class InvoiceBloc extends Bloc<InvoiceEvent, InvoiceState> {
  final InvoiceService _invoiceService = InvoiceService();
  
  InvoiceBloc() : super(InvoiceInitial()) {
    on<LoadInvoices>(_onLoadInvoices);
    on<AddInvoice>(_onAddInvoice);
    on<UpdateInvoice>(_onUpdateInvoice);
    on<DeleteInvoice>(_onDeleteInvoice);
  }

  // Handler para carregar invoices
  void _onLoadInvoices(LoadInvoices event, Emitter<InvoiceState> emit) async {
    emit(InvoiceLoading());
    try {
      // Ajuste o nome do método conforme sua implementação no InvoiceService
      final invoices = await _invoiceService.getInvoices(); // ou getAll() ou list()
      emit(InvoiceLoaded(invoices));
    } catch (error) {
      emit(InvoiceError('Erro ao carregar faturas: ${error.toString()}'));
    }
  }

  // Handler para adicionar invoice
  void _onAddInvoice(AddInvoice event, Emitter<InvoiceState> emit) async {
    emit(InvoiceLoading());
    try {
      await _invoiceService.addInvoice(event.invoice);
      final invoices = await _invoiceService.getInvoices(); // ou getAll() ou list()
      emit(InvoiceLoaded(invoices));
    } catch (error) {
      emit(InvoiceError('Erro ao adicionar fatura: ${error.toString()}'));
    }
  }

  // Handler para atualizar invoice
  void _onUpdateInvoice(UpdateInvoice event, Emitter<InvoiceState> emit) async {
    emit(InvoiceLoading());
    try {
      await _invoiceService.updateInvoice(event.invoice);
      final invoices = await _invoiceService.getInvoices(); // ou getAll() ou list()
      emit(InvoiceLoaded(invoices));
    } catch (error) {
      emit(InvoiceError('Erro ao atualizar fatura: ${error.toString()}'));
    }
  }

  // Handler para deletar invoice
  void _onDeleteInvoice(DeleteInvoice event, Emitter<InvoiceState> emit) async {
    emit(InvoiceLoading());
    try {
      await _invoiceService.deleteInvoice(event.invoiceId);
      final invoices = await _invoiceService.getInvoices(); // ou getAll() ou list()
      emit(InvoiceLoaded(invoices));
    } catch (error) {
      emit(InvoiceError('Erro ao deletar fatura: ${error.toString()}'));
    }
  }

  // Fechar o banco de dados quando o bloc for fechado
  @override
  Future<void> close() async {
    await _invoiceService.close();
    return super.close();
  }
}