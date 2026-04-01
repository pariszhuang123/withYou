# 📱 WithYou / 陪你

> Feel like someone is already there.

WithYou is a **one-tap, offline companion call app** that creates the feeling someone is present and expecting you — without requiring real communication.

**Primary scenario:** A woman is in a situation she wants to leave. She triggers a fake call that plays through the **speaker** — bystanders overhear a convincing voice ("I'm downstairs, where are you?"), giving her a natural, pressure-free reason to walk away.

---

## ✨ Why This Exists

Most safety tools focus on emergencies. But many real situations are just slightly uncomfortable, uncertain, or hard to explain.

WithYou is designed for those moments.

> Not to react — but to **change the situation before it escalates**.

---

## 🎯 What It Does

Tap **"Call me now"**:

1. A realistic incoming call appears
2. A natural Chinese voice plays **through the speaker** (so others hear it)
3. Follow-up calls arrive automatically as notifications over time
4. It feels like someone is waiting for you

No setup. No login. No internet needed.

### 📋 v1 Scenarios

| Scenario | Chinese Name | Description |
|----------|-------------|-------------|
| Pickup Expectation | 接送催促 | Someone is downstairs waiting to pick you up |
| Safety Check | 关心确认 | Someone checking if you're okay / where you are |
| Casual Exit | 轻松脱身 | A casual reason to step away from the situation |
| Urgent Pull-away | 稍微紧急 | Something mildly urgent that requires you to leave |

Each scenario has a fixed caller identity (e.g. 小陈, 阿杰) — neutral names, not relationship titles.

---

## 🔑 Core Features

- 📞 One-tap call simulation — "Call me now" button
- 🔊 Speaker-first audio (designed to be overheard)
- 🎧 Pre-recorded natural voice scripts (Chinese only for v1)
- 🔁 3-stage call flow (initial + 2 follow-ups via notifications)
- 🎭 4 scenarios with fixed caller identities (小陈, 阿杰, etc.)
- 📴 Fully offline
- 🔒 No data collection
- 💾 Audio budget: ≤5MB total

---

## 🧠 Design Principles

| Principle | Target |
|-----------|--------|
| Fast | < 3 seconds to first call screen |
| Calm | No alarms, no panic |
| Believable | Passes the "overheard by a stranger" test |
| Private | Nothing leaves the device |
| Reliable | People depend on this — zero flaky behavior |

---

## 🏗️ Architecture

Contract-based, dependency-injected, layer-separated:

```
UI (Screens) → Bloc → Services (contracts) → Repository (Drift) + Platform
```

Every layer communicates through abstract contracts. See full details in [`docs/architecture.md`](docs/architecture.md).

---

## 📁 Documentation

All detailed specifications live in `docs/`. AI agents and contributors should read the relevant doc before implementing.

| Doc | Purpose |
|-----|---------|
| [Architecture](docs/architecture.md) | Layers, DI, dependencies, project structure |
| [Design System](docs/design-system.md) | Material 3 theme, call screen UI, accessibility |
| [Data Model](docs/data-model.md) | SQLite/Drift schema |
| [Content Model](docs/content-model.md) | Scenario × caller mapping |
| [Testing Strategy](docs/testing.md) | Test plan, 31 critical test cases, mocks |
| [CI/CD](docs/ci-cd.md) | GitHub Actions pipeline |

### Contracts

| Contract | Purpose |
|----------|---------|
| [Call Flow](docs/contracts/call-flow.md) | 3-stage call orchestration — the critical path |
| [Audio Playback](docs/contracts/audio-playback.md) | Speaker-first audio rules |
| [Notification](docs/contracts/notification.md) | Follow-up call scheduling |
| [Repository](docs/contracts/call-session-repository.md) | Session + event persistence |
| [Content Resolver](docs/contracts/content-resolver.md) | Scenario-based asset resolution |
| [Paywall](docs/contracts/paywall.md) | Purchase gating rules |

---

## 💰 Monetization

- First complete call flow is **free**
- One-time unlock: **$3.99** (unlimited use, all scenarios)
- No subscriptions

---

## 🔐 Privacy

- No login, no tracking, no analytics
- All data stored locally
- No telephony spoofing
- Fully offline

---

## 🚧 Status

MVP in development.

---

## 🧠 Philosophy

This is not a "fake call app." This is a **presence simulation system**.

> Sometimes, you don't need help.
> You just need it to feel like someone is there.

---

## 📄 License

No licence
