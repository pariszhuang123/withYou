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

With one tap:

1. A realistic incoming call appears
2. A natural voice plays **through the speaker** (so others hear it)
3. Follow-up calls happen automatically — even if declined
4. It feels like someone is persistently trying to reach you

No setup. No login. No internet needed.

---

## 🔑 Core Features

- 📞 One-tap call simulation (logo = trigger)
- 🔊 Speaker-first audio (designed to be overheard)
- 🔁 3-stage call flow — all 3 calls fire regardless of accept/decline
- 🎧 Pre-recorded natural Chinese voice scripts
- 📱 Platform-native call UI (iOS-style on iPhone, Android-style on Android)
- 🌏 UI follows device language (中文 / English)
- 📴 Fully offline (audio bundled, no internet)
- 🔒 No data stored — no session logs, no call history

---

## 🧠 Design Principles

| Principle | Target |
|-----------|--------|
| Fast | < 3 seconds to first call screen |
| Calm | No alarms, no panic |
| Believable | Passes the "overheard by a stranger" test |
| Private | Nothing stored, nothing to find |
| Persistent | All 3 calls fire even if declined |
| Reliable | People depend on this — zero flaky behavior |

---

## 🏗️ Architecture

Contract-based, dependency-injected, layer-separated:

```
UI (Screens) → Bloc → Services (contracts) → Platform (audio, notifications)
```

Every layer communicates through abstract contracts. See [`docs/architecture.md`](docs/architecture.md).

---

## 📁 Documentation

All detailed specs live in `docs/`. AI agents and contributors must read the relevant doc before implementing.

| Doc | Purpose |
|-----|---------|
| [Architecture](docs/architecture.md) | Layers, DI, dependencies, project structure |
| [Design System](docs/design-system.md) | Material 3 theme, call screen templates, l10n |
| [Data Model](docs/data-model.md) | App state persistence (minimal) |
| [Content Model](docs/content-model.md) | Scenario × caller mapping, audio assets |
| [Testing Strategy](docs/testing.md) | Test plan, critical test cases, mocks |
| [CI/CD](docs/ci-cd.md) | GitHub Actions pipeline |

### Contracts

| Contract | Purpose |
|----------|---------|
| [Call Flow](docs/contracts/call-flow.md) | 3-stage call orchestration — the critical path |
| [Audio Playback](docs/contracts/audio-playback.md) | Speaker-first audio rules |
| [Notification](docs/contracts/notification.md) | Follow-up call scheduling + resume |
| [App State](docs/contracts/app-state.md) | Scenario preference + purchase state |
| [Content Resolver](docs/contracts/content-resolver.md) | Scenario-based asset resolution |
| [Call Template](docs/contracts/call-template.md) | Platform-specific call UI templates |
| [Paywall](docs/contracts/paywall.md) | Purchase gating with emergency bypass |

---

## 💰 Monetization — Emergency Bypass Model

| Use | Behavior |
|-----|----------|
| 1st flow | **Free** — full 3-stage experience |
| 2nd attempt | Paywall shown with **"紧急使用"** (Emergency) button |
| Emergency tap | Immediately triggers call — zero friction |
| After emergency | Paywall returns: "We're glad we could help. Unlock to have it ready anytime." |
| 3rd+ attempt | Must purchase ($3.99 one-time) |
| Emergency reset | Resets every 30 days — always one available |
| During active flow | **NEVER** show paywall |

---

## 🔐 Privacy

- No login, no tracking, no analytics
- **No session history stored** — no call logs, nothing to find
- Only stored data: scenario preference + purchase state
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
