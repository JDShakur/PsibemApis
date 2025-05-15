import 'package:flutter/material.dart';

class TermsOfUseContent extends StatelessWidget {
  const TermsOfUseContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text('1. INTRODUÇÃO\n\n'
                      'Bem-vindo ao PsiBem! Sua privacidade é uma prioridade para nós. Este documento explica como coletamos, usamos, armazenamos e protegemos suas informações ao utilizar nosso aplicativo\n'
                      'ao se cadastrar e utilizar o PsiBem Mental, você concorda com os termos descritos aqui. Se tiver dúvidas, entre em contato conosco pelo e-mail psibemtcc@gmail.com.\n'
                      '\n'
                      '2. DADOS COLETADOS\n'
                      'Coletamos os seguintes tipos de informações:\n'
                      '\n'
                      '2.1. Informações Fornecidas pelo Usuário\n'
                      'Nome completo\n'
                      'Endereço de e-mail\n'
                      'Número de telefone \n'
                      'Informações de pagamento (para planos pagos)\n'
                      'Dados profissionais (para psicólogos, como CRP e especializações)\n'
                      '\n'
                      '2.2. Informações Coletadas Automaticamente\n'
                      'Endereço IP e informações do dispositivo\n'
                      'Registros de acesso e uso do aplicativo\n'
                      'Cookies e tecnologias similares para melhorar a experiência do usuário\n'
                      '\n'
                      '2.3. Informações Sensíveis\n'
                      'Nosso aplicativo pode armazenar informações sobre seu bem-estar emocional. Essas informações são tratadas com sigilo e proteção reforçada.\n'
                      '\n'
                      '3. COMO UTILIZAMOS SEUS DADOS\n'
                      'Usamos suas informações para:\n'
                      'Fornecer e melhorar nossos serviços\n'
                      'Processar pagamentos e gerenciar assinaturas\n'
                      'Garantir a segurança da plataforma\n'
                      'Enviar comunicações e notificações importantes\n'
                      'Cumprir obrigações legais\n'
                      '\n'
                      '4. COMPARTILHAMENTO DE DADOS\n'
                      'Não vendemos nem compartilhamos seus dados com terceiros, exceto:\n'
                      'Quando exigido por lei\n'
                      'Para processadores de pagamento confiáveis\n'
                      'Para melhoria dos serviços (exemplo: analytics)\n'
                      '\n'
                      '5. SEGURANÇA DOS DADOS\n'
                      'Adotamos medidas técnicas e organizacionais para proteger suas informações contra acessos não autorizados, perda ou alteração.\n'
                      '\n'
                      '6. SEUS DIREITOS\n'
                      'Você pode:\n'
                      'Acessar seus dados armazenados\n'
                      'Solicitar a correção ou exclusão de informações\n'
                      'Revogar consentimentos para uso de dados\n'
                      'Para exercer seus direitos, entre em contato pelo e-mail psibemtcc@gmail.com.\n'
                      '\n'
                      '7. RETENÇÃO DE DADOS\n'
                      'Armazenamos seus dados enquanto sua conta estiver ativa. Caso solicite a exclusão, removeremos suas informações conforme obrigações legais e regulatórias.\n'
                      '\n'
                      '8. ALTERAÇÕES NESTA POLÍTICA\n'
                      'Podemos atualizar esta política periodicamente. Notificaremos você sobre mudanças significativas por e-mail ou dentro do aplicativo.\n'
                      '\n'
                      '9. CONTATO\n'
                      'Se tiver dúvidas ou preocupações sobre a privacidade dos seus dados, fale conosco pelo e-mail [email de contato].\n'
                      'Ao utilizar o PsiBem Mental, você confirma que leu e concorda com estes Termos de Privacidade.\n'),
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Fechar'),
          ),
        ),
      ],
    );
  }
}
