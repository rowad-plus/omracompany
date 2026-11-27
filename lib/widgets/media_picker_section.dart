import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/models.dart';
import '../services/media_prep.dart';
import '../theme/app_theme.dart';

/// Photos + videos of a hotel or bus (2026-11-27). Shows what is already saved
/// (tap ✕ to delete right away) and what was just picked (uploaded when the
/// sheet is saved). Any size: photos are shrunk by the picker, videos by
/// [prepareVideo], and the server shrinks both again.
class MediaPickerSection extends StatefulWidget {
  final List<CompanyMediaItem> existing;
  final List<XFile> pending;
  final Future<void> Function(CompanyMediaItem item) onDeleteExisting;
  final String Function(String key) t;

  const MediaPickerSection({
    super.key,
    required this.existing,
    required this.pending,
    required this.onDeleteExisting,
    required this.t,
  });

  @override
  State<MediaPickerSection> createState() => _MediaPickerSectionState();
}

class _MediaPickerSectionState extends State<MediaPickerSection> {
  final _picker = ImagePicker();
  final Set<int> _deleting = {};

  Future<void> _addPhotos() async {
    final picked = await _picker.pickMultiImage(maxWidth: 1600, maxHeight: 1600, imageQuality: 75);
    if (picked.isNotEmpty && mounted) setState(() => widget.pending.addAll(picked));
  }

  Future<void> _addVideo() async {
    final v = await _picker.pickVideo(source: ImageSource.gallery);
    if (v == null || !mounted) return;
    final ready = await prepareVideo(context, v, widget.t('preparing_video'));
    if (!mounted) return;
    if (ready == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(widget.t('err_video_too_big'))));
      return;
    }
    setState(() => widget.pending.add(ready));
  }

  Widget _tile({required Widget child, required VoidCallback? onRemove, bool busy = false}) {
    return SizedBox(
      width: 78,
      height: 78,
      child: Stack(
        children: [
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Container(color: AppColors.border.withValues(alpha: 0.4), child: child),
            ),
          ),
          if (busy) const Positioned.fill(child: Center(child: CircularProgressIndicator(strokeWidth: 2))),
          if (onRemove != null && !busy)
            Positioned(
              top: 2,
              right: 2,
              child: InkWell(
                onTap: onRemove,
                child: Container(
                  padding: const EdgeInsets.all(3),
                  decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                  child: const Icon(Icons.close, size: 14, color: Colors.white),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _videoIcon({bool processing = false}) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.play_circle_fill, size: 30, color: AppColors.textMuted),
            if (processing) Text(widget.t('media_processing'), style: const TextStyle(fontSize: 9.5, color: AppColors.textMuted)),
          ],
        ),
      );

  @override
  Widget build(BuildContext context) {
    final t = widget.t;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(t('section_photos_videos'), style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(t('media_auto_shrink_hint'), style: const TextStyle(fontSize: 11.5, color: AppColors.textMuted)),
        const SizedBox(height: 10),
        if (widget.existing.isNotEmpty || widget.pending.isNotEmpty) ...[
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final m in widget.existing)
                _tile(
                  busy: _deleting.contains(m.id),
                  onRemove: () async {
                    setState(() => _deleting.add(m.id));
                    await widget.onDeleteExisting(m);
                    if (mounted) setState(() => _deleting.remove(m.id));
                  },
                  child: m.isVideo
                      ? _videoIcon(processing: !m.ready)
                      : Image.network(m.url, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.image)),
                ),
              for (var i = 0; i < widget.pending.length; i++)
                _tile(
                  onRemove: () => setState(() => widget.pending.removeAt(i)),
                  child: isVideoFile(widget.pending[i])
                      ? _videoIcon()
                      : FutureBuilder(
                          future: widget.pending[i].readAsBytes(),
                          builder: (_, snap) => snap.hasData
                              ? Image.memory(snap.data!, fit: BoxFit.cover)
                              : const SizedBox.shrink(),
                        ),
                ),
            ],
          ),
          const SizedBox(height: 10),
        ],
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _addPhotos,
                icon: const Icon(Icons.add_photo_alternate_outlined, size: 18),
                label: Text(t('action_add_photos')),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _addVideo,
                icon: const Icon(Icons.videocam_outlined, size: 18),
                label: Text(t('action_add_video')),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
