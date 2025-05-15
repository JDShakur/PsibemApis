import 'package:flutter/material.dart';
import 'package:psibem/usuarios/views/moodtracker/monitoramento_page.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class Calendario extends StatefulWidget {
  const Calendario({super.key});

  @override
  _CalendarioState createState() => _CalendarioState();
}

class _CalendarioState extends State<Calendario> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  final Map<DateTime, String> _moods = {};
  final Map<DateTime, String> _autoestima = {};
  List<Map<String, dynamic>> emocoesPersonalizadas = [];

  final Map<String, Color> _emojiColors = {
    '😊': const Color.fromARGB(255, 255, 251, 215),
    '😢': const Color.fromARGB(255, 133, 172, 204),
    '😡': Colors.red,
    '😴': const Color.fromARGB(255, 244, 210, 250),
    '😐': Colors.grey,
    '😰': const Color.fromARGB(255, 240, 187, 107),
    '😍': const Color.fromARGB(255, 255, 149, 184),
    '🤔': Colors.teal,
    '🤯': const Color.fromARGB(255, 196, 108, 82),
    '🥳': const Color.fromARGB(255, 168, 255, 171),
  };

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('pt_BR');
    _carregarDados();
  }

  Future<void> _carregarDados() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Carrega emoções personalizadas
      final emocoesJson = prefs.getString('emocoes_personalizadas');
      if (emocoesJson != null) {
        setState(() {
          emocoesPersonalizadas = List<Map<String, dynamic>>.from(
            jsonDecode(emocoesJson),
          );
        });
      }

      // Carrega humores
      final humoresJson = prefs.getString('humores');
      if (humoresJson != null) {
        final Map<String, dynamic> humoresMap = jsonDecode(humoresJson);
        setState(() {
          _moods.clear();
          humoresMap.forEach((key, value) {
            _moods[DateTime.parse(key)] = value.toString();
          });
        });
      }

      // Carrega autoestima
      final autoestimaJson = prefs.getString('autoestima');
      if (autoestimaJson != null) {
        final Map<String, dynamic> autoestimaMap = jsonDecode(autoestimaJson);
        setState(() {
          _autoestima.clear();
          autoestimaMap.forEach((key, value) {
            _autoestima[DateTime.parse(key)] = value.toString();
          });
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao carregar dados: $e')),
      );
    }
  }

  Future<void> _salvarDados() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Salva emoções personalizadas
      await prefs.setString(
          'emocoes_personalizadas', jsonEncode(emocoesPersonalizadas));

      // Salva humores
      final humoresMap = <String, String>{};
      _moods.forEach((key, value) {
        humoresMap[key.toString()] = value;
      });
      await prefs.setString('humores', jsonEncode(humoresMap));

      // Salva autoestima
      final autoestimaMap = <String, String>{};
      _autoestima.forEach((key, value) {
        autoestimaMap[key.toString()] = value;
      });
      await prefs.setString('autoestima', jsonEncode(autoestimaMap));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao salvar dados: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F9FC),
      appBar: AppBar(
        backgroundColor: const Color(0xFF81C7C6),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        elevation: 0,
      ),
      body: Stack(
        children: [
          Positioned(
            top: -50,
            left: 0,
            right: 0,
            child: Container(
              width: 397,
              height: 200,
              clipBehavior: Clip.antiAlias,
              decoration: ShapeDecoration(
                color: const Color(0xFF81C7C6),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                shadows: const [
                  BoxShadow(
                    color: Color(0x4C000000),
                    blurRadius: 3,
                    offset: Offset(0, 1),
                    spreadRadius: 0,
                  ),
                  BoxShadow(
                    color: Color(0x26000000),
                    blurRadius: 8,
                    offset: Offset(0, 4),
                    spreadRadius: 3,
                  ),
                ],
              ),
              child: const Center(
                child: Padding(
                  padding: EdgeInsets.only(top: 40.0),
                  child: Text(
                    "Olá! Como está se sentindo hoje?",
                    style: TextStyle(
                      fontSize: 28,
                      fontFamily: 'HelveticaNeue',
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 70),
            child: Column(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(50),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 10,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: TableCalendar(
                        locale: 'pt_BR',
                        firstDay: DateTime.utc(2020, 1, 1),
                        lastDay: DateTime.utc(2030, 12, 31),
                        focusedDay: _focusedDay,
                        calendarFormat: _calendarFormat,
                        availableCalendarFormats: const {
                          CalendarFormat.month: 'Mês',
                        },
                        headerStyle: const HeaderStyle(
                          formatButtonVisible: false,
                          titleCentered: true,
                          titleTextStyle: TextStyle(
                            fontSize: 20,
                            fontFamily: 'HelveticaNeue',
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF208584),
                          ),
                          leftChevronIcon: Icon(
                            Icons.chevron_left,
                            color: Color(0xFF208584),
                          ),
                          rightChevronIcon: Icon(
                            Icons.chevron_right,
                            color: Color(0xFF208584),
                          ),
                        ),
                        startingDayOfWeek: StartingDayOfWeek.monday,
                        selectedDayPredicate: (day) =>
                            isSameDay(_selectedDay, day),
                        onDaySelected: (selectedDay, focusedDay) {
                          setState(() {
                            _selectedDay = selectedDay;
                            _focusedDay = focusedDay;
                          });

                          // Verifica se o dia selecionado é o dia atual
                          if (isSameDay(selectedDay, DateTime.now())) {
                            _showMoodDialog(selectedDay);
                          } else {
                            // Mostra apenas os dados salvos para dias passados
                            _showMoodViewDialog(selectedDay);
                          }
                        },
                        onFormatChanged: (format) {
                          setState(() {
                            _calendarFormat = format;
                          });
                        },
                        onPageChanged: (focusedDay) {
                          _focusedDay = focusedDay;
                        },
                        calendarStyle: const CalendarStyle(
                          todayTextStyle: TextStyle(
                            fontSize: 18,
                            fontFamily: 'HelveticaNeue',
                            color: Colors.white,
                          ),
                          todayDecoration: BoxDecoration(
                            color: Color(0xFF81C7C6),
                            shape: BoxShape.circle,
                          ),
                          selectedTextStyle: TextStyle(
                            fontSize: 18,
                            fontFamily: 'HelveticaNeue',
                            color: Colors.white,
                          ),
                          selectedDecoration: BoxDecoration(
                            color: Color(0xFF208584),
                            shape: BoxShape.circle,
                          ),
                          weekendTextStyle: TextStyle(
                            fontSize: 18,
                            fontFamily: 'HelveticaNeue',
                            color: Color.fromARGB(255, 255, 192, 187),
                          ),
                          defaultTextStyle: TextStyle(
                            fontSize: 18,
                            fontFamily: 'HelveticaNeue',
                            color: Colors.black,
                          ),
                          outsideTextStyle: TextStyle(
                            fontSize: 18,
                            fontFamily: 'HelveticaNeue',
                            color: Colors.grey,
                          ),
                          cellMargin: EdgeInsets.all(10),
                        ),
                        daysOfWeekStyle: const DaysOfWeekStyle(
                          weekdayStyle: TextStyle(
                            fontSize: 10,
                            fontFamily: 'HelveticaNeue',
                            color: Colors.black,
                          ),
                          weekendStyle: TextStyle(
                            fontSize: 10,
                            fontFamily: 'HelveticaNeue',
                            color: Color.fromARGB(255, 255, 192, 187),
                          ),
                        ),
                        calendarBuilders: CalendarBuilders(
                          defaultBuilder: (context, day, focusedDay) {
                            final mood = _moods[day];
                            if (mood != null) {
                              return Center(
                                child: Text(
                                  mood.split(' ')[0],
                                  style: const TextStyle(fontSize: 18),
                                ),
                              );
                            }
                            return Center(
                              child: Text(
                                day.day.toString(),
                                style: const TextStyle(fontSize: 18),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 20.0),
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MonitoramentoPage(
                            moods: _moods,
                            autoestima: _autoestima,
                            emocoesPersonalizadas: emocoesPersonalizadas,
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(55),
                      ),
                    ),
                    child: const Icon(
                      Icons.bar_chart,
                      size: 50,
                      color: Color(0xFF81C7C6),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showMoodDialog(DateTime day) {
    String? selectedMood = _moods[day];
    String? selectedAutoestima = _autoestima[day];

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              contentPadding: const EdgeInsets.only(
                  top: 20, left: 20, right: 20, bottom: 10),
              content: Stack(
                children: [
                  Positioned(
                    top: 0,
                    right: 0,
                    child: IconButton(
                      icon: const Icon(Icons.close, color: Color(0xFF208584)),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  SizedBox(
                    width: 250,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Qual seu mood hoje?',
                          style: TextStyle(
                            fontSize: 18,
                            fontFamily: 'HelveticaNeue',
                            color: Color(0xFF208584),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 20),
                        _buildMoodDropdown(selectedMood, (newValue) {
                          if (newValue == 'adicionar_novo_humor') {
                            _mostrarDialogoEmocao(context: context)
                                .then((novaEmocao) {
                              if (novaEmocao != null) {
                                setState(() {
                                  emocoesPersonalizadas.add(novaEmocao);
                                  _salvarDados();
                                });
                              }
                            });
                          } else {
                            setState(() => selectedMood = newValue);
                          }
                        }),
                        const SizedBox(height: 20),
                        _buildAutoestimaDropdown(selectedAutoestima,
                            (newValue) {
                          setState(() => selectedAutoestima = newValue);
                        }),
                      ],
                    ),
                  ),
                ],
              ),
              actions: [
                ElevatedButton(
                  onPressed: () async {
                    if (selectedMood != null || selectedAutoestima != null) {
                      setState(() {
                        if (selectedMood != null) _moods[day] = selectedMood!;
                        if (selectedAutoestima != null) {
                          _autoestima[day] = selectedAutoestima!;
                        }
                      });
                      Navigator.pop(context);
                      await _salvarDados();
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Selecione pelo menos uma opção.'),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF208584),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 30,
                      vertical: 15,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Salvar',
                    style: TextStyle(
                      fontSize: 16,
                      fontFamily: 'HelveticaNeue',
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showMoodViewDialog(DateTime day) {
    final mood = _moods[day];
    final autoestima = _autoestima[day];

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          contentPadding:
              const EdgeInsets.only(top: 20, left: 20, right: 20, bottom: 10),
          content: Stack(
            children: [
              Positioned(
                top: 0,
                right: 0,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Color(0xFF208584)),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              SizedBox(
                width: 250,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Seu mood em ${day.day}/${day.month}/${day.year}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontFamily: 'HelveticaNeue',
                        color: Color(0xFF208584),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    if (mood != null)
                      Text(
                        'Humor: $mood',
                        style: const TextStyle(fontSize: 16),
                      ),
                    if (autoestima != null)
                      Text(
                        'Autoestima: $autoestima',
                        style: const TextStyle(fontSize: 16),
                      ),
                    if (mood == null && autoestima == null)
                      const Text(
                        'Nenhum dado registrado para este dia',
                        style: TextStyle(fontSize: 16),
                      ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF208584),
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 15,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Fechar',
                style: TextStyle(
                  fontSize: 16,
                  fontFamily: 'HelveticaNeue',
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildMoodDropdown(String? selectedMood, Function(String?) onChanged) {
    return DropdownButton<String>(
      value: selectedMood,
      hint: const Text('Escolha seu mood'),
      onChanged: onChanged,
      items: _buildMoodDropdownItems(),
      selectedItemBuilder: (context) {
        return _buildMoodDropdownItems().map((item) {
          return Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              item.value!,
              style: TextStyle(
                color: _emojiColors[item.value!.split(' ')[0]] ?? Colors.black,
              ),
            ),
          );
        }).toList();
      },
    );
  }

  List<DropdownMenuItem<String>> _buildMoodDropdownItems() {
    return [
      ...emocoesPersonalizadas.map((emocao) {
        return DropdownMenuItem(
          value: '${emocao['emoji']} ${emocao['humor']}',
          child: Dismissible(
            key: Key(emocao['humor']),
            direction: DismissDirection.endToStart,
            background: Container(
              color: const Color.fromARGB(255, 253, 226, 224),
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 20),
              child: const Icon(Icons.delete, color: Colors.white),
            ),
            onDismissed: (direction) {
              _removerEmocao(emocao);
            },
            child: Row(
              children: [
                Text('${emocao['emoji']} ${emocao['humor']}'),
                const Spacer(),
                IconButton(
                  icon: const Icon(
                    Icons.edit,
                    color: Color.fromARGB(255, 155, 156, 156),
                  ),
                  onPressed: () => _editarEmocao(emocao),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Color(0xFF208584)),
                  onPressed: () => _removerEmocao(emocao),
                ),
              ],
            ),
          ),
        );
      }),
      DropdownMenuItem(
        value: 'adicionar_novo_humor',
        enabled: emocoesPersonalizadas.length < 5,
        child: Text(
          '+ Adicionar novo humor',
          style: TextStyle(
            color: emocoesPersonalizadas.length >= 5
                ? Colors.grey
                : const Color(0xFF208584),
          ),
        ),
      ),
    ];
  }

  Widget _buildAutoestimaDropdown(
    String? selectedAutoestima,
    Function(String?) onChanged,
  ) {
    return DropdownButton<String>(
      value: selectedAutoestima,
      hint: const Text('Escolha sua autoestima'),
      onChanged: onChanged,
      items: <String>['Alta', 'Média', 'Baixa'].map((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
    );
  }

  Future<Map<String, dynamic>?> _mostrarDialogoEmocao({
    BuildContext? context,
    String? initialHumor,
    String? initialEmoji,
  }) async {
    final TextEditingController controller = TextEditingController(
      text: initialHumor,
    );
    String? emojiSelecionado = initialEmoji;

    return showDialog<Map<String, dynamic>>(
      context: context!,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              contentPadding: const EdgeInsets.only(
                top: 20,
                left: 20,
                right: 20,
                bottom: 10,
              ),
              content: Stack(
                children: [
                  Positioned(
                    top: 0,
                    right: 0,
                    child: IconButton(
                      icon: const Icon(Icons.close, color: Color(0xFF208584)),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  SizedBox(
                    width: double.maxFinite,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          initialHumor == null
                              ? 'Adicionar novo humor'
                              : 'Editar humor',
                          style: const TextStyle(
                            fontSize: 18,
                            fontFamily: 'HelveticaNeue',
                            color: Color(0xFF208584),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 20),
                        TextField(
                          controller: controller,
                          decoration: InputDecoration(
                            hintText: initialHumor == null
                                ? 'Digite o novo humor'
                                : 'Edite o humor',
                          ),
                        ),
                        const SizedBox(height: 20),
                        Wrap(
                          spacing: 10,
                          children: _emojiColors.keys.map((emoji) {
                            return GestureDetector(
                              onTap: () {
                                setState(() => emojiSelecionado = emoji);
                              },
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: _emojiColors[emoji],
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: emoji == emojiSelecionado
                                        ? Colors.black
                                        : Colors.transparent,
                                    width: 2,
                                  ),
                                ),
                                child: Text(
                                  emoji,
                                  style: const TextStyle(fontSize: 24),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              actions: [
                ElevatedButton(
                  onPressed: () {
                    if (controller.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Por favor, insira um humor válido.'),
                        ),
                      );
                    } else if (emojiSelecionado == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Por favor, selecione um emoji.'),
                        ),
                      );
                    } else {
                      Navigator.pop(context, {
                        'emoji': emojiSelecionado!,
                        'humor': controller.text,
                      });
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF208584),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 30,
                      vertical: 15,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Salvar',
                    style: TextStyle(
                      fontSize: 16,
                      fontFamily: 'HelveticaNeue',
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _editarEmocao(Map<String, dynamic> emocao) async {
    final emocaoEditada = await _mostrarDialogoEmocao(
      context: context,
      initialHumor: emocao['humor'],
      initialEmoji: emocao['emoji'],
    );
    if (emocaoEditada != null) {
      setState(() {
        final index = emocoesPersonalizadas.indexOf(emocao);
        emocoesPersonalizadas[index] = emocaoEditada;
        _salvarDados();
      });
    }
  }

  Future<void> _removerEmocao(Map<String, dynamic> emocao) async {
    setState(() {
      emocoesPersonalizadas.remove(emocao);
      _salvarDados();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Humor "${emocao['humor']}" deletado com sucesso!',
          style: const TextStyle(
            fontSize: 16,
            fontFamily: 'HelveticaNeue',
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF208584),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
