class ProfileSummary {
  final String id;
  final String name;
  final String? description;
  final bool running;

  const ProfileSummary({
    required this.id,
    required this.name,
    this.description,
    this.running = false,
  });
}

