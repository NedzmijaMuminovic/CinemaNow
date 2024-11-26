import 'dart:convert';
import 'package:flutter/material.dart';

class BaseCard extends StatelessWidget {
  final String imageUrl;
  final List<Widget> content;
  final List<Widget> actions;
  final double imageHeight;

  const BaseCard({
    super.key,
    required this.imageUrl,
    required this.content,
    required this.actions,
    this.imageHeight = 400,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[850],
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          ClipRRect(
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(16.0)),
            child: imageUrl.startsWith('data:image')
                ? Container(
                    height: imageHeight,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image:
                            MemoryImage(base64Decode(imageUrl.split(',').last)),
                        fit: BoxFit.cover,
                        alignment: Alignment.topCenter,
                      ),
                    ),
                  )
                : Image.asset(
                    imageUrl,
                    height: imageHeight,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    alignment: Alignment.topCenter,
                  ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: content,
              ),
            ),
          ),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
            decoration: const BoxDecoration(
              borderRadius:
                  BorderRadius.vertical(bottom: Radius.circular(16.0)),
            ),
            child: _buildActionButtons(),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    if (actions.isEmpty) return const SizedBox.shrink();

    if (actions.length == 1) {
      return Center(
        child: actions[0],
      );
    }

    if (actions.length == 3) {
      return Column(
        children: [
          Center(
            child: actions[0],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 120,
                child: actions[1],
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 120,
                child: actions[2],
              ),
            ],
          ),
        ],
      );
    }

    final rows = (actions.length / 2).ceil();
    return Column(
      children: List.generate(rows, (rowIndex) {
        final startIndex = rowIndex * 2;
        final endIndex = (startIndex + 2).clamp(0, actions.length);
        final rowButtons = actions.sublist(startIndex, endIndex);

        return Padding(
          padding: EdgeInsets.only(top: rowIndex > 0 ? 8.0 : 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (var i = 0; i < rowButtons.length; i++) ...[
                if (i > 0) const SizedBox(width: 8),
                SizedBox(
                  width: 120,
                  child: rowButtons[i],
                ),
              ],
            ],
          ),
        );
      }),
    );
  }
}
