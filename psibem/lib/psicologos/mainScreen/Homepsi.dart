import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:psibem/widget/atendimento_psicologo.dart';
import 'package:psibem/widget/materiais_page.dart';

class HomePagePsicologo extends StatefulWidget {
  const HomePagePsicologo({super.key});

  @override
  _HomePagePsicologoState createState() => _HomePagePsicologoState();
}

class _HomePagePsicologoState extends State<HomePagePsicologo> {
  String userName = "";
  final List<String> materiaisDeApoio = [
    "Guia de Ansiedade",
    "Exercícios de Mindfulness",
    "Questionário de Depressão"
  ];

  List<Atendimento> atendimentos = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _recuperarNomeUsuario();
    _carregarAtendimentos();
  }

 Future<void> _carregarAtendimentos() async {
  try {
    print('Iniciando carregamento de atendimentos...');
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      print('Usuário logado: ${user.uid}');
      
      final querySnapshot = await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(user.uid)
          .collection('atendimentos')
          .orderBy('dataHora')
          .get();

      print('Total de atendimentos encontrados: ${querySnapshot.docs.length}');
      
      setState(() {
        atendimentos = querySnapshot.docs.map((doc) {
          print('Processando doc: ${doc.id}');
          return Atendimento.fromMap(doc.data(), doc.id);
        }).toList();
        isLoading = false;
      });
    } else {
      print('Nenhum usuário logado');
      setState(() {
        isLoading = false;
      });
    }
  } catch (e, stackTrace) {
    print("Erro ao carregar atendimentos: $e");
    print("Stack trace: $stackTrace");
    setState(() {
      isLoading = false;
    });
  }
}

  Future<void> _recuperarNomeUsuario() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('usuarios')
            .doc(user.uid)
            .get();
        if (userDoc.exists) {
          String nomeUsuario = userDoc['apelido'] ?? 'Usuário';

          setState(() {
            userName = nomeUsuario;
          });
        } else {
          setState(() {
            userName = 'Usuário';
          });
        }
      } else {
        setState(() {
          userName = 'Usuário';
        });
      }
    } catch (e) {
      print("Erro ao recuperar nome do usuário: $e");
      setState(() {
        userName = 'Usuário';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF6F9FC),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Olá, $userName!',
                  style: TextStyle(
                    fontFamily: 'Roboto',
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal,
                  ),
                ),
                Text(
                  'Como podemos te ajudar hoje?',
                  style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                      fontFamily: 'Roboto'),
                ),
                SizedBox(height: 20),
                _buildCardAtendimentos(),
                SizedBox(height: 20),
                Text('Recomendações',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Roboto')),
                SizedBox(height: 12),
                _buildCardAnexos(),
                SizedBox(height: 20),
                _buildRecommendationCard(context, 'Ver histórico de sessões',
                    'Acompanhe as sessões dos pacientes.', '/historico'),
                SizedBox(height: 12),
                _buildRecommendationCard(
                    context,
                    'Materiais de apoio',
                    'Envie e organize materiais para seus pacientes.',
                    '/materiais'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCardAtendimentos() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.teal[100],
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Próximos atendimentos',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Roboto',
                ),
              ),
              IconButton(
                icon: Icon(Icons.add, color: Colors.teal),
                onPressed: () => _mostrarDialogoAdicionarAtendimento(context),
              ),
            ],
          ),
          SizedBox(height: 8),
          if (isLoading)
            Center(child: CircularProgressIndicator())
          else if (atendimentos.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Center(
                child: Text(
                  'Nenhum atendimento agendado',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ),
            )
          else
            ...atendimentos.map((atendimento) {
              return ListTile(
                leading: Icon(Icons.person, color: Colors.teal),
                title: Text(atendimento.paciente),
                subtitle: Text(
                  DateFormat('dd/MM/yyyy - HH:mm').format(atendimento.dataHora),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.delete, color: Colors.red[300]),
                      onPressed: () =>
                          _confirmarExclusaoAtendimento(atendimento.id),
                    ),
                    Icon(Icons.arrow_forward_ios, color: Colors.teal, size: 16),
                  ],
                ),
                onTap: () {
                  showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: Text("Observações"),
                content: Text(atendimento.observacoes ?? "Nenhuma observação"),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text("OK"),
                  ),
                ],
              ),
            );
                },
              );
            }).toList(),
        ],
      ),
    );
  }

  Future<void> _mostrarDialogoAdicionarAtendimento(BuildContext context) async {
    final formKey = GlobalKey<FormState>();
    String paciente = '';
    DateTime dataHora = DateTime.now();
    String? observacoes;

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Adicionar Atendimento'),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Paciente'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Informe o nome do paciente';
                      }
                      return null;
                    },
                    onSaved: (value) => paciente = value!,
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    child: Text(
                      'Selecionar Data e Hora: ${DateFormat('dd/MM/yyyy - HH:mm').format(dataHora)}',
                    ),
                    onPressed: () async {
                      final DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: dataHora,
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2100),
                      );
                      if (pickedDate != null) {
                        final TimeOfDay? pickedTime = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.fromDateTime(dataHora),
                        );
                        if (pickedTime != null) {
                          setState(() {
                            dataHora = DateTime(
                              pickedDate.year,
                              pickedDate.month,
                              pickedDate.day,
                              pickedTime.hour,
                              pickedTime.minute,
                            );
                          });
                        }
                      }
                    },
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    decoration:
                        InputDecoration(labelText: 'Observações (opcional)'),
                    maxLines: 3,
                    onSaved: (value) => observacoes = value,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancelar'),
            ),
           ElevatedButton(
  onPressed: () async {
    try {
      // Verifica se o formKey está associado ao formulário
      if (formKey.currentState == null) {
        print('Erro: formKey não está associado a um Form');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro interno no formulário')),
        );
        return;
      }

      // Valida o formulário
      if (formKey.currentState!.validate()) {
        // Salva os dados do formulário
        formKey.currentState!.save();
        
        print('Dados do formulário:');
        print('Paciente: $paciente');
        print('Data/Hora: $dataHora');
        print('Observações: $observacoes');

        // Tenta adicionar o atendimento
        await _adicionarAtendimento(paciente, dataHora, observacoes);
        
        // Fecha o diálogo apenas se tudo der certo
        if (mounted) {
          Navigator.pop(context);
        }
      }
    } catch (e, stackTrace) {
      print('Erro ao salvar atendimento: $e');
      print('Stack trace: $stackTrace');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao salvar: ${e.toString()}')),
        );
      }
    }
  },
  child: Text('Salvar'),
),
          ],
        );
      },
    );
  }

  Future<void> _adicionarAtendimento(String paciente, DateTime dataHora, String? observacoes) async {
  try {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // Verifica se o usuário existe na coleção 'usuarios'
      final userDoc = await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(user.uid)
          .get();

      if (!userDoc.exists) {
        // Se o documento do usuário não existe, cria um básico
        await FirebaseFirestore.instance
            .collection('usuarios')
            .doc(user.uid)
            .set({'apelido': 'Psicólogo'});
      }

      // Adiciona o atendimento
      final docRef = await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(user.uid)
          .collection('atendimentos')
          .add({
            'paciente': paciente,
            'dataHora': Timestamp.fromDate(dataHora),
            'observacoes': observacoes,
          });

      print('Atendimento adicionado com ID: ${docRef.id}');
      
      await _carregarAtendimentos();
    } else {
      print('Usuário não autenticado');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Usuário não autenticado')),
      );
    }
  } catch (e) {
    print("Erro detalhado ao adicionar atendimento: $e");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Erro ao adicionar: ${e.toString()}')),
    );
  }
}

  Future<void> _confirmarExclusaoAtendimento(String id) async {
    bool confirmado = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirmar exclusão'),
        content: Text('Deseja realmente excluir este atendimento?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Excluir', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmado == true) {
      await _excluirAtendimento(id);
    }
  }

  Future<void> _excluirAtendimento(String id) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance
            .collection('usuarios')
            .doc(user.uid)
            .collection('atendimentos')
            .doc(id)
            .delete();

        await _carregarAtendimentos(); // Recarrega a lista
      }
    } catch (e) {
      print("Erro ao excluir atendimento: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao excluir atendimento')),
      );
    }
  }

  Widget _buildCardAnexos() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.teal[50],
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Arquivos compartilhados',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              fontFamily: 'Roboto',
            ),
          ),
          SizedBox(height: 8),
          Row(
            children: [
              ElevatedButton.icon(
                onPressed: () {},
                icon: Icon(Icons.upload_file),
                label: Text('Enviar arquivo'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationCard(
      BuildContext context, String title, String subtitle, String route) {
    return GestureDetector(
      onTap: () {
        if (route == '/materiais') {
          // Verifica se há materiais
          if (materiaisDeApoio.isEmpty) {
            // Mostra o popup se não houver materiais
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: Text("Materiais de Apoio"),
                content: Text("Nenhum material disponível por enquanto."),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text("OK"),
                  ),
                ],
              ),
            );
          } else {
            // Navega para a tela de materiais se houver
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    MateriaisPage(materiais: materiaisDeApoio),
              ),
            );
          }
        } else {
          Navigator.pushNamed(context, route);
        }
      },
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.teal[100],
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 6,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                        fontSize: 16,
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 4),
                  Text(subtitle, style: TextStyle(color: Colors.grey[800])),
                ],
              ),
            ),
            Icon(Icons.arrow_forward, color: Colors.teal),
          ],
        ),
      ),
    );
  }
}
