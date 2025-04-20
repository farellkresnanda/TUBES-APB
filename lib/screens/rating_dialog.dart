import 'package:flutter/material.dart';

class RatingDialog extends StatefulWidget {
  final void Function(int rating) onRated;

  const RatingDialog({super.key, required this.onRated});

  @override
  State<RatingDialog> createState() => _RatingDialogState();
}

class _RatingDialogState extends State<RatingDialog> {
  int selectedRating = 0;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Bantu Kami Menilai Aplikasi',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              return GestureDetector(
                onTap: () {
                  setState(() {
                    selectedRating = index + 1;
                  });

                  // Tutup dialog dan kembalikan rating ke pemanggil
                  Navigator.of(context).pop();
                  widget.onRated(selectedRating);
                },
                child: Icon(
                  Icons.star,
                  size: 32,
                  color: index < selectedRating ? Colors.orange : Colors.grey,
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
