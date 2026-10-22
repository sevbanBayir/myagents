---
name: ui-craft-study-guide
description: Human-facing study plan (Turkish) for learning sinasamaki's UI craft and steering agents with the ui-craft skill. Agents use the skill itself; this doc is for Sevban.
---

# ui-craft çalışma rehberi

Bu rehber, sinasamaki'nin (Ian Leshan) UI zanaatını kendin öğrenmen ve agent'lara aktarman
için. **Kurallar ve sayılar tek yerde duruyor:** [`skills/ui-craft`](../skills/ui-craft/SKILL.md)
ve onun `references/` dosyaları. Burada onları tekrar etmiyorum. Bu dosya neyi hangi sırayla
inceleyeceğini, gözünü nasıl eğiteceğini ve agent'ları nasıl yönlendireceğini anlatıyor.

## Önce bilmen gereken üç şey

1. **Adam kendine "non-designer" diyor.** Temeli Material ve Apple HIG; üstüne koyduğu her şeyi
   "his ile" ayarlıyor. Zevki doğuştan değil, bir **döngünün** ürünü: hot reload ile saniyeler
   içinde render et, bak, düzelt. AI'ın tasarımda zayıf olmasının ana sebebi de bu döngünün
   olmaması. Skill'in merkezinde bu yüzden "render et ve bak" adımı var.
2. **Gözünü, beğendiği uygulamaları birebir yeniden yaparak eğitmiş.** "Made in Compose"
   serisi bu: Timely, Airbnb, Dynamic Island, Flipboard. Kendi söylediğine göre "Timely'deki
   detaylar nasıl yapılmış?" sorusu kariyerini belirlemiş. Senin için de en hızlı yol bu.
3. **Repo'nun license'ı yok.** Fikirleri ve pattern'leri al, kodu kendi projene kopyalama.
   Skill de bu yüzden kendi yazdığı sketch'lerle ve pinned GitHub linkleriyle ilerliyor.

## Hazırlık

Bu oturumda klonladığım kopya geçici bir klasördeydi. Kalıcı bir yere klonla:

```sh
git clone https://github.com/sinasamaki/ChromaDecks ~/StudioProjects/ChromaDecks
```

JDK 21 gerekiyor (Gradle 8.9, Android Studio'nun JDK 25'iyle çalışmıyor). Belirli bir deck'i
açma tarifi [sources.md](../skills/ui-craft/references/sources.md#chromadecks)'de. Deck'ler
arasında ←/→ ile gezilir. Her aşamada deck'i bir ekranda, ilgili `.kt` dosyasını diğerinde aç.

## Gözünü eğitmek

Her slaytta şu dört soruyu sor, cevabını bir satır not al:

- **Ne hareket ediyor, ne duruyor?** Her adımda genelde tek bir şey değişiyor. Değişeni bul.
- **Kaç tempo var?** Arka plan çok yavaş, içerik orta, dokunuş feedback'i hızlı. Üçünü ayır.
- **Işık nereden geliyor?** Border'ın üst kenarı mı parlak? Gölge altta mı?
- **Bu efekt hangi bilgiyi veriyor?** Cevap veremiyorsan o efekt muhtemelen orada değildir.
  Bulamadıysan bir daha bak.

Videoları 0.5x hızda izle. Bir geçişte duraklatıp frame frame ilerlet ve "bounce in, plain
out" gibi kalıpları yakalamaya çalış. **Squint test**'i de alışkanlık hâline getir: gözünü
kısınca ekranda en parlak ya da en doygun şey, en önemli şey mi?

## Çalışma planı: micro'dan macro'ya

Her aşamada aynı dört şey var: **aç** (deck ve dosya), **bak** (neye dikkat edeceğin),
**oku** (skill'deki ilgili bölüm), **yap** (alıştırma). Bir aşamayı alıştırmasını bitirmeden
kapatma: okumak tanımak içindir, yapmak ise öğrenmek için.

### 1. Spring hissi

- **Aç:** UI Delight deck'i, hover/press ve animated list item slaytları;
  `_talks/ui_delight/components/ListItem.kt` (683–714).
- **Bak:** Hover ile press tek bir değerin iki noktası (.5 ve 1). Glow o değerden türüyor;
  hover'dan press'e geçiş kesintisiz.
- **Oku:** [motion.md](../skills/ui-craft/references/motion.md): "The spring vocabulary" ve
  "One driver".
- **Yap:** Kendi projende bir kart yap ve aynı state geçişini üç şekilde uygula: `tween(300)`,
  `spring(StiffnessLow)`, `spring(StiffnessLow, MediumBouncy)`. Üçünü hızlıca tıklayıp bırak
  (interrupt et). Spring'in neden "kesilebilir" olduğunu elinde hisset. Sonra hover/press'i
  tek bir `focus` değerine bağla.

### 2. Fizik ve jest

- **Aç:** Timely deck'i, NumberDucking ve SetUp slaytları; `TimelyDial.kt` (98–161,
  250–261), `DuckingNumberDial.kt`.
- **Bak:** Binary tetikleyici "pop" ediyor, continuous falloff fiziksel hissettiriyor. Thumb
  bırakılınca en yakın dakikaya oturuyor (detent).
- **Oku:** motion.md, "Micro motion": drag, rubber band, detent, proximity.
- **Yap:** Bir slider yaz: bırakınca en yakın değere spring ile otursun, thumb'a yakın tick'ler
  mesafeyle orantılı uzasın, sınırın ötesine çekince rubber band ile direnç göstersin.

### 3. Renk

- **Aç:** Timely deck'inin 10 slaytını baştan sona geç, sadece renge bak;
  `TimelyTimerPresentation.kt` (62–75), `Colors.kt` (742–788).
- **Bak:** Her slayt hue'yu ring'de 3 adım kaydırıyor; arka plan ve kod renkleri birlikte
  800 ms'de geçiyor. Role'ler step'e bağlı, hue serbest.
- **Oku:** [color-depth.md](../skills/ui-craft/references/color-depth.md), ilk iki bölüm.
- **Yap:** Tek bir base hue'dan bir ekran teması türet (kart, arka plan gradient'i, accent,
  glow). Sonra base hue'yu değiştir: tema bozulmadan kalıyorsa sistemi doğru kurmuşsun.
  Kontrastı ölç; floor için skill'deki Defaults tablosuna bak.

