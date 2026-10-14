// R1: immutable — final fields, const constructors, copyWith.
class Profile {
  const Profile({required this.name, required this.group});

  // R3: defaults for a fresh profile come from a named constructor.
  const Profile.empty() : name = '', group = '';

  final String name;
  final String group;

  Profile copyWith({String? name, String? group}) =>
      Profile(name: name ?? this.name, group: group ?? this.group);
}
