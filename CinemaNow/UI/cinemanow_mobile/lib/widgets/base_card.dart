import 'dart:convert';
import 'package:flutter/material.dart';

class BaseCard extends StatelessWidget {
  final String imageUrl;
  final List<Widget> content;
  final List<Widget>? actions;
  final double imageHeight;

  const BaseCard({
    super.key,
    required this.imageUrl,
    required this.content,
    this.actions,
    this.imageHeight = 200,
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
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: content,
              ),
            ),
          ),
          if (actions != null && actions!.isNotEmpty)
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              decoration: BoxDecoration(
                color: Colors.grey[850],
                borderRadius:
                    const BorderRadius.vertical(bottom: Radius.circular(16.0)),
              ),
              child: Row(
                mainAxisAlignment: actions!.length == 1
                    ? MainAxisAlignment.center
                    : MainAxisAlignment.spaceBetween,
                children: actions!,
              ),
            ),
        ],
      ),
    );
  }
}