### 4. Işık ve derinlik

- **Aç:** ChromaDial deck'i, dial showcase'ler; `MonthDurationPickerComponent.kt` (200–299),
  `TemperatureDialComponent.kt` (141–212); blog'da Airbnb month picker yazısı.
- **Bak:** Ay dial'ı altı ayrı katmandan oluşuyor: groove, glow leak, body, iç ışık, rim, çukur
  merkez. Her biri tek başına neredeyse görünmez.
- **Oku:** color-depth.md: "Surface recipes" ve "Glows".
- **Yap:** Bir dial thumb'ını katman katman yeniden kur. Her katmanı ayrı render et ve
  "tek başına neredeyse hiçbir şey" testini uygula. Sonra hepsini birlikte render et.

### 5. Tipografi ve okunabilirlik

- **Aç:** herhangi bir build slaytı; `ChromaTheme.kt`, `CodeIDE.kt`, `CodeBlock.kt`; commit
  `764757e` (`git show 764757e`).
- **Bak:** Content slaytında tek bir cümle bile yok. Dosya adı başlık işlevi görüyor, kod
  ≤ 58 kolon, hiyerarşi aynı boyutta ton farkıyla kuruluyor. 764757e onun kendi
  "okunabilirlik" düzeltmesi: ne değiştirdiğine tek tek bak.
- **Oku:** [type-layout.md](../skills/ui-craft/references/type-layout.md).
- **Yap:** Kendi uygulamandan bir ekranı al. Type scale'e indir, iki weight ve tonla hiyerarşi
  kur, de-emphasis için opacity ladder kullan. Önce/sonra render'larını yan yana koy.

### 6. Makro: anlatı ve geçişler

- **Aç:** dört video deck'i baştan sona; `SlidesPresenter.kt`, `BasicAnimations.kt`,
  `ListSlide.kt`.
- **Bak:** Sonraki deck'lerde başlık 3. slayta kayıyor (önce hook, sonra galeri). Kod hep
  state'ten üretiliyor. Tüm geçişler tek bir scroll spring'inden türüyor.
- **Oku:** [explainers.md](../skills/ui-craft/references/explainers.md).
- **Yap:** İşten bir konuyu (örneğin bir POS akışı) 5–6 slaytlık bir mini deck ile anlat:
  `initialState` + mutation'lar, kod state'ten türesin, tek bir canlı component olsun. Ya da
  aynı fikirleri bir onboarding akışına uygula.

