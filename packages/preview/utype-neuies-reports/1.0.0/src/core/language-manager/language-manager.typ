#import "@preview/linguify:0.4.2": set-database, linguify

// Temel yolu tanımla. [Define base path.]
#let _base-path = "/src/core/"

// Kullanıcı temel yolunu tanımla. [Define user base path.]
#let _user-base-path = "/template/assets/"

//  Dil yöneticisi klasörünün adı. [Folder name of language manager folder.]
#let _language-manager-folder-path = _base-path + "language-manager/"

// Desteklenen diller dosyasının yolu. [Define supported languages file path.]
#let _supported-languages-file-path = _language-manager-folder-path + "supported-languages.toml"

// Dil verilerinin kaydedileceği klasör adı. [Folder name that language data files saved.]
#let _languages-data-folder-name = "languages"

// Varsayılan dil verilerinin kaydedileceği yol. [Define default language data base path.]
#let _default-language-data-base-path = _language-manager-folder-path + _languages-data-folder-name + "/"

// Kullanıcı dil verilerinin kaydedileceği yol. [Define user language overrides base path.]
#let _user-language-overrides-base-path = _user-base-path + _languages-data-folder-name + "/"

// Desteklenen diller kaydını yükle. [Load the supported languages registry.]
#let _supported-languages = toml(_supported-languages-file-path).supported-languages

// Dil veri tabanının veri tipi. [Language database's data type.]
#let _language-database-data-type = "dict"

// Dil verilerinin toml dosyasındaki tanımı. [Language data definition in toml file.]
#let _language-data-toml-definition = "translations"

// Belirli bir dil dosyasını yükleyen fonksiyondur. [Function to load a specific language file.]\
// @param language-code (string): Dil verisini yüklemek istediğiniz dil. [Language code to load language data.]\
// @param file-path (string): Dil verisini yüklemek istediğiniz dosyanın yolu. [Language data file path to load language data.]
#let _load-language-data(language-code: none, file-path: none) = {
  if language-code in _supported-languages {
    return toml(file-path)
  }
  return (:)
}

// Dil verilerini ve kullanıcı dil üzerine yazmalarını birleştirerek birleştirilmiş veri tabanını oluştur. [Build the combined database with core languages and user language overrides.]\
// @param default-language (string): Dil belirtilmemişse kullanılacak varsayılan dil. [The default language code to use if no language is specified.]
#let _build-language-database(default-language: none) = {
  // Linguify paketi için dil veri tabanını tanımla. [Define language database for linguify package.]
  let language-database = (
    conf: (
      default-lang: default-language,
      data_type: _language-database-data-type,
    ),
    lang: (:),
  )

  // Her bir dil dosyasını yükle ve veri tabanına ekle. [Load each language file and add to database.]
  for (language-code, info) in _supported-languages {
    // Dil verisi toml dosyasının adını ve uzantısını al. [Get language data toml file name with extention.]
    let file-name-with-extention = _supported-languages.at(language-code).file-path

    // Varsayılan dil verilerinin dosya yolu. [Default language data file path.]
    let default-language-data-file-path = _default-language-data-base-path + file-name-with-extention

    // Kullanıcı dil üzerine yazma verilerinin dosya yolu. [User language overrides data file path.]
    let user-language-overrides-file-path = _user-language-overrides-base-path + file-name-with-extention

    // Varsayılan dil verilerini yükle. [Load default language data.]
    let default-language-data = _load-language-data(
      language-code: language-code,
      file-path: default-language-data-file-path,
    )

    // Varsayılan çevirileri al (eğer varsa). [Get default translations if there is.]
    let default-language-translations = if _language-data-toml-definition in default-language-data {
      default-language-data.translations
    } else {
      (:)
    }

    // Kullanıcı dil üzerine yazma verilerini yükle. [Load user language overrides data.]
    let user-language-overrides-data = _load-language-data(
      language-code: language-code,
      file-path: user-language-overrides-file-path,
    )

    // Kullanıcı çeviri üzerine yazmalarını al (eğer varsa). [Get user translation overrides if there is.]
    let user-translation-overrides = if _language-data-toml-definition in user-language-overrides-data {
      user-language-overrides-data.translations
    } else {
      (:)
    }

    // Varsayılan dil çevirileri ve kullanıcı çeviri üzerine yazmalarını birleştir (kullanıcı üzerine yazmaları son sağlandığı için önceliklidir). [Combine default language translations and user translation overrides (user translation overrides takes precedence because it is supplied last).]
    language-database.lang.insert(
      language-code,
      default-language-translations + user-translation-overrides,
    )
  }

  // Dil veri tabanını döndür. [Return the language database.]
  return language-database
}

// Dil veri tabanını oluştur ve başlat. [Build and init the language database.]
// @param default-language (string): Herhangi bir dil belirtilmediğinde kullanılacak varsayılan dil kodu. [The default language code to use if no language is specified.]
#let init-language-manager(default-language: none) = {
  let language-database = _build-language-database(default-language: default-language)

  // Linguify paketi için dil veri tabanını ayarla. [Set the database for linguify package.]
  set-database(language-database)
}

// Bir anahtar için çeviri al. [Get a translation for a key.]
// @param key (string): Aranacak çeviri anahtarı. [The translation key to lookup.]
// @param language-code (string): Çevirinin alınacağı dil kodu. [The language code to get translation for.]
// @return Çevrilmiş metin. [The translated string.]
#let translator(
  key: none,
  language-code: auto,
) = {
  // Linguafy paketini kullanarak çeviri al ve bunu döndür. [Get the translation using linguify package and return it.]
  return linguify(key, args: auto, default: auto, from: auto, lang: language-code)
}
