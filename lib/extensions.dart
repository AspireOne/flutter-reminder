extension DurationExtensions on Duration {
  int inMinutesRoundedUp() {
    return inMinutes + ((inSeconds % 60) > 0 ? 1 : 0);
  }
}