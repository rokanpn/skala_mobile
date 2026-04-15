import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/complaint_service.dart';

class NewComplaintScreen extends StatefulWidget {
  const NewComplaintScreen({super.key});

  @override
  State<NewComplaintScreen> createState() => _NewComplaintScreenState();
}

class _NewComplaintScreenState extends State<NewComplaintScreen> {
  final titleController = TextEditingController();
  final descController = TextEditingController();
  String selectedCategory = "ڕێگا";
  bool isLoading = false;

  // گۆڕدراوی وێنەکە
  File? _selectedImage;

  final List<String> categories = [
    "ڕێگا",
    "ئاو",
    "کارەبا",
    "پاکیژەکردن",
    "پارکەکان",
    "تر"
  ];

  // فەنکشنی هەڵبژاردنی وێنە
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      if (mounted) {
        setState(() => _selectedImage = File(pickedFile.path));
      }
    }
  }

  Future<void> submit() async {
    if (titleController.text.isEmpty || descController.text.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("تکایە هەموو خانەکان پڕ بکەرەوە")),
        );
      }
      return;
    }
    setState(() => isLoading = true);

    // وێنەکە دەنێرین بۆ سێرڤیسەکە
    final ok = await ComplaintService.create(
      title: titleController.text.trim(),
      description: descController.text.trim(),
      category: selectedCategory,
      mediaFile: _selectedImage,
    );

    if (mounted) {
      setState(() => isLoading = false);

      if (ok) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("سکاڵاکە بە سەرکەوتوویی ناردرا")),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("هەڵەیەک ڕوویدا لە کاتی ناردن")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("تۆمارکردنی سکاڵا"),
        backgroundColor: Colors.amber,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("ناونیشانی کورت",
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: titleController,
              decoration: InputDecoration(
                hintText: "بۆ نموونە: شکانی بۆری ئاو",
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 16),
            const Text("جۆری سکاڵا",
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(12),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: selectedCategory,
                  isExpanded: true,
                  items: categories
                      .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                      .toList(),
                  onChanged: (val) {
                    if (val != null && mounted) {
                      setState(() => selectedCategory = val);
                    }
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text("وردەکاری",
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: descController,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: "کێشەکە بە وردی ڕوون بکەرەوە...",
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 20),

            // وێنەکە پیشان دەدەین ئەگەر هەڵبژێردرابوو
            if (_selectedImage != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(_selectedImage!,
                      height: 200, width: double.infinity, fit: BoxFit.cover),
                ),
              ),

            // دوگمەی هەڵبژاردنی وێنە
            TextButton.icon(
              onPressed: _pickImage,
              icon: const Icon(Icons.add_a_photo, color: Colors.amber),
              label: const Text("زیادکردنی وێنە",
                  style: TextStyle(color: Colors.black)),
            ),

            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: isLoading ? null : submit,
                icon: isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2))
                    : const Icon(Icons.send_rounded),
                label:
                    const Text("ناردنی سکاڵا", style: TextStyle(fontSize: 16)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
