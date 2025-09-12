import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PhotoViewPage extends StatelessWidget {
  final String imagePath;

  const PhotoViewPage({Key? key, required this.imagePath}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'View Photo',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: Hero(
          tag: imagePath,
          child: Image.asset(imagePath, fit: BoxFit.contain),
        ),
      ),
    );
  }
}
