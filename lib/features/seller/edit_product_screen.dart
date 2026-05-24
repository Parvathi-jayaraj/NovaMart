import 'package:novamart/services/cloudinary_service.dart';

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:novamart/services/seller_dashboard_service.dart';

class EditProductScreen extends StatefulWidget {
  final Map<String, dynamic> product;

  const EditProductScreen({
    super.key,
    required this.product,
  });

  @override
  State<EditProductScreen> createState() =>
      _EditProductScreenState();
}

class _EditProductScreenState
    extends State<EditProductScreen> {

  final service = SellerDashboardService();

  // =========================
  // IMAGE VARIABLES
  // =========================
  File? selectedImage;

  final ImagePicker picker =
      ImagePicker();

  // =========================
  // TEXT CONTROLLERS
  // =========================
  late TextEditingController
      nameController;

  late TextEditingController
      descriptionController;

  late TextEditingController
      priceController;

  // =========================
  // INIT STATE
  // =========================
  @override
  void initState() {
    super.initState();

    nameController = TextEditingController(
      text: widget.product['name'],
    );

    descriptionController =
        TextEditingController(
      text: widget.product['description'],
    );

    priceController =
        TextEditingController(
      text:
          widget.product['price'].toString(),
    );
  }

  // =========================
  // PICK IMAGE
  // =========================
  Future<void> pickImage() async {

    final XFile? image =
        await picker.pickImage(
      source: ImageSource.gallery,
    );

    if (image != null) {

      setState(() {

        selectedImage =
            File(image.path);
      });
    }
  }

  // =========================
  // UPDATE PRODUCT
  // =========================
  Future<void> updateProduct() async {

  String imageUrl =
      widget.product['imageUrl'];

  // =========================
  // IF NEW IMAGE SELECTED
  // =========================
  if (selectedImage != null) {

    final cloudinaryService =
        CloudinaryService();

    final uploadedImageUrl =
        await cloudinaryService
            .uploadImage(
      selectedImage!,
    );

    if (uploadedImageUrl != null) {

      imageUrl = uploadedImageUrl;
    }
  }

  // =========================
  // UPDATE FIRESTORE
  // =========================
  await service.updateProduct(

    productId: widget.product['id'],

    name: nameController.text.trim(),

    description:
        descriptionController.text.trim(),

    price: double.tryParse(
          priceController.text.trim(),
        ) ??
        0,

    imageUrl: imageUrl,
  );

  ScaffoldMessenger.of(context)
      .showSnackBar(

    const SnackBar(
      content: Text(
        "Product Updated",
      ),
    ),
  );

  Navigator.pop(context);
}


  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text(
          "Edit Product",
        ),
      ),

      body: SingleChildScrollView(

        padding: const EdgeInsets.all(16),

        child: Column(

          children: [

            // =========================
            // PRODUCT IMAGE
            // =========================
            GestureDetector(

              onTap: pickImage,

              child: Container(

                height: 180,
                width: double.infinity,

                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.grey,
                  ),

                  borderRadius:
                      BorderRadius.circular(12),
                ),

                child: selectedImage != null

                    // NEW SELECTED IMAGE
                    ? ClipRRect(

                        borderRadius:
                            BorderRadius.circular(12),

                        child: Image.file(
                          selectedImage!,
                          fit: BoxFit.cover,
                        ),
                      )

                    // EXISTING IMAGE
                    : ClipRRect(

                        borderRadius:
                            BorderRadius.circular(12),

                        child: Image.network(

                          widget.product['imageUrl'],

                          fit: BoxFit.cover,
                        ),
                      ),
              ),
            ),

            const SizedBox(height: 20),

            // =========================
            // PRODUCT NAME
            // =========================
            TextField(
              controller: nameController,

              decoration:
                  const InputDecoration(
                labelText: "Product Name",
                border:
                    OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            // =========================
            // PRICE
            // =========================
            TextField(
              controller: priceController,

              keyboardType:
                  TextInputType.number,

              decoration:
                  const InputDecoration(
                labelText: "Price",
                border:
                    OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            // =========================
            // DESCRIPTION
            // =========================
            TextField(
              controller:
                  descriptionController,

              maxLines: 4,

              decoration:
                  const InputDecoration(
                labelText: "Description",
                border:
                    OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 30),

            // =========================
            // UPDATE BUTTON
            // =========================
            SizedBox(
              width: double.infinity,
              height: 55,

              child: ElevatedButton(

                onPressed: updateProduct,

                child: const Text(
                  "Update Product",
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}