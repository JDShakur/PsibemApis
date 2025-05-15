import 'package:flutter/material.dart';

class ProfilePictureSelector extends StatefulWidget {
  final List<String> availablePictures;
  final String currentPicture;
  final ValueChanged<String> onPictureSelected;
  final double mainPictureSize;
  final Color accentColor;

  const ProfilePictureSelector({
    super.key,
    required this.availablePictures,
    required this.currentPicture,
    required this.onPictureSelected,
    this.mainPictureSize = 120,
    this.accentColor = const Color(0xFF81C7C6),
  });

  @override
  State<ProfilePictureSelector> createState() => _ProfilePictureSelectorState();
}

class _ProfilePictureSelectorState extends State<ProfilePictureSelector> {
  late String _selectedPicture;

  @override
  void initState() {
    super.initState();
    _selectedPicture = widget.currentPicture;
  }

  void _showSelectionModal() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return _PictureSelectionModal(
          availablePictures: widget.availablePictures,
          selectedPicture: _selectedPicture,
          onPictureSelected: (picture) {
            setState(() => _selectedPicture = picture);
            widget.onPictureSelected(picture);
            Navigator.pop(context);
          },
          accentColor: widget.accentColor,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        Container(
          width: widget.mainPictureSize,
          height: widget.mainPictureSize,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.mainPictureSize * 0.25),
            image: DecorationImage(
              image: _selectedPicture.startsWith('http')
                  ? NetworkImage(_selectedPicture) as ImageProvider
                  : AssetImage(_selectedPicture),
              fit: BoxFit.cover,
            ),
            border: Border.all(
              color: Colors.white,
              width: 3,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: widget.accentColor,
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white,
              width: 2,
            ),
          ),
          child: IconButton(
            icon: const Icon(Icons.edit, color: Colors.white, size: 20),
            onPressed: _showSelectionModal,
          ),
        ),
      ],
    );
  }
}

class _PictureSelectionModal extends StatelessWidget {
  final List<String> availablePictures;
  final String selectedPicture;
  final ValueChanged<String> onPictureSelected;
  final Color accentColor;

  const _PictureSelectionModal({
    required this.availablePictures,
    required this.selectedPicture,
    required this.onPictureSelected,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Escolha sua foto de perfil',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: accentColor,
              ),
            ),
            const SizedBox(height: 16),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 1,
              ),
              itemCount: availablePictures.length,
              itemBuilder: (context, index) {
                final picture = availablePictures[index];
                return GestureDetector(
                  onTap: () => onPictureSelected(picture),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(
                        color: selectedPicture == picture
                            ? accentColor
                            : Colors.transparent,
                        width: 3,
                      ),
                      image: DecorationImage(
                        image: picture.startsWith('http')
                            ? NetworkImage(picture) as ImageProvider
                            : AssetImage(picture),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: accentColor),
                ),
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Cancelar',
                  style: TextStyle(color: accentColor),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
