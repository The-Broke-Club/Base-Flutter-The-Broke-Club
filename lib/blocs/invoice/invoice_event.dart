import 'package:broke_club/models/invoice.dart';

abstract class InvoiceEvent {}

class LoadInvoices extends InvoiceEvent {}

class AddInvoice extends InvoiceEvent {
  final Invoice invoice;
  AddInvoice(this.invoice);
}

class UpdateInvoice extends InvoiceEvent {
  final Invoice invoice;
  UpdateInvoice(this.invoice);
}

class DeleteInvoice extends InvoiceEvent {
  final String invoiceId;
  DeleteInvoice(this.invoiceId);
}
