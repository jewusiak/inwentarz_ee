class Utils {
  // source: https://typeofweb.com/odmiana-rzeczownikow-przy-liczebnikach-jezyku-polskim
  // przykład: singularNominativ, pluralNominativ, pluralGenitive: komentarz, komentarze, komentarzy
  static String polishPlural(
      singularNominativ, pluralNominativ, pluralGenitive, value) {
    if (value == 1) {
      return singularNominativ;
    } else if (value % 10 >= 2 &&
        value % 10 <= 4 &&
        (value % 100 < 10 || value % 100 >= 20)) {
      return pluralNominativ;
    } else {
      return pluralGenitive;
    }
  }
}
