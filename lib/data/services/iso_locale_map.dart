/// ISO-639-3 -> BCP-47 locale, shared by both FlutterTtsService and
/// OnDeviceSttService — the OS's native TTS and speech-recognition engines
/// both key off the same locale identifiers. Covers the languages OS
/// engines most commonly ship real voices/recognizers for; anything not
/// listed here fails cleanly rather than guessing.
class IsoLocaleMap {
  static const Map<String, String> isoToLocale = {
    'eng': 'en-US', 'spa': 'es-ES', 'fra': 'fr-FR', 'deu': 'de-DE',
    'ita': 'it-IT', 'por': 'pt-PT', 'rus': 'ru-RU', 'jpn': 'ja-JP',
    'kor': 'ko-KR', 'cmn': 'zh-CN', 'yue': 'zh-HK', 'ara': 'ar-SA',
    'hin': 'hi-IN', 'nld': 'nl-NL', 'pol': 'pl-PL', 'tur': 'tr-TR',
    'vie': 'vi-VN', 'tha': 'th-TH', 'ind': 'id-ID', 'swe': 'sv-SE',
    'nor': 'nb-NO', 'fin': 'fi-FI', 'ell': 'el-GR', 'heb': 'he-IL',
    'ces': 'cs-CZ', 'hun': 'hu-HU', 'ukr': 'uk-UA', 'dan': 'da-DK',
    'ron': 'ro-RO', 'bul': 'bg-BG', 'hrv': 'hr-HR', 'slk': 'sk-SK',
    'cat': 'ca-ES', 'zul': 'zu-ZA', 'afr': 'af-ZA', 'swa': 'sw-KE',
    'ben': 'bn-BD', 'urd': 'ur-PK', 'tam': 'ta-IN', 'tel': 'te-IN',
    'mar': 'mr-IN', 'guj': 'gu-IN', 'kan': 'kn-IN', 'mal': 'ml-IN',
    'pan': 'pa-IN', 'fil': 'fil-PH', 'msa': 'ms-MY', 'khm': 'km-KH',
    'mya': 'my-MM', 'nep': 'ne-NP', 'sin': 'si-LK', 'kaz': 'kk-KZ',
    'kir': 'ky-KG', 'srp': 'sr-RS', 'slv': 'sl-SI', 'lit': 'lt-LT',
    'lav': 'lv-LV', 'est': 'et-EE', 'isl': 'is-IS', 'sqi': 'sq-AL',
    'amh': 'am-ET', 'som': 'so-SO', 'yor': 'yo-NG', 'ibo': 'ig-NG',
    'hau': 'ha-NG', 'xho': 'xh-ZA',
  };
}
