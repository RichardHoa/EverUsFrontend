# 💖 EverUs

EverUs is a couples app: partners answer a preferences **Questionnaire**, and the app uses those answers to power features like the **date planner**, which generates a sequence of real-world stops (each with backup options) tailored to a chosen search radius.

This repo is the **Flutter client**. It talks to a separate backend service — see [EverUsBackend](https://github.com/RichardHoa/EverUsBackend).

For the project's domain vocabulary (Questionnaire, QuestionnaireResponse, Stage, Backup rank, Distance preference, etc.) and the reasoning behind past decisions, see [`CONTEXT.md`](./CONTEXT.md) and [`docs/adr/`](./docs/adr/) — treat those as the source of truth over this README's prose.

---

## 🚀 How to Run

1. **Navigate to the Flutter project folder:**
   ```bash
   cd flutter-project/everus
   ```

2. **Get packages:**
   ```bash
   flutter pub get
   ```

3. **Run the app on your emulator or connected device:**
   ```bash
   flutter run
   ```
   Or in a browser:
   ```bash
   flutter run -d chrome --web-port=8008
   ```

The app requires the backend service to be running — see [EverUsBackend](https://github.com/RichardHoa/EverUsBackend) for setup, including the current place-data collection pipeline that feeds the date planner.

---

## 🤖 AI-Assisted Development

This project is built with [Claude Code](https://claude.com/claude-code). Domain-modeling and code-review workflows (glossary upkeep in `CONTEXT.md`, ADRs, grilling design decisions before implementing) use the [mattpocock-skills](https://www.aihero.dev/skills) plugin by Matt Pocock. If you're continuing development with Claude Code, install the same plugin so those workflows are available to you:

```
/plugin marketplace add anthropics/claude-plugins-official
/plugin install mattpocock-skills@claude-plugins-official
```

Project conventions for agents (issue tracking under `.scratch/`, the `CONTEXT.md` + `docs/adr/` domain-doc layout) are documented in `CLAUDE.md` and `docs/agents/`.

---

## ⚙️ Git Commit Template

This repository contains a git commit message template (`.gitmessage`) to maintain uniform commit scopes (`feat:`, `fix:`, `docs:`, `refactor:`, etc.).

To set up this template locally in your clone, run:
```bash
git config commit.template .gitmessage
```
