import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_compress/video_compress.dart';
import '../theme/app_theme.dart';

/// 2026-11-27: videos of any size are shrunk on the phone (640x480 MP4) before
/// upload so even a long video goes up quickly; the server then brings every
/// video down to at most 2 MB. Shows a progress dialog while working.
/// Returns the compressed copy, the original when compressing isn't possible
/// but the file is still reasonable to upload (<= 80 MB), or null.
Future<XFile?> prepareVideo(BuildContext context, XFile v, String preparingLabel) async {
  final progress = ValueNotifier<double>(0);
  final sub = VideoCompress.compressProgress$.subscribe((p) => progress.value = p);
  final nav = Navigator.of(context, rootNavigator: true);
  showDialog<void>(
    context: context,
    barrierDismissible: false,
    useRootNavigator: true,
    builder: (ctx) => PopScope(
      canPop: false,
      child: AlertDialog(
        content: ValueListenableBuilder<double>(
          valueListenable: progress,
          builder: (_, p, __) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(preparingLabel),
              const SizedBox(height: 14),
              LinearProgressIndicator(value: p > 0 ? (p / 100).clamp(0.0, 1.0) : null),
              const SizedBox(height: 8),
              Text('${p.clamp(0, 100).toStringAsFixed(0)}%', style: const TextStyle(color: AppColors.textMuted)),
            ],
          ),
        ),
      ),
    ),
  );
  XFile? result;
  try {
    final info = await VideoCompress.compressVideo(
      v.path,
      quality: VideoQuality.Res640x480Quality,
      deleteOrigin: false,
      includeAudio: true,
      frameRate: 30,
    );
    final path = info?.path;
    if (path != null && path.isNotEmpty) {
      result = XFile(path, name: 'video.mp4', mimeType: 'video/mp4');
    }
  } catch (_) {
    result = null;
  } finally {
    sub.unsubscribe();
  }
  if (result == null) {
    try {
      if (await v.length() <= 80 * 1024 * 1024) result = v;
    } catch (_) {}
  }
  nav.pop();
  progress.dispose();
  return result;
}

final _videoExt = RegExp(r'\.(mp4|mov|m4v|webm|3gp)$', caseSensitive: false);

bool isVideoFile(XFile f) =>
    (f.mimeType ?? '').startsWith('video/') || _videoExt.hasMatch(f.name) || _videoExt.hasMatch(f.path);

/// Upload name for a picked file: photos are always JPEG after the picker shrinks them.
String uploadName(XFile f, int i) {
  if (!isVideoFile(f)) return 'photo_$i.jpg';
  final ext = RegExp(r'\.(\w+)$').firstMatch(f.name)?.group(1) ?? 'mp4';
  return 'video_$i.$ext';
}
