import 'dart:convert';

// ignore_for_file: public_member_api_docs, sort_constructors_first

class Field {
  final String name;
  final String inputType;
  Field({
    required this.name,
    required this.inputType,
  });

  Field copyWith({
    String? name,
    String? inputType,
  }) {
    return Field(
      name: name ?? this.name,
      inputType: inputType ?? this.inputType,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'label': name,
      'type': inputType,
    };
  }

  factory Field.fromMap(Map<String, dynamic> map) {
    return Field(
      name: map['label'] as String,
      inputType: map['type'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory Field.fromJson(String source) =>
      Field.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() => 'Field(name: $name, inputType: $inputType)';

  @override
  bool operator ==(covariant Field other) {
    if (identical(this, other)) return true;

    return other.name == name && other.inputType == inputType;
  }

  @override
  int get hashCode => name.hashCode ^ inputType.hashCode;
}