**Bitirme projesi:** Beğendiğin bir uygulamadan küçük bir detay seç (bir buton, bir picker,
bir geçiş) ve "Made in Compose" usulü birebir yeniden yap. Haftada bir detay iyi bir tempo.

## Agent'ları yönlendirmek

**Skill'i çağır ve çerçeveyi ver.** Agent'a "güzel yap" demek yerine niyeti ve state'leri
söyle; render ve critique adımlarını skill zaten istiyor:

```text
ui-craft skill'ini kullan.
Intent: swipe-to-archive, eşiği geçince "bırakırsan arşivlenecek" bilgisini versin.
States: rest, hover, pressed, dragging, armed, released.
Sistem: base hue Lime, canvas Zinc900, tek complementary accent Purple.
Her state'i render et, checklist'e göre pass/fail yaz,
elle denemem gereken interaction'ları listele.
```

**Ortak kelime dağarcığı kullan.** Agent'a feedback verirken skill'deki terimleri kullan.
Prompt'ta, skill'de ve kodda aynı kelime geçince agent doğru bölüme daha güvenilir ulaşır.

| Terim | Anlamı | Örnek feedback |
| --- | --- | --- |
| one driver | etkileşim başına tek animated value, gerisi `lerp` | "glow ile scale ayrı animasyon, tek focus value'ya bağla" |
| physics for state, time for clocks | state'te spring, tween sadece renk/stagger/loop/morph | "bu offset `tween(300)`, `spring(Low)` yap" |
| bounce in, plain out | giriş yaylı, çıkış sade ve hızlı | "exit'te bounce var, plain out yap" |
| light from the top | border/highlight üstte parlak, gölge altta | "border düz gri, üstten alta α .3 → .05 gradient yap" |
| faint layers | derinlik tek güçlü katmandan değil, çok sayıda silik katmandan | "tek bir kalın glow var, 6/24/60 dp stack'e böl" |
| (hue, step) | her renk palette'te bir hue ve step | "bu hex nereden geldi? `(s+1).v300` kullan" |
| tempo tiers | arka plan yavaş, içerik orta, feedback hızlı | "arka plan içerikle aynı hızda, 4× yavaşlat" |
| proximity falloff | binary yerine mesafeyle orantılı tepki | "tick'ler aniden pop ediyor, 18°'lik falloff yap" |
| rubber band / detent | gidemeyeceği yerde direnç / bırakınca en yakın değere oturma | "sınırda duvar gibi duruyor, rubber band ekle" |
| opacity ladder | de-emphasis için 1 / .5 / .25 | "pasif item'ları küçültme, ladder ile geri çek" |
| one idea per step | aynı anda tek değişiklik | "zoom ile tab değişimi ayrı adımda, birleştir" |

**AI'ın tipik hataları ve skill'deki karşılığı:**
- Görmeden "oldu" diyor → step 4: render edilmemiş state "bitti" sayılmaz.
- `tween(300)` ve Material default'larına kaçıyor → Defaults tablosu.
- Her şeyi animate ediyor → "her efekt bir state'e karşılık gelmeli" ve motion.md'deki
  Restraint bölümü.
- Rastgele, gökkuşağı renkler kullanıyor → hue ring ve role tabloları.
- Hisle ilgili konuları değerlendiremiyor → step 6: agent, elle denemen gerekenleri sana
  söylemek zorunda. O kısmı sen yapacaksın.

## Okuma ve izleme sırası

1. KotlinConf 2026 konuşması ve Q&A'i: zihniyetin özeti.
2. Blog'da "How I prototype with colors": döngü ve palette.
3. Blog'da "Made in Compose: Airbnb Month Picker Dial": katmanlı derinlik.
4. mDevCamp workshop repo'su: bir component'i adım adım cilalamak.
5. Livestream röportajı: süreç, ilham kaynakları, AI'a bakışı.

Linklerin hepsi ve tam liste [sources.md](../skills/ui-craft/references/sources.md#his-writing)'de.

## Sınırlar

- Repo'yu kod olarak okuduk ve deck'leri açtık, ama geçiş sürelerini ekranda ölçmedik. Skill'deki
  "settle" süreleri spring sabitlerinden hesaplandı.
- Videolardaki anlatımı (voice-over) analiz etmedik. Bir adımın neden orada olduğu çoğu zaman
  çıkarım.
- Onun bazı dial yazıları gradient üzerinde kontrastta zayıf (1.7–2.8:1). Skill bunu
  düzeltiyor; o kısmı kopyalama.
