import 'package:flutter/material.dart';

class InitialChatWidget extends StatefulWidget {
  const InitialChatWidget({super.key, required this.onSubmit});

  final Function(String) onSubmit;

  @override
  State<InitialChatWidget> createState() => _InitialChatWidgetState();
}

class _InitialChatWidgetState extends State<InitialChatWidget> {
  final TextEditingController _textEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  "Hello, user.",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text(
                  "How can I help you today?",
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                Container(
                  constraints: const BoxConstraints(maxWidth: 600),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _textEditingController,
                          decoration: InputDecoration(
                            hintText: "What do you want to know?",
                            hintStyle: TextStyle(color: Colors.white),
                            border: InputBorder.none,
                          ),
                          style: const TextStyle(color: Colors.white),
                          onSubmitted: (value) {
                            if (value.isNotEmpty) {
                              widget.onSubmit(_textEditingController.text);
                            }
                          },
                        ),
                      ),
                      IconButton(
                        icon:
                            const Icon(Icons.arrow_upward, color: Colors.white),
                        onPressed: () {
                          if (_textEditingController.text.isNotEmpty) {
                            widget.onSubmit(_textEditingController.text);
                          }
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Wrap(
                  spacing: 12,
                  children: [
                    _buildButton("DeepSearch", Icons.search),
                    _buildButton("Think", Icons.lightbulb),
                    _buildButton("Research", Icons.manage_search),
                    _buildButton("How to", Icons.auto_stories),
                    _buildButton("Analyze", Icons.bar_chart),
                    _buildButton("Create images", Icons.image),
                    _buildButton("Code", Icons.code),
                  ],
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildButton(String text, IconData icon) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.black54,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      onPressed: () {},
      icon: Icon(icon, size: 18, color: Colors.white),
      label: Text(text),
    );
  }
}
