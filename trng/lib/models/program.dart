class Program {
  String name;
  int duration;

  Program({required this.name, required this.duration});

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'duration': duration,
    };
  }
}