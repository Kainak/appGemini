# 📚 Study – Seu Coach de Estudos Pessoal

O **Study Buddy** é um aplicativo desenvolvido com Flutter que atua como um coach de estudos personalizado. Utilizando entrada de voz e a API do **Google Gemini**, ele oferece **dicas motivadoras e realistas de estudo**, com base no seu humor, tempo disponível e foco do dia.

> Ideal para quem busca organização, motivação e eficiência na rotina de estudos! 😉

---

## ✨ Funcionalidades

- 🎙️ **Entrada por voz** com reconhecimento em tempo real.
- 📋 **Análise do seu momento atual de estudo**, com base em:
  - Estado de espírito
  - Tempo disponível
  - Foco do dia
- 🤖 **Sugestões personalizadas** usando IA (API Gemini)
- 📚 Recomendações de livros e links relacionados
- ✨ Interface moderna e acolhedora com suporte a emojis

---

## 📸 Capturas de Tela

> *(Adicione aqui prints do app rodando. Pode ser emulador ou dispositivo real.)*

---

## 🛠️ Tecnologias Utilizadas

- [Flutter](https://flutter.dev/) + Dart
- [Speech to Text](https://pub.dev/packages/speech_to_text) (reconhecimento de voz)
- [HTTP](https://pub.dev/packages/http) (requisições à API)
- [flutter_dotenv](https://pub.dev/packages/flutter_dotenv) (gestão segura de chaves)
- [Gemini API (Google Generative AI)](https://ai.google.dev/)

---

## ⚙️ Como Rodar o Projeto

1. **Clone o repositório:**

```bash
git clone https://github.com/seu-usuario/study-buddy.git
cd study-buddy
```

2. **Instale as dependências:**

```bash
flutter pub get
```

3. **Configure seu arquivo `.env`:**

Crie um arquivo `.env` na raiz do projeto com sua chave da API Gemini:

```
API_KEY=coloque_sua_api_key_aqui
```

> 🔐 *Certifique-se de não versionar seu `.env`. O arquivo já está no `.gitignore`.*

4. **Rode o app:**

```bash
flutter run
```

---

## ✅ Próximos Passos (To-do)

- [ ] Modo noturno 🌙
- [ ] Histórico de dicas e sugestões anteriores
- [ ] Compartilhamento das dicas com amigos
- [ ] Tradução para outros idiomas
- [ ] Integração com calendário (Google Calendar)

---

## 🙌 Contribuindo

Sinta-se à vontade para abrir issues ou enviar pull requests! Toda ajuda é bem-vinda para tornar o **Study Buddy** ainda melhor. 🚀

---

## 📄 Licença

Este projeto está licenciado sob a **MIT License**. Veja o arquivo [LICENSE](./LICENSE) para mais detalhes.

---

## 💡 Inspiração

Desenvolvido com carinho para ajudar estudantes a **planejarem melhor seus dias de estudo**, com ajuda da tecnologia e um toque de motivação. 💜
