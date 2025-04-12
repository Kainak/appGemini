import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  await dotenv.load();
  runApp(const StudyBuddyApp());
}

class StudyBuddyApp extends StatelessWidget {
  const StudyBuddyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Study Buddy',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      home: const StudyPlannerScreen(),
    );
  }
}

class StudyPlannerScreen extends StatefulWidget {
  const StudyPlannerScreen({Key? key}) : super(key: key);

  @override
  State<StudyPlannerScreen> createState() => _StudyPlannerScreenState();
}

class _StudyPlannerScreenState extends State<StudyPlannerScreen> {
  final TextEditingController _inputController = TextEditingController();
  final stt.SpeechToText _speech = stt.SpeechToText();

  bool _isLoading = false;
  bool _isListening = false;
  String _responseMessage = '';
  final String? apiKey = dotenv.env['API_KEY'];

  // Opções de qualificação do prompt
  String _mood = '😐 Normal';
  String _time = '⏱️ Pouco tempo';
  String _focus = '📘 Teoria';

  @override
  void initState() {
    super.initState();
    _initSpeech();
  }

    void _initSpeech() async {
    bool available = await _speech.initialize(
      onStatus: (status) {
        if (status == 'done') {
          setState(() {
            _isListening = false;
          });
        }
      },
      onError: (errorNotification) {
        setState(() {
          _isListening = false;
        });
      },
    );
    if (!available) {
      // O reconhecimento de voz não está disponível no dispositivo
    }
  }
  
  void _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize();
      if (available) {
        setState(() {
          _isListening = true;
        });
        _speech.listen(
          onResult: (result) {
            setState(() {
              _inputController.text = result.recognizedWords;
            });
          },
        );
      }
    } else {
      setState(() {
        _isListening = false;
        _speech.stop();
      });
    }
  }

  Future<void> _getStudyTip() async {
    if (_inputController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Descreva seu momento de estudo ou use o microfone'),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final prompt = '''

    Você é um coach de estudos, e tem conhecimento vasto sobre projetos e métodos ágeis. Com base na seguinte descrição:

    - Estado de espírito: $_mood
    - Tempo disponível: $_time
    - Foco atual: $_focus
    - Entrada do usuário: "${_inputController.text}"

    Dê uma sugestão realista, mas motivadora de como eu posso estudar hoje com base nos parametros que te passei. Divida em fases ou passos se possível. Use emojis.

    Não use asteriscos ou deixe palavras em negrito!
    
    Mantenha um tom acolhedor, mas seja firme ao mesmo tempo.

    Sugira links e livros relacionados aos temas
    ''';

    final url =
        'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=$apiKey';

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "contents": [
            {
              "parts": [
                {"text": prompt},
              ],
            },
          ],
          "generationConfig": {
            "temperature": 0.7,
            "topK": 40,
            "topP": 0.95,
            "maxOutputTokens": 700,
          },
        }),
      );

      if (response.statusCode == 200) {
        final jsonResp = jsonDecode(response.body);
        final result = jsonResp['candidates'][0]['content']['parts'][0]['text'];
        setState(() => _responseMessage = result);
      } else {
        setState(
          () =>
              _responseMessage =
                  'Erro ${response.statusCode}: ${response.body}',
        );
      }
    } catch (e) {
      setState(() => _responseMessage = 'Erro ao conectar com a API: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Widget _optionSelector<T>(
    String label,
    List<T> options,
    T selected,
    ValueChanged<T> onSelected,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Wrap(
          spacing: 8,
          children:
              options.map((option) {
                final isSelected = selected == option;
                return ChoiceChip(
                  label: Text(option.toString()),
                  selected: isSelected,
                  onSelected: (_) => onSelected(option),
                  selectedColor: Colors.deepPurple.shade100,
                  backgroundColor: Colors.grey.shade200,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.deepPurple : Colors.black,
                  ),
                );
              }).toList(),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Study Buddy'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      //
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Descreva seu momento de estudo:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _inputController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText:
                            'Fale um pouco sobre o que quer ou precisa estudar hoje. Vou tentar te ajudar 😉',
                      ),
                    ),
                    const SizedBox(height: 16),
                    _optionSelector(
                      'Como você está se sentindo?',
                      [ '😄 Motivado','😐 Normal', '😞 Cansado', '🥲 Aflito'],
                      _mood,
                      (val) => setState(() => _mood = val),
                    ),
                    const SizedBox(height: 8),
                    _optionSelector(
                      'Quanto tempo você tem?',
                      ['⏱️ Pouco tempo', '🕒 1 hora', '🕓 Várias horas', '1 semana', '1 mês'],
                      _time,
                      (val) => setState(() => _time = val),
                    ),
                    const SizedBox(height: 8),
                    _optionSelector(
                      'Qual seu foco hoje?',
                      ['📘 Teoria', '📝 Revisão', '🎯 Prática', '📌 Planejamento', '💡 Preciso de idéias'],
                      _focus,
                      (val) => setState(() => _focus = val),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _isLoading ? null : _getStudyTip,
                      icon: const Icon(Icons.lightbulb,color: Colors.yellow,),
                      label:
                          _isLoading
                              ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                              : const Text('Quero uma dica!'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.all(16),
                        textStyle: const TextStyle(fontSize: 16),
                      ),
                    ),
                    const SizedBox(height: 20),
                    if (_responseMessage.isNotEmpty)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.deepPurple.shade50,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _responseMessage,
                          style: const TextStyle(fontSize: 16, height: 1.5),
                        ),
                      ),
                    const SizedBox(
                      height: 100,
                    ), 
                  ],
                ),
              ),
            ),
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _isListening ? "Gravando..." : "Toque para falar",
                    style: TextStyle(
                      color: _isListening ? Colors.deepPurple : Colors.black54,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  IconButton(
                    iconSize: 32,
                    onPressed: _listen,
                    icon: Icon(
                      _isListening ? Icons.mic : Icons.mic_none,
                      color: Colors.deepPurple,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
