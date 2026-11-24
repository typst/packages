// Showcase data: every example rendered in French and Arabic.
//
// One list, two languages. Keeping the pair in a single entry is what makes
// the document trustworthy: the French and the Arabic on a given row are the
// same program, so a block that is missing from one locale shows up as an
// obvious gap rather than as a quietly different example.
//
// The catalogue follows ProfCollege's ordering (Mouvement, Apparence, Son,
// Événements, Contrôle, Capteurs, Opérateurs, Variables, Listes, Stylo) so
// the two documents can be read side by side.

// ---------------------------------------------------------------------------
// Complete programs — the scripts from ProfCollege pages 359-361.
// ---------------------------------------------------------------------------

#let programs = (
  (
    title: [Script de base],
    fr: "quand @greenFlag est cliqué
avancer de (50) pas
répéter (10) fois
tourner @turnLeft de (36) degrés
avancer de (50) pas
fin",
    ar: "عند نقر @greenFlag
تحرك (50) خطوة
كرِّر (10) مرة
استدر @turnLeft (36) درجة
تحرك (50) خطوة
نهاية",
  ),
  (
    title: [Spirale au stylo],
    fr: "quand @greenFlag est cliqué
relever le stylo
aller à x: (0) y: (0)
s'orienter à (90)
stylo en position d'écriture
mettre [i v] à (1)
répéter indéfiniment
avancer de (i) pas
ajouter (1) à [i v]
tourner @turnRight de (121) degrés
fin",
    ar: "عند نقر @greenFlag
ارفع القلم
اذهب إلى الموضع س: (0) ص: (0)
اتجه نحو الاتجاه (90)
أنزل القلم
اجعل [i v] مساويًا (1)
كرِّر باستمرار
تحرك (i) خطوة
غيّر [i v] بمقدار (1)
استدر @turnRight (121) درجة
نهاية",
  ),
  (
    title: [Rosace],
    fr: "quand la touche (espace v) est pressée
effacer tout
mettre la couleur du stylo à [#ff0000]
mettre la taille du stylo à (10)
répéter (24) fois
stylo en position d'écriture
avancer de (20) pas
tourner @turnRight de (15) degrés
relever le stylo
fin",
    ar: "عند ضغط مفتاح (المسافة v)
امسح كل شيء
اجعل لون القلم مساويًا [#ff0000]
اجعل حجم القلم مساويًا (10)
كرِّر (24) مرة
أنزل القلم
تحرك (20) خطوة
استدر @turnRight (15) درجة
ارفع القلم
نهاية",
  ),
  (
    title: [Condition et compteur],
    fr: "quand @greenFlag est cliqué
mettre [score v] à (0)
répéter indéfiniment
si <(score) > (10)> alors
dire [Bravo !] pendant (2) secondes
sinon
ajouter (1) à [score v]
fin
fin",
    ar: "عند نقر @greenFlag
اجعل [النقاط v] مساويًا (0)
كرِّر باستمرار
إذا <(النقاط) > (10)>
قل [أحسنت!] لمدة (2) ثانية
وإلا
غيّر [النقاط v] بمقدار (1)
نهاية
نهاية",
  ),
  (
    title: [Attente et message],
    fr: "quand je reçois (message1 v)
attendre (1) secondes
dire [Bonjour !]
envoyer à tous (message1 v) et attendre
attendre jusqu'à ce que <(score) = (5)>
arrêter (tout v)",
    ar: "عندما أتلقى (رسالة1 v)
انتظر (1) ثانية
قل [مرحبا!]
بث (رسالة1 v) وانتظر
انتظر حتى <(النقاط) = (5)>
أوقف (الكل v)",
  ),
  (
    title: [Bloc personnalisé],
    fr: "define (Point)
stylo en position d'écriture
avancer de (20) pas
relever le stylo",
    ar: "تعريف (نقطة)
أنزل القلم
تحرك (20) خطوة
ارفع القلم",
  ),
)

// ---------------------------------------------------------------------------
// The block catalogue, category by category.
// ---------------------------------------------------------------------------

#let catalogue = (
  (
    name: [Mouvement],
    blocks: (
      ("avancer de (50) pas", "تحرك (50) خطوة"),
      ("tourner @turnRight de (50) degrés", "استدر @turnRight (50) درجة"),
      ("tourner @turnLeft de (50) degrés", "استدر @turnLeft (50) درجة"),
      ("aller à (position aléatoire v)", "اذهب إلى (موضع عشوائي v)"),
      ("aller à x: (50) y: (100)", "اذهب إلى الموضع س: (50) ص: (100)"),
      ("glisser en (1) secondes à x: (50) y: (50)", "انزلق خلال (1) ثانية إلى الموضع س: (50) ص: (50)"),
      ("s'orienter à (90)", "اتجه نحو الاتجاه (90)"),
      ("s'orienter vers (pointeur de souris v)", "اتجه نحو (مؤشر الفأرة v)"),
      ("ajouter (10) à x", "غيّر الموضع س بمقدار (10)"),
      ("mettre y à (10)", "اجعل الموضع ص مساويًا (10)"),
      ("rebondir si le bord est atteint", "ارتد إذا كنت عند الحافة"),
      ("fixer le sens de rotation (gauche-droite v)", "اجعل نمط الدوران (يسار-يمين v)"),
    ),
  ),
  (
    name: [Apparence],
    blocks: (
      ("dire [Bonjour !] pendant (2) secondes", "قل [مرحبا!] لمدة (2) ثانية"),
      ("dire [Bonjour !]", "قل [مرحبا!]"),
      ("penser à [Hmmm...] pendant (2) secondes", "فكِّر [همم...] لمدة (2) ثانية"),
      ("penser à [Hmmm...]", "فكِّر [همم...]"),
      ("ajouter (10) à la taille", "غيّر الحجم بمقدار (10)"),
      ("montrer", "أظهر"),
      ("cacher", "أخفِ"),
    ),
  ),
  (
    name: [Son],
    blocks: (
      ("jouer le son (Miaou v) jusqu'au bout", "شغِّل الصوت (مواء v) وانتظر انتهاءه"),
      ("jouer le son (Miaou v)", "شغِّل الصوت (مواء v)"),
      ("arrêter tous les sons", "أوقف كل الأصوات"),
      ("ajouter (-10) au volume", "غيّر شدة الصوت بمقدار (-10)"),
      ("mettre le volume à (100) %", "اجعل شدة الصوت مساويةً (100)%"),
    ),
  ),
  (
    name: [Événements],
    blocks: (
      ("quand @greenFlag est cliqué", "عند نقر @greenFlag"),
      ("quand la touche (espace v) est pressée", "عند ضغط مفتاح (المسافة v)"),
      ("quand l'arrière-plan bascule sur (arrière-plan1 v)", "عندما تتبدل الخلفية إلى (خلفية1 v)"),
      ("quand je reçois (message1 v)", "عندما أتلقى (رسالة1 v)"),
      ("envoyer à tous (message1 v)", "بث (رسالة1 v)"),
      ("envoyer à tous (message1 v) et attendre", "بث (رسالة1 v) وانتظر"),
    ),
  ),
  (
    name: [Contrôle],
    blocks: (
      ("attendre (1) secondes", "انتظر (1) ثانية"),
      ("répéter (10) fois\navancer de (10) pas\nfin", "كرِّر (10) مرة\nتحرك (10) خطوة\nنهاية"),
      ("répéter indéfiniment\navancer de (10) pas\nfin", "كرِّر باستمرار\nتحرك (10) خطوة\nنهاية"),
      ("si <(n) > (5)> alors\navancer de (10) pas\nfin", "إذا <(ن) > (5)>\nتحرك (10) خطوة\nنهاية"),
      ("si <(n) > (5)> alors\navancer de (10) pas\nsinon\nreculer\nfin", "إذا <(ن) > (5)>\nتحرك (10) خطوة\nوإلا\nتراجع\nنهاية"),
      ("attendre jusqu'à ce que <(n) > (5)>", "انتظر حتى <(ن) > (5)>"),
      ("arrêter (tout v)", "أوقف (الكل v)"),
    ),
  ),
  (
    name: [Capteurs],
    blocks: (
      ("touche le (pointeur de souris v) ?", "ملامس لـ (مؤشر الفأرة v)؟"),
      ("demander [Ton nom ?] et attendre", "اسأل [ما اسمك؟] وانتظر"),
      ("(réponse)", "(الإجابة)"),
      ("touche (espace v) pressée ?", "مفتاح (المسافة v) مضغوط؟"),
      ("souris pressée ?", "زر الفأرة مضغوط؟"),
      ("distance de (pointeur de souris v)", "المسافة إلى (مؤشر الفأرة v)"),
    ),
  ),
  (
    name: [Opérateurs],
    blocks: (
      ("((10) + (20))", "((10) + (20))"),
      ("((10) - (20))", "((10) - (20))"),
      ("((10) * (20))", "((10) × (20))"),
      ("((10) / (20))", "((10) ÷ (20))"),
      ("(nombre aléatoire entre (1) et (10))", "(عدد عشوائي بين (1) و (10))"),
      ("<(10) > (20)>", "<(10) > (20)>"),
      ("<(10) < (20)>", "<(10) < (20)>"),
      ("<(10) = (20)>", "<(10) = (20)>"),
      ("<<(a) > (b)> et <(c) > (d)>>", "<<(أ) > (ب)> و <(ج) > (د)>>"),
      ("<non <(a) > (b)>>", "<ليس <(أ) > (ب)>>"),
      ("(regrouper [pomme] et [banane])", "(اربط [تفاح] [موز])"),
    ),
  ),
  (
    name: [Variables],
    blocks: (
      ("mettre [ma variable v] à (0)", "اجعل [متغيري v] مساويًا (0)"),
      ("ajouter (1) à [ma variable v]", "غيّر [متغيري v] بمقدار (1)"),
      ("montrer la variable (ma variable v)", "أظهر المتغير (متغيري v)"),
      ("cacher la variable (ma variable v)", "أخفِ المتغير (متغيري v)"),
    ),
  ),
  (
    name: [Listes],
    blocks: (
      ("ajouter [chose] à (ListeA v)", "أضف [شيء] إلى (القائمةأ v)"),
      ("supprimer l'élément (1) de (ListeA v)", "احذف (1) من (القائمةأ v)"),
      ("insérer [chose] en position (1) de (ListeA v)", "أدرج [شيء] في الموقع (1) من (القائمةأ v)"),
      ("(élément (1) de (ListeA v))", "(العنصر (1) من (القائمةأ v))"),
      ("(longueur de (ListeA v))", "(طول (القائمةأ v))"),
      ("<(ListeA v) contient [chose] ?>", "<(القائمةأ v) تحتوي [شيء]؟>"),
    ),
  ),
  (
    name: [Stylo],
    blocks: (
      ("effacer tout", "امسح كل شيء"),
      ("stylo en position d'écriture", "أنزل القلم"),
      ("relever le stylo", "ارفع القلم"),
      ("mettre la couleur du stylo à [#ff0000]", "اجعل لون القلم مساويًا [#ff0000]"),
      ("mettre la taille du stylo à (10)", "اجعل حجم القلم مساويًا (10)"),
      ("ajouter (1) à la taille du stylo", "غيّر حجم القلم بمقدار (1)"),
      ("estampiller", "اطبع"),
    ),
  ),
)
