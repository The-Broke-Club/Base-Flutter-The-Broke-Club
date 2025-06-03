import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'pages/Tela_Login.dart';
import 'pages/Tela_Home.dart';
import 'pages/Tela_Settings.dart'; // Importação do arquivo correto
import 'pages/Tela_Profile.dart';
import 'pages/Tela_Itens.dart';
import 'models/auth_state.dart';
import 'services/auth_service.dart';
import 'repositories/auth_repository.dart';
import 'blocs/login/login_bloc.dart';
import 'blocs/invoice/invoice_bloc.dart';
import 'models/user.dart';
import 'models/item_data.dart';
import 'models/invoice.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
          providers: [
        ChangeNotifierProvider(create: (context) => AuthService()),
        ChangeNotifierProvider(create: (context) => AuthState(context)),
        ChangeNotifierProvider(create: (context) => UserPreferences()),
        Provider(create: (context) => AuthRepository(context.read<AuthService>())),
      ],
          child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => LoginBloc(context.read<AuthRepository>()),
          ),
          BlocProvider(
            create: (context) => InvoiceBloc(),
          ),
        ],
        child: MaterialApp.router(
          title: 'The Broke Club',
          theme: ThemeData(
            primarySwatch: Colors.blue,
            visualDensity: VisualDensity.adaptivePlatformDensity,
          ),
          routerConfig: _router,
          debugShowCheckedModeBanner: false,
        ),
      ),
    );
  }
}

final GoRouter _router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const LoginPage(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginPage(),
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) {
        final authState = Provider.of<AuthState>(context, listen: false);
        final user = authState.user ?? User.createSample();
        final recentItems = ItemData.generateSampleItems();
        return HomePage(
          user: user,
          recentItems: recentItems,
        );
      },
    ),
    GoRoute(
      path: '/profile',
      builder: (context, state) {
        final authState = Provider.of<AuthState>(context, listen: false);
        final user = state.extra as User? ?? authState.user ?? User.createSample();
        return UserProfilePage(user: user);
      },
    ),
    GoRoute(
      path: '/invoices',
      builder: (context, state) => const TelaItens(),
    ),
    // GoRoute(
    //   path: '/edit-profile',
    //   builder: (context, state) {
    //     final authState = Provider.of<AuthState>(context, listen: false);
    //     final user = state.extra as User? ?? authState.user ?? User.createSample();
    //     return EditProfilePage(user: user);
    //   },
    // ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsPage(), // Agora usa a classe do arquivo Tela_Settings.dart
    ),
    GoRoute(
      path: '/item-details',
      builder: (context, state) {
        final item = state.extra as ItemData?;
        final invoice = state.extra as Invoice?;
        return ItemDetailsPage(item: item, invoice: invoice);
      },
    ),
  ],
  redirect: (context, state) {
    final authState = Provider.of<AuthState>(context, listen: false);
    final isLoggedIn = authState.isAuthenticated;
    final isOnLoginPage = state.matchedLocation == '/login' || state.matchedLocation == '/';

    if (!isLoggedIn && !isOnLoginPage) {
      return '/login';
    }
    if (isLoggedIn && isOnLoginPage) {
      return '/home';
    }
    return null;
  },
  errorBuilder: (context, state) => Scaffold(
    appBar: AppBar(title: const Text('Erro')),
    body: Center(child: Text('Página não encontrada: ${state.uri}')),
  ),
);

class ItemDetailsPage extends StatelessWidget {
  final ItemData? item;
  final Invoice? invoice;

  const ItemDetailsPage({super.key, this.item, this.invoice});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(item != null ? 'Detalhes do Item' : invoice != null ? 'Detalhes da Fatura' : 'Erro'),
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
      ),
      body: Center(
        child: item != null
            ? Text(
                'Detalhes de ${item!.name}',
                style: Theme.of(context).textTheme.bodyLarge,
                semanticsLabel: 'Detalhes do item ${item!.name}',
              )
            : invoice != null
                ? Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Fatura: ${invoice!.title}',
                              style: Theme.of(context).textTheme.headlineSmall,
                              semanticsLabel: 'Título da fatura',
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Valor: R\$ ${invoice!.amount.toStringAsFixed(2)}',
                              style: Theme.of(context).textTheme.bodyLarge,
                              semanticsLabel: 'Valor da fatura',
                            ),
                            Text(
                              'Vencimento: ${_formatDate(invoice!.dueDate)}',
                              style: Theme.of(context).textTheme.bodyLarge,
                              semanticsLabel: 'Data de vencimento da fatura',
                            ),
                            Text(
                              'Status: ${invoice!.isPaid ? "Pago" : "Pendente"}',
                              style: Theme.of(context).textTheme.bodyLarge,
                              semanticsLabel: 'Status da fatura',
                            ),
                            if (invoice!.description != null) ...[
                              const SizedBox(height: 8),
                              Text(
                                'Descrição: ${invoice!.description}',
                                style: Theme.of(context).textTheme.bodyLarge,
                                semanticsLabel: 'Descrição da fatura',
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  )
                : const Text(
                    'Nenhum item ou fatura selecionado',
                    semanticsLabel: 'Nenhum item ou fatura selecionado',
                  ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final formatter = DateFormat('dd/MM/yyyy');
    return formatter.format(date);
  }
}