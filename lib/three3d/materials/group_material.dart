import './material.dart';

class GroupMaterial extends Material {
  List<Material>? children;

  GroupMaterial() : super() {
    type = "GroupMaterial";
  }
}
