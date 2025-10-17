import 'package:image_picker/image_picker.dart';

pickImage(ImageSource source) async {
  final ImagePicker _picker = ImagePicker();
  final pickedFile = await _picker.pickImage(source: source);
  if (pickedFile != null) {
    return await pickedFile.readAsBytes();
  }
  print("No image selected");
}
