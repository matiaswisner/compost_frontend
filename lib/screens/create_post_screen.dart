import 'package:flutter/material.dart';

import '../models/material_model.dart';
import '../services/api_service.dart';
import '../services/location_service.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final ApiService apiService = ApiService();
  final LocationService locationService = LocationService();

  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final quantityController = TextEditingController();

  List<CompostMaterial> materials = [];

  CompostMaterial? selectedMaterial;

  String selectedType = 'OFFER';

  bool loading = false;

  @override
  void initState() {
    super.initState();
    loadMaterials();
  }

  Future<void> loadMaterials() async {
    try {
      final result = await apiService.getMaterials();

      setState(() {
        materials = result;

        if (materials.isNotEmpty) {
          selectedMaterial = materials.first;
        }
      });
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> submitPost() async {
    if (selectedMaterial == null) return;

    setState(() {
      loading = true;
    });

    try {
      final position = await locationService.getCurrentLocation();

      await apiService.createPost(
        title: titleController.text,
        description: descriptionController.text,
        type: selectedType,
        quantity: double.tryParse(quantityController.text) ?? 0,
        unit: 'KG',
        materialId: selectedMaterial!.id,
        lat: position.latitude,
        lng: position.longitude,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Publicación creada correctamente'),
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
        ),
      );
    }

    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5FAFC),
      appBar: AppBar(
        title: const Text('Nueva publicación'),
        backgroundColor: const Color(0xFF6EC1E4),
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          TextField(
            controller: titleController,
            decoration: const InputDecoration(
              labelText: 'Título',
              border: OutlineInputBorder(),
            ),
          ),

          const SizedBox(height: 16),

          TextField(
            controller: descriptionController,
            maxLines: 4,
            decoration: const InputDecoration(
              labelText: 'Descripción',
              border: OutlineInputBorder(),
            ),
          ),

          const SizedBox(height: 16),

          TextField(
            controller: quantityController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Cantidad',
              border: OutlineInputBorder(),
            ),
          ),

          const SizedBox(height: 16),

          DropdownButtonFormField<String>(
            value: selectedType,
            items: const [
              DropdownMenuItem(
                value: 'OFFER',
                child: Text('Ofrezco'),
              ),
              DropdownMenuItem(
                value: 'NEED',
                child: Text('Necesito'),
              ),
            ],
            onChanged: (value) {
              setState(() {
                selectedType = value!;
              });
            },
            decoration: const InputDecoration(
              labelText: 'Tipo',
              border: OutlineInputBorder(),
            ),
          ),

          const SizedBox(height: 16),

          DropdownButtonFormField<CompostMaterial>(
            value: selectedMaterial,
            items: materials.map((material) {
              return DropdownMenuItem(
                value: material,
                child: Text(material.name),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                selectedMaterial = value;
              });
            },
            decoration: const InputDecoration(
              labelText: 'Material',
              border: OutlineInputBorder(),
            ),
          ),

          const SizedBox(height: 24),

          ElevatedButton(
            onPressed: loading ? null : submitPost,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2E7D32),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: loading
                ? const CircularProgressIndicator(
              color: Colors.white,
            )
                : const Text(
              'Crear publicación',
              style: TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}