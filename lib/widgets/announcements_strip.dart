import 'package:flutter/material.dart';
import '../models/announcement.dart';

class AnnouncementsStrip extends StatelessWidget {
  final List<Announcement> items;
  final void Function(int index) onClose;

  const AnnouncementsStrip({
    super.key,
    required this.items,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
  child: Container(
    width: double.infinity,
    margin: const EdgeInsets.symmetric(horizontal: 16),
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(0.15),
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: Colors.white.withOpacity(0.2)),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.15),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 8, bottom: 4),
          child: Text(
            '📣 Announcements',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 16,
              color: Colors.white,
              letterSpacing: 0.3,
            ),
          ),
        ),
        SizedBox(
          height: 84,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 2),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (context, i) {
              final a = items[i];
              return Dismissible(
                key: ValueKey(a.title + i.toString()),
                direction: DismissDirection.up,
                onDismissed: (_) => onClose(i),
                child: Container(
                  width: 300,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: const Color(0xFFE9E2E1)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(.12),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: a.tint.withOpacity(.12),
                          shape: BoxShape.circle,
                          border:
                              Border.all(color: a.tint.withOpacity(.28)),
                        ),
                        child: Icon(a.icon, color: a.tint),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              a.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w800),
                            ),
                            if (a.subtitle != null)
                              Text(
                                a.subtitle!,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    color: Color(0xFF6E6A69)),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        visualDensity: VisualDensity.compact,
                        onPressed: () => onClose(i),
                        icon: const Icon(Icons.close,
                            size: 18, color: Color(0xFF8C8887)),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    ),
  ),
);

  }
}
