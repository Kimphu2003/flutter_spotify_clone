import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spotify_clone/core/theme/app_pallete.dart';
import 'package:flutter_spotify_clone/core/utils.dart';
import 'package:flutter_spotify_clone/core/widgets/custom_field.dart';
import 'package:flutter_spotify_clone/features/home/repositories/HomeRepository.dart';
import 'package:flutter_spotify_clone/features/home/view/widgets/audio_wave.dart';
import 'package:flutter_spotify_clone/features/home/viewmodel/home_viewmodel.dart';

import '../../../../core/widgets/loader.dart';

class UploadSongPage extends ConsumerStatefulWidget {
  const UploadSongPage({super.key});

  @override
  ConsumerState<UploadSongPage> createState() => _UploadSongPage();
}

class _UploadSongPage extends ConsumerState<UploadSongPage> {
  final songNameController = TextEditingController();
  final artistController = TextEditingController();
  Color selectedColor = Palette.cardColor;
  File? selectedImage;
  File? selectedAudio;
  final formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    super.dispose();
    songNameController.dispose();
    artistController.dispose();
  }

  void selectAudio() async {
    try {
      final pickedAudio = await pickAudio();
      if (pickedAudio != null) {
        setState(() {
          selectedAudio = pickedAudio;
        });
      }
    } catch (e) {
      print("Error in selectAudio: $e");
    }
  }

  void selectImage() async {
    try {
      final pickedImage = await pickImage();
      if (pickedImage != null) {
        setState(() {
          selectedImage = pickedImage;
        });
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(
      homeViewModelProvider.select((val) => val?.isLoading == true),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Center(child: Text('Upload song')),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: () async {
              if (formKey.currentState!.validate() &&
                  selectedImage != null &&
                  selectedAudio != null) {
                ref
                    .read(homeViewModelProvider.notifier)
                    .uploadSong(
                      selectedAudio!,
                      selectedImage!,
                      songNameController.text,
                      artistController.text,
                      selectedColor,
                    );
              } else {
                showSnackBar(context, 'Missing fields');
              }
            },
          ),
        ],
      ),
      body:
          isLoading
              ? const Loader()
              : SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Form(
                    key: formKey,
                    child: Column(
                      children: [
                        GestureDetector(
                          onTap: selectImage,
                          child:
                              selectedImage != null
                                  ? SizedBox(
                                    height: 150,
                                    width: double.infinity,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: Image.file(
                                        selectedImage!,
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                  )
                                  : DottedBorder(
                                    color: Palette.borderColor,
                                    dashPattern: const [10, 4],
                                    radius: const Radius.circular(10),
                                    borderType: BorderType.RRect,
                                    strokeCap: StrokeCap.square,
                                    child: SizedBox(
                                      height: 150,
                                      width: double.infinity,
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.folder_open, size: 40),
                                          const SizedBox(height: 15),
                                          const Text(
                                            'Select the thumbnail for your song',
                                            style: TextStyle(fontSize: 15),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                        ),
                        const SizedBox(height: 40),
                        selectedAudio != null
                            ? AudioWave(path: selectedAudio!.path)
                            : CustomField(
                              hintText: 'Pick song',
                              controller: null,
                              readOnly: true,
                              onTap: selectAudio,
                            ),
                        const SizedBox(height: 20),
                        CustomField(
                          hintText: 'Artist ',
                          controller: artistController,
                        ),
                        const SizedBox(height: 20),
                        CustomField(
                          hintText: 'Song Name ',
                          controller: songNameController,
                        ),
                        const SizedBox(height: 20),
                        ColorPicker(
                          pickersEnabled: {ColorPickerType.wheel: true},
                          color: selectedColor,
                          onColorChanged: (Color color) {
                            setState(() {
                              selectedColor = color;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
    );
  }
}
