class Pic {
  String? name;
  String? path;

  Pic(this.name,this.path);

  Pic.fromJson(Map<String, dynamic> json){
    name = json['name'] ?? '';
    path = json['path'] ?? '';
  }
}