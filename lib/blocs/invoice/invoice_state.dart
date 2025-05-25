import 'package:broke_club/models/invoice.dart';

abstract class InvoiceState {}

class InvoiceInitial extends InvoiceState {}

class InvoiceLoading extends InvoiceState {}

class InvoiceLoaded extends InvoiceState {
  final List<Invoice> invoices;
  InvoiceLoaded(this.invoices);
}

class InvoiceOperationSuccess extends InvoiceState {
  final String message;
  final List<Invoice> invoices;
  InvoiceOperationSuccess(this.message, this.invoices);
}

class InvoiceError extends InvoiceState {
  final String message;
  InvoiceError(this.message);
}