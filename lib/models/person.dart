class Person {
  String name;
  String address;
  String contact;

  Person({required this.name, required this.address, required this.contact});

  // Convert a Person object into a Map to store in Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'address': address,
      'contact': contact,
    };
  }

  // Create a Person object from a Map (retrieved from Firestore)
  factory Person.fromMap(Map<String, dynamic> map) {
    return Person(
      name: map['name'],
      address: map['address'],
      contact: map['contact'],
    );
  }
}
