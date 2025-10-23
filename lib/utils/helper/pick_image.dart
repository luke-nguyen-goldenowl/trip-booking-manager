import 'package:image_picker/image_picker.dart';

pickImage(ImageSource source) async {
  final ImagePicker picker = ImagePicker();
  final pickedFile = await picker.pickImage(source: source);
  if (pickedFile != null) {
    return await pickedFile.readAsBytes();
  }
}
