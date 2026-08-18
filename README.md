# چله‌بان (Cheleban)

اپلیکیشن شخصی برای پیگیری **۴۰ شب** نماز شب، زیارت عاشورا و دعای توسل + سیستم آگاهی موقعیتی هوایی (Airspace Awareness).

**نسخه:** 1.0.0  
**وضعیت:** Production-ready foundation + Airspace Awareness

---

## ویژگی‌ها

- تیک‌زنی سریع سه عبادت اصلی
- تقویم ۴۰ روزه با progress واقعی
- قفل بیومتریک + PIN امن
- **Airspace Awareness** (داده‌های عمومی ADS-B)
  - Detection + Identification + Classification مسئولانه
  - Confidence Score واقعی
  - Unknown Object System
  - Privacy Mode
  - Offline-first
- تم تاریک تاکتیکی + RTL فارسی
- ذخیره‌سازی محلی امن

---

## تصاویر حرم

پوشه `assets/images/` آماده دریافت تصاویر محترم حرم امام رضا (ع) و حرم امام حسین (ع) است.  
راهنما داخل همان پوشه (`assets/images/README.md`) قرار دارد.

---

## شروع سریع

```bash
git clone <your-private-repo-url>
cd cheleban_app
cp .env.example .env   # فقط محلی
flutter pub get
flutter analyze
flutter test
flutter run
```

---

## ساختار پروژه

```
lib/
├── core/
│   ├── airspace/          # Airspace Engine + Validation + Confidence
│   ├── services/
│   ├── theme/
│   └── providers.dart
├── data/models/
│   └── airspace/
├── features/
│   ├── airspace/          # صفحه AIRSPACE + جزئیات Object
│   ├── home/
│   ├── calendar/
│   ├── auth/
│   └── settings/
└── main.dart
```

---

## Build & Release

```bash
flutter build apk --release
flutter build appbundle --release
```

### GitHub Actions
- CI: format + analyze + test
- Build Android روی تگ `v*`

**Secrets مورد نیاز برای Release:**  
`KEYSTORE_BASE64`, `KEYSTORE_PASSWORD`, `KEY_ALIAS`, `KEY_PASSWORD`

---

## امنیت

- هیچ API Key یا Secret داخل سورس نیست.
- `.env` در `.gitignore` است.
- Repository را **Private** نگه دارید.
- PIN با salt + SHA-256 هش می‌شود.
- Encryption key فقط در Secure Storage.

---

## اصول Airspace

```
DATA FIRST • CONFIDENCE FIRST • PRIVACY FIRST • SAFETY FIRST
```

- هیچ ادعای FIGHTER / هدف‌گیری / رهگیری عملیاتی وجود ندارد.
- داده ناقص → UNKNOWN / LOW CONFIDENCE
- داده قدیمی → STALE
- شبکه قطع → OFFLINE

---

## License
Private / Personal Use.
