# بانر الرئيسية — iOS

البانر بقى **popup في نص الشاشة** بدل الشريط اللي كان جوه المحتوى،
والموديل اتظبط على الـ response الحقيقي من
`https://api.msagold.com/api/v1/banners`.

## الملفات

| الملف | الحالة |
|---|---|
| `BannerModel.swift` | **اتغيّر بالكامل** — decoding متسامح + التواريخ + الفلترة |
| `BannerService.swift` | **اتغيّر** — من غير كاش، نداء مباشر على الـ API |
| `BannerPopupVC.swift` | **جديد** — الـ popup نفسه |
| `BannerBrand.swift` | **جديد** — ألوان البراند من `Colors.ai` |
| `HomeVC+Banner.swift` | **اتغيّر** — بيعرض الـ popup بدل الشريط |
| `BannerSliderView.swift` | تعديل بسيط — `onPageChanged` + النقط بلون البراند |
| `BannerCell.swift` | تعديل بسيط — خلفية البراند + شيل التدوير الداخلي |

## الدمج

١. **بدّل الملفات** في فولدر `Banner` بالنسخ دي، وضيف الجديدين
   (`BannerPopupVC.swift` و `BannerBrand.swift`) للـ target من Xcode.

٢. **`HomeVC` مش محتاجة أي تعديل** — نفس التلات نداءات اللي عندك:

   ```swift
   override func viewDidLoad() {
       super.viewDidLoad()
       setupBannerSlider()        // بقى بيحمّل ويعرض الـ popup
   }

   override func viewWillAppear(_ animated: Bool) {
       super.viewWillAppear(animated)
       resumeBannerSlider()
   }

   override func viewWillDisappear(_ animated: Bool) {
       super.viewWillDisappear(animated)
       pauseBannerSlider()
   }
   ```

٣. **الـ `banneView` في الاستوري بورد** سيبها زي ما هي — الكود بيخفيها،
   والـ stackView بيقفل مكانها لوحده.

---

## اللي اتظبط في الموديل

الـ response الحقيقي:

```json
{
  "meta": { "current_page": 1, "per_page": 15, "total": 1 },
  "data": [{
    "id": 4,
    "name": "MSA ",
    "media_type": "image",
    "media_url": "https://api.msagold.com/storage/14/01M18....jpeg",
    "thumb_url": "https://api.msagold.com/storage/14/conversions/...-thumb.jpg",
    "order": 0,
    "starts_at": null, "ends_at": null,
    "link":   { "type": "none",   "url": null },
    "status": { "value": "active", "label": { "ar": "نشط", "en": "Active" } }
  }],
  "links": { "next": null, "prev": null }
}
```

| الحالة | التصرّف |
|---|---|
| `link.type = "none"` | `linkURL = nil` → زرار "اعرف أكثر" مبيظهرش خالص |
| `name = "MSA "` | بيتعمله trim قبل العرض |
| `starts_at` / `ends_at` | بتتفكّ لـ `Date` (ISO-8601 بالميكروثانية UTC) |
| `status.value` | البانر مش `active` مبيتعرضش |
| `per_page = 15` | بنطلب `per_page=50` عشان كل البانرات تيجي في ريكوست واحد |
| بانر واحد بس | النقط مبتظهرش، ومفيش تقليب — كارت ثابت |

### تلات إصلاحات مهمة

**١. الـ decoding مبقاش بيقع.** النسخة القديمة كانت معرّفة الحقول
non-optional (`name: String`, `link: BannerLink`, `createdAt: String`…)،
فأي حقل ناقص من الباك اند كان بيرمي error ويضيّع الـ **response كله**.
دلوقتي كله `decodeIfPresent`، والبانر الوحيد اللي بيتشال هو اللي مالوش
`id` أو `media_url`. وكمان بانر واحد باظ مبيوقّعش الباقي
(`FailableDecodable`).

**٢. `Meta` مبقاش فيه تضارب.** النسخة القديمة كانت بتستخدم `Meta`
المعرّفة في `NewsModel.swift`. دلوقتي فيه `BannerMeta` مستقلة، فلو شكل
الـ meta اتغيّر في أي مكان تاني البانر مش هيتأثر.

