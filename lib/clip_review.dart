import 'package:flutter/material.dart';

class ClipSegment {
  final String thumbnailUrl;
  final Duration duration;
  
  ClipSegment(this.thumbnailUrl, this.duration);
}

class ClipReviewWidget extends StatelessWidget {
  final List<ClipSegment> clips;
  final void Function(int) onClipSelected;

  const ClipReviewWidget({required this.clips, required this.onClipSelected, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: clips.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final clip = clips[index];
          return GestureDetector(
            onTap: () => onClipSelected(index),
            child: Column(
              children: [
                Container(
                  width: 140,
                  height: 80,
                  decoration: BoxDecoration(
                    image: DecorationImage(image: NetworkImage(clip.thumbnailUrl), fit: BoxFit.cover),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                const SizedBox(height: 8),
                Text('${clip.duration.inSeconds} seconds'),
              ],
            ),
          );
        },
      ),
    );
  }
}
