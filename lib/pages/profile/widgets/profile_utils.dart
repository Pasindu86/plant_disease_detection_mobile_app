/// Returns the initials from a full name string.
///
/// - If the name has 2+ parts, returns the first letter of the first two parts.
/// - If the name has 1 part, returns the first letter.
/// - If the name is empty, returns '?'.
String getInitials(String name) {
  if (name.isEmpty) return '?';
  final parts = name.trim().split(' ');
  if (parts.length >= 2) {
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }
  return name[0].toUpperCase();
}