**٣. اللينك كان بيتفتح غلط.** النسخة القديمة كانت بتعمل
`openLink(URL(string: item.mediaURL))` — يعني بتفتح **رابط الصورة**
نفسها بدل رابط البانر. دلوقتي بتستخدم `item.linkURL`.

---

## شكل الـ popup

```
                    ✕     ← زرار إغلاق فوق الكارت
 ┌──────────────────────┐
 │      ميديا 16:9      │  ← نفس السلايدر: صور وفيديو + عنوان + نقط ذهبية
 └──────────────────────┘
 [      اعرف أكثر      ]  ← زرار بتدرج الكريمي→الذهبي (يظهر لو فيه لينك بس)
```

- `.overFullScreen` — الرئيسية بتفضل باينة ورا الخلفية المعتّمة، إحساس
  popup مش شاشة جديدة.
- **عرض الشاشة كامل ناقص ١٦ يمين وشمال** (من الـ safe area)، والارتفاع
  نسبة **16:9** من العرض. غيّر الـ `multiplier` في `card.heightAnchor` —
  القيمة هي الارتفاع ÷ العرض، يعني `1` لمربع و `4.0/3.0` لطولي.
- بيدخل بأنيميشن spring (scale + fade).
- الضغط على الخلفية بيقفل.
- الضغط على الميديا: لو فيه لينك بيفتحه، لو مفيش بيفتحها بملء الشاشة
  (نفس `PhotoDetialsVC` و `AVPlayerViewController`).

## الظهور

**مرة واحدة كل تشغيلة للتطبيق.** مفيش سياسات ولا إعدادات — `viewDidLoad`
بتنده الـ API على طول، وأول ما البانرات توصل الـ popup بيظهر.

`viewDidLoad` بتشتغل مرة واحدة لكل تشغيلة (الـ tab bar بيحتفظ بالـ
`HomeVC`)، واللي بيمنع التكرار لو اتعملت من جديد لأي سبب هو
`shownThisLaunch` في `BannerService` — متغيّر `static` في الذاكرة،
**مش** في `UserDefaults`:

| | |
|---|---|
| فتح التطبيق | يظهر ✅ |
| راح لتاب تاني ورجع للرئيسية | مبيظهرش ✅ |
| التطبيق راح للخلفية ورجع | مبيظهرش ✅ |
| قفل التطبيق خالص وفتحه | يظهر تاني ✅ |

عايزه يظهر كل مرة الرئيسية تتفتح مش كل فتحة تطبيق؟ رجّع `false` بدل
`!shownThisLaunch` في `shouldShowPopup`.

## مفيش كاش

كل مرة بنسأل الـ API من جديد. يعني لو الداشبورد وقّفت بانر أو نشرت واحد
جديد، المستخدم بيشوف الجديد من أول فتحة — مش بعد ما الكاش يقدم.

الثمن: **مفيش بانر بيظهر وهو أوفلاين**. مقبول لأن البانر إعلان مش محتوى
أساسي، ولو الريكوست فشل الرئيسية بتشتغل عادي من غيره.

## ملاحظات

- **الكاش القديم:** لو التطبيق نزل عند مستخدمين بنسخة كانت بتكاش،
  المفتاح `_MSA_|_Home_Banners_` بيفضل في `UserDefaults` من غير ما حد
  يقراه. حاجة صغيرة، بس تقدر تمسحه في أول تشغيلة لو حبيت تنضّف.

- **الألوان:** `BannerBrand.swift` فيه ألوان البراند محلياً. لما تنقلها
  للـ asset catalog امسح الملف وبدّل الأسماء.

- **الفلترة:** `activeNow()` بتشتغل على اللي راجع من الشبكة. أي حقل
  ناقص مبنفلترش بيه عشان بانر ما يختفيش بالغلط. لو عايز تلغي الفلترة،
  شيل `.activeNow()` من `BannerService.fetchBanners`.

- **أكتر من ٥٠ بانر:** هتحتاج تلف على `links.next` — الـ struct بتاعها
  موجود جاهز (`BannerPageLinks`).

- **الشريط القديم:** `BannerSliderView` لسه شغالة كما هي، فلو حبيت
  ترجّع الشريط جوه المحتوى في أي وقت حطها في الـ `banneView` زي الأول.
