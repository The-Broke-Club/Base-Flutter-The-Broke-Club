class Validators {
  // Valida um endereço de email
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor, insira um email';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Por favor, insira um email válido';
    }
    return null;
  }

  // Valida uma senha
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor, insira uma senha';
    }
    // Alterado temporariamente de 6 para 4 caracteres para facilitar testes
    if (value.length < 4) {
      return 'A senha deve ter pelo menos 4 caracteres';
    }
    return null;
  }

  // Valida um nome (ex.: nome do usuário ou título de um item financeiro)
  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor, insira um nome';
    }
    if (value.length < 2) {
      return 'O nome deve ter pelo menos 2 caracteres';
    }
    return null;
  }

  // Valida um valor monetário (ex.: para itens financeiros)
  static String? validateAmount(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor, insira um valor';
    }
    final amount = double.tryParse(value.replaceAll(',', '.'));
    if (amount == null) {
      return 'Por favor, insira um valor numérico válido';
    }
    if (amount <= 0) {
      return 'O valor deve ser maior que zero';
    }
    return null;
  }

  // Valida uma descrição (opcional, para itens financeiros)
  static String? validateDescription(String? value) {
    if (value != null && value.length > 500) {
      return 'A descrição não pode exceder 500 caracteres';
    }
    return null;
  }
}