import 'package:flutter/material.dart';

class HelpCenterPage extends StatelessWidget {
  const HelpCenterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Help Center'), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'How can we help you?',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          // 🔍 Search Field
          TextField(
            decoration: InputDecoration(
              hintText: 'Search help articles...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // 📚 FAQ List
          const FAQTile(
            question: 'Comment créer un compte ?',
            answer:
                'Pour créer un compte, cliquez sur "S’inscrire", entrez vos informations et validez avec un code envoyé par SMS.',
          ),
          const FAQTile(
            question: 'Comment modifier mon profil ?',
            answer:
                'Allez dans "Profil" > "Informations personnelles", puis modifiez ce que vous souhaitez.',
          ),
          const FAQTile(
            question: 'Comment signaler un problème ?',
            answer:
                'Allez dans "Paramètres" > "Signaler un problème" ou envoyez-nous un message via WhatsApp.',
          ),

          const SizedBox(height: 24),

          // 📩 Contact
          Card(
            color: Colors.blue.shade50,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              leading: const Icon(Icons.mail_outline, color: Colors.blue),
              title: const Text("Vous n’avez pas trouvé de réponse ?"),
              subtitle: const Text("Contactez notre équipe de support."),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                // 👉 Ouvrir un email ou un WhatsApp
                // Ex: launch("mailto:support@sevislakay.com")
              },
            ),
          ),
        ],
      ),
    );
  }
}

class FAQTile extends StatelessWidget {
  final String question;
  final String answer;

  const FAQTile({super.key, required this.question, required this.answer});

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      tilePadding: const EdgeInsets.symmetric(horizontal: 8),
      childrenPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      title: Text(
        question,
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      children: [Text(answer)],
    );
  }
}
