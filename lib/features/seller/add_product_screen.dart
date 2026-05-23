import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../services/cloudinary_service.dart';
import '../../../models/product_model.dart';
import '../../../services/product_service.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {

  final TextEditingController nameController = TextEditingController();

  final TextEditingController descriptionController =
      TextEditingController();

  final TextEditingController priceController = TextEditingController();
//I ADDED THE BELOW 2 LINES
  File? selectedImage;

final ImagePicker picker = ImagePicker();

//ALSO I ADDED THIS 

Future<void> pickImage() async {

  final XFile? image =
      await picker.pickImage(source: ImageSource.gallery);

  if (image != null) {
    setState(() {
      selectedImage = File(image.path);
    });
  }
}

Future<void> uploadProduct() async {

  if (nameController.text.trim().isEmpty ||
      descriptionController.text.trim().isEmpty ||
      priceController.text.trim().isEmpty) {
    print("Fill all fields");
    return;
  }

  if (selectedImage == null) {
    print("No image selected");
    return;
  }

  try {

    final cloudinaryService = CloudinaryService();

    final imageUrl =
        await cloudinaryService.uploadImage(
      selectedImage!,
    );

    if (imageUrl == null) {
      print("Image upload failed");
      return;
    }

    final productId =
        DateTime.now().millisecondsSinceEpoch.toString();

   // final currentUser =
      //  FirebaseAuth.instance.currentUser;

final currentUser = FirebaseAuth.instance.currentUser;

if (currentUser == null) {
  print("User not logged in");
  return;
}

    final product = ProductModel(
      id: productId,
      name: nameController.text.trim(),
      description:
          descriptionController.text.trim(),
     // price: double.parse(
       // priceController.text.trim(),
     // ),
     price: double.tryParse(priceController.text.trim()) ?? 0.0,
      imageUrl: imageUrl,
      sellerId: currentUser.uid,
      sellerName: currentUser.email ?? "Seller",
       createdAt: DateTime.now(),
    );

    await ProductService().uploadProduct(product);

    print("Product Uploaded Successfully");

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content:
            Text("Product Uploaded Successfully"),
      ),
    );

  } catch (e) {

    print(e.toString());

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(e.toString()),
      ),
    );
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Product"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            // Product Image Placeholder i ADDED UPTO LINE NO 73
           GestureDetector(
  onTap: pickImage,
  child: Container(
    height: 180,
    width: double.infinity,
    decoration: BoxDecoration(
      border: Border.all(color: Colors.grey),
      borderRadius: BorderRadius.circular(12),
    ),
    child: selectedImage != null
        ? ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.file(
              selectedImage!,
              fit: BoxFit.cover,
            ),
          )
        : const Center(
            child: Text("Tap to Select Image"),
          ),
  ),
),

            const SizedBox(height: 20),

            // Product Name
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: "Product Name",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            // Description
            TextField(
              controller: descriptionController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: "Description",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            // Price
            TextField(
              controller: priceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Price",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 30),

            // Add Product Button
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: uploadProduct,
                child: const Text(
                  "Add Product",
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}