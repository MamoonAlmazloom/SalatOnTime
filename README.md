# الصلاة على وقتها · Salat On Time

**Leave home at the right moment — reach your mosque on time, every prayer.**

**اخرج من البيت في اللحظة المناسبة وصِل مسجدك على وقت كل صلاة.**

[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-0E7C66.svg)](LICENSE)

## What it does

Most prayer apps tell you when the adhan is. This one answers the question that actually gets you to the mosque: **"when do I need to leave home?"**

1. Pick your mosque once on a map.
2. Tell the app how long it takes you to get there (or let it calculate the route).
3. Add your personal buffers — wudu, bathroom time per prayer, a safety margin.
4. Set when the iqama is held at your mosque, per prayer.

The app then computes an exact **leave-home time** for all five prayers and fires an alert at that moment — a standard notification, or an alarm-style alert that rings through silent mode. Each alert carries a rotating ayah or hadith encouraging prayer in congregation.

## Privacy: verify, don't trust

- **No servers.** Prayer times are calculated offline on your device (Umm al-Qura method).
- **No accounts, no analytics, no ads, no tracking SDKs.**
- **We can't sell your data — we never receive it.**
- Map images come directly from [OpenStreetMap](https://www.openstreetmap.org); optional route calculation talks directly to a public OSRM instance. Nothing passes through us.
- This repository is the entire app. Audit it yourself.

[Privacy policy | سياسة الخصوصية](https://mamoonalmazloom.github.io/SalatOnTime/privacy-policy)

## Features

- 🕌 Live countdowns: adhan, iqama, and the headline **"leave home in…"**
- ⏰ Exact-time alerts for the next 3 days, rescheduled automatically, surviving reboots
- 🔊 Alarm-style option: rings on the alarm channel even in silent mode (Android)
- 🌍 Arabic (RTL) and English, switchable in-app or following the system
- 🌙 Hijri + Gregorian dates; light/dark/system theme
- 📿 Per-prayer tuning: iqama offsets, arrive-by adhan or iqama, bathroom minutes
- 📡 Works fully offline after setup (map tiles need internet)

## Building

Flutter (stable ≥ 3.44). Then:

```sh
flutter pub get
flutter run --target=lib/main.dart
```

Release builds require your own signing config in `android/key.properties` (see `android/app/build.gradle.kts`); without it, release builds fall back to debug signing.

## License

[GPL-3.0](LICENSE) — you may reuse this code, but derivative apps must remain open source. That's deliberate: nobody should be able to take a privacy-first prayer app, add trackers, and ship it closed.
