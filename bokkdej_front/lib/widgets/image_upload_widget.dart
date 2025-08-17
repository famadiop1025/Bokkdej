import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class ImageUploadWidget extends StatefulWidget {
  final String modelType; // 'menu', 'ingredients', 'bases'
  final int itemId;
  final String token;
  final Function(String imageUrl)? onImageUploaded;

  const ImageUploadWidget({
    Key? key,
    required this.modelType,
    required this.itemId,
    required this.token,
    this.onImageUploaded,
  }) : super(key: key);

  @override
  State<ImageUploadWidget> createState() => _ImageUploadWidgetState();
}

class _ImageUploadWidgetState extends State<ImageUploadWidget> {
  File? _selectedImage;
  XFile? _selectedWebImage; // Pour Flutter Web
  bool _isUploading = false;

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.photo_camera),
              title: Text('Prendre une photo'),
              onTap: () async {
                Navigator.pop(context);
                final XFile? image = await picker.pickImage(
                  source: ImageSource.camera,
                  imageQuality: 80,
                );
                if (image != null) {
                  setState(() {
                    if (kIsWeb) {
                      _selectedWebImage = image;
                      _selectedImage = null;
                    } else {
                      _selectedImage = File(image.path);
                      _selectedWebImage = null;
                    }
                  });
                }
              },
            ),
            ListTile(
              leading: Icon(Icons.photo_library),
              title: Text('Choisir depuis la galerie'),
              onTap: () async {
                Navigator.pop(context);
                final XFile? image = await picker.pickImage(
                  source: ImageSource.gallery,
                  imageQuality: 80,
                );
                if (image != null) {
                  setState(() {
                    if (kIsWeb) {
                      _selectedWebImage = image;
                      _selectedImage = null;
                    } else {
                      _selectedImage = File(image.path);
                      _selectedWebImage = null;
                    }
                  });
                }
              },
            ),
            ListTile(
              leading: Icon(Icons.cancel),
              title: Text('Annuler'),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _uploadImage() async {
    if (_selectedImage == null && _selectedWebImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Veuillez sélectionner une image'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (widget.itemId <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('ID d\'élément invalide'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isUploading = true;
    });

    try {
      var request = http.MultipartRequest(
        'PATCH',
        Uri.parse('http://localhost:8000/api/${widget.modelType}/${widget.itemId}/'),
      );
      
      request.headers['Authorization'] = 'Bearer ${widget.token}';
      
      if (kIsWeb && _selectedWebImage != null) {
        // Pour Flutter Web
        final bytes = await _selectedWebImage!.readAsBytes();
        request.files.add(http.MultipartFile.fromBytes(
          'image',
          bytes,
          filename: _selectedWebImage!.name,
        ));
      } else if (_selectedImage != null) {
        // Pour mobile/desktop
        request.files.add(await http.MultipartFile.fromPath('image', _selectedImage!.path));
      }

      var response = await request.send();
      String responseBody = await response.stream.bytesToString();
      
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Image uploadée avec succès'),
            backgroundColor: Colors.green,
          ),
        );
        
        // Réinitialiser
        setState(() {
          _selectedImage = null;
          _selectedWebImage = null;
        });
        
        // Callback pour notifier le parent
        if (widget.onImageUploaded != null) {
          widget.onImageUploaded!('updated');
        }
      } else {
        print('Erreur upload: ${response.statusCode}, body: $responseBody');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de l\'upload (${response.statusCode})'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print('Exception upload: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Gestion d\'image',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 12),
            
            // Zone de sélection d'image
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 150,
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey, style: BorderStyle.solid),
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.grey[100],
                ),
                child: (_selectedImage != null || _selectedWebImage != null)
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: kIsWeb && _selectedWebImage != null
                            ? FutureBuilder<Uint8List>(
                                future: _selectedWebImage!.readAsBytes(),
                                builder: (context, snapshot) {
                                  if (snapshot.hasData) {
                                    return Image.memory(snapshot.data!, fit: BoxFit.cover);
                                  }
                                  return Center(child: CircularProgressIndicator());
                                },
                              )
                            : _selectedImage != null
                                ? Image.file(_selectedImage!, fit: BoxFit.cover)
                                : Container(),
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_photo_alternate, size: 40, color: Colors.grey),
                          SizedBox(height: 8),
                          Text(
                            'Appuyer pour sélectionner une image',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
              ),
            ),
            
            SizedBox(height: 12),
            
            // Boutons d'action
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _pickImage,
                    icon: Icon(Icons.photo_library),
                    label: Text('Choisir'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isUploading ? null : _uploadImage,
                    icon: _isUploading 
                        ? SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Icon(Icons.cloud_upload),
                    label: Text(_isUploading ? 'Upload...' : 'Upload'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            
            // Bouton pour supprimer l'image sélectionnée
            if (_selectedImage != null || _selectedWebImage != null)
              Padding(
                padding: EdgeInsets.only(top: 8),
                child: TextButton.icon(
                  onPressed: () {
                    setState(() {
                      _selectedImage = null;
                      _selectedWebImage = null;
                    });
                  },
                  icon: Icon(Icons.clear, color: Colors.red),
                  label: Text('Supprimer la sélection', style: TextStyle(color: Colors.red)),
                ),
              ),
          ],
        ),
      ),
    );
  }
}