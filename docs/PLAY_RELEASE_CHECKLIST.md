# Google Play release checklist

## جاهز داخل المشروع

- [x] Application ID ثابت: `com.redtech.redline`
- [x] Target SDK 36
- [x] App Bundle (AAB)
- [x] مفتاح Upload إنتاجي منفصل عن debug
- [x] HTTPS إجباري وcleartext معطل
- [x] التحديث الخارجي عبر GitHub معطل
- [x] سياسة الخصوصية موجودة داخل التطبيق
- [x] مسودة سياسة خصوصية عامة وبيانات المتجر وData safety
- [x] لقطات شاشة جاهزة في `assets/screenshot/`
- [x] App icon وfeature graphic في `play_store/`

## يلزم إتمامه داخل Play Console

- [ ] تفعيل Play App Signing ورفع ملف AAB.
- [ ] نشر `docs/privacy-policy.html` على رابط HTTPS عام ووضع الرابط في App content.
- [ ] إضافة بريد دعم حقيقي ورقم/موقع المطور عند الحاجة.
- [ ] رفع icon مقاس 512×512 وfeature graphic مقاس 1024×500 ولقطات الهاتف.
- [ ] تعبئة Data safety من المستند المرفق.
- [ ] تعبئة Content rating واختيار Business والجمهور 18+.
- [ ] اختيار Ads = No وApp access = restricted.
- [ ] توفير حساب ERP تجريبي صالح لفريق المراجعة وتعليمات الدخول.
- [ ] إكمال متطلبات الاختبار المغلق إن كان حساب المطور الشخصي خاضعًا لها.
- [ ] أخذ نسخة احتياطية مشفرة من `android/upload-keystore.jks` و`android/key.properties` خارج الجهاز.

## كل إصدار لاحق

ارفع `version` في `pubspec.yaml`، خصوصًا رقم البناء بعد `+`. لا يمكن رفع AAB آخر بنفس `versionCode`.
