#import "../ascii-ipa.typ": *

#let run-tests = (tests, translator, name) => {
  for test in tests {
    assert(
      translator(test.at(0)) == test.at(1),
      message: name + ": " + test.at(0) + " -> " + test.at(1)
    )
    assert(
      translator(test.at(1), reverse: true) == test.at(0),
      message: name + " " + test.at(1) + " -> " + test.at(0)
    )
  }
}

#let xsampa-tests = (
  ("Ii:Uu:O:eE:@3:Q{VA:", "ɪiːʊuːɔːeɛːəɜːɒæʌɑː"),
  ("mnN", "mnŋ"),
  ("pttSkbddZg", "pttʃkbddʒɡ"),
  ("fTsSxvDzZh", "fθsʃxvðzʒh"),
  ("lrjw", "lrjw"),
  ("i1ueoa", "iɨueoa"),
  ("mm_jnn_j", "mmʲnnʲ"),
  ("pp_jtt_jkk_jbb_jdd_jgg_j", "ppʲttʲkkʲbbʲddʲɡɡʲ"),
  ("tsts_jts\\", "tstsʲtɕ"),
  ("ff_jss_js`s\\:xx_jvv_jzz_jz`z\\:G", "ffʲssʲʂɕːxxʲvvʲzzʲʐʑːɣ"),
  ("5l_jj", "ɫlʲj"),
  ("r_jr", "rʲr"),
  ("iui:u:aa:awaj", "iuiːuːaaːawaj"),
  ("ptt_?\\kq?bdd_?\\dZg", "pttˤkqʔbddˤdʒɡ"),
  ("fTss_?\\SxXX\\hvDzD_?\\z_?\\GR?\\", "fθssˤʃxχħhvðzðˤzˤɣʁʕ"),
  ("mn", "mn"),
  ("r", "r"),
  ("l5jw", "lɫjw"),
  ("E@`pO@`t", "ɛɚpɔɚt"),
)

#let praat-tests = (
  ("\\ici\\:f\\hsu\\:f\\ct\\:fe\\ef\\:f\\sw", "ɪiːʊuːɔːeɛːə"),
  ("\\er\\:f\\ab\\ae\\vt\\as\\:f", "ɜːɒæʌɑː"),
  ("mn\\ng", "mnŋ"),
  ("ptt\\shkbdd\\zh\\gs", "pttʃkbddʒɡ"),
  ("f\\tfs\\shxv\\dhz\\zhh", "fθsʃxvðzʒh"),
  ("lrjw", "lrjw"),
  ("i\\i-ueoa", "iɨueoa"),
  ("mm\\^jnn\\^j", "mmʲnnʲ"),
  ("pp\\^jtt\\^jkk\\^jbb\\^jdd\\^j\\gs\\gs\\^j", "ppʲttʲkkʲbbʲddʲɡɡʲ"),
  ("tsts\\^jt\\cc", "tstsʲtɕ"),
  ("ff\\^jss\\^j\\s.\\cc\\:fxx\\^jvv\\^j", "ffʲssʲʂɕːxxʲvvʲ"),
  ("zz\\^j\\z.\\zc\\:f\\gf", "zzʲʐʑːɣ"),
  ("\\l~l\\^jj", "ɫlʲj"),
  ("r\\^jr", "rʲr"),
  ("iui\\:fu\\:faa\\:fawaj", "iuiːuːaaːawaj"),
  ("ptt\\^9kq\\?gbdd\\^9d\\zh\\gs", "pttˁkqʔbddˁdʒɡ"),
  ("f\\tfss\\^9\\shx\\cf\\h-hv\\dh", "fθssˁʃxχħhvð"),
  ("z\\dh\\^9z\\^9\\gf\\ri\\9e", "zðˁzˁɣʁʕ"),
  ("mn", "mn"),
  ("r", "r"),
  ("l\\l~jw", "lɫjw"),
)

#let branner-tests = (
  ("Ii:Uu:c&:eE:@E&:a\"&ae)v&a\":", "ɪiːʊuːɔːeɛːəɜːɒæʌɑː"),
  ("mnng)", "mnŋ"),
  ("pttSkbdd3\"g", "pttʃkbddʒɡ"),
  ("fO-sSxvd-z3\"h", "fθsʃxvðzʒh"),
  ("lrjw", "lrjw"), ("ii-ueoa", "iɨueoa"),
  ("mmj^nnj^", "mmʲnnʲ"),
  ("ppj^ttj^kkj^bbj^ddj^ggj^", "ppʲttʲkkʲbbʲddʲɡɡʲ"),
  ("tstsj^tci)", "tstsʲtɕ"),
  ("ffj^ssj^sr)ci):xxj^vvj^zzj^zr)zi):g\"", "ffʲssʲʂɕːxxʲvvʲzzʲʐʑːɣ"),
  ("l~)lj^j", "ɫlʲj"),
  ("rj^r", "rʲr"), ("iui:u:aa:awaj", "iuiːuːaaːawaj"),
  ("ptt&g^kq?bdd&g^d3\"g", "pttˤkqʔbddˤdʒɡ"),
  ("fO-ss&g^SxXh-hvd-zd-&g^z&g^g\"R%?&", "fθssˤʃxχħhvðzðˤzˤɣʁʕ"),
  ("mn", "mn"),
  ("r", "r"),
  ("ll~)jw", "lɫjw"),
)

#let sil-tests = (
  ("i=i:u<u:o<:ee<:e=e>:o=a<u>a=:", "ɪiːʊuːɔːeɛːəɜːɒæʌɑː"),
  ("mnn>", "mnŋ"),
  ("ptts=kbddz=g<", "pttʃkbddʒɡ"),
  ("ft=ss=xvd=zz=h", "fθsʃxvðzʒh"),
  ("lrjw", "lrjw"),
  ("iI=ueoa", "iɨueoa"),
  ("mmj^nnj^", "mmʲnnʲ"),
  ("ppj^ttj^kkj^bbj^ddj^g<g<j^", "ppʲttʲkkʲbbʲddʲɡɡʲ"),
  ("tstsj^tc<", "tstsʲtɕ"),
  ("ffj^ssj^s<c<:xxj^vvj^zzj^z<z>:g=", "ffʲssʲʂɕːxxʲvvʲzzʲʐʑːɣ"),
  ("l~~lj^j", "ɫlʲj"),
  ("rj^r", "rʲr"),
  ("iui:u:aa:awaj", "iuiːuːaaːawaj"),
  ("ptt?<^kq?=bdd?<^dz=g<", "pttˤkqʔbddˤdʒɡ"),
  ("ft=ss?<^s=xx=h>hvd=zd=?<^z?<^g=R>?<", "fθssˤʃxχħhvðzðˤzˤɣʁʕ"),
  ("mn", "mn"),
  ("r", "r"),
  ("ll~~jw", "lɫjw"),
)

#run-tests(branner-tests, branner, "Branner")
#run-tests(praat-tests, praat, "Praat")
#run-tests(sil-tests, sil, "SIL")
#run-tests(xsampa-tests, xsampa, "X-SAMPA")
