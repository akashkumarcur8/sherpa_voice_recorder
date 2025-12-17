class Nudge {
  final String text;
  final bool positive; // true for “yes” / “partial yes”, false for NA/No

  Nudge({required this.text, required this.positive});
}