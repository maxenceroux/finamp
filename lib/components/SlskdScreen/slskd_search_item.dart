import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/slskd_models.dart';

class SlskdSearchItem extends StatelessWidget {
  final SlskdSearch search;
  final VoidCallback? onTap;

  const SlskdSearchItem({
    Key? key,
    required this.search,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Calculate locked file count
    int lockedCount =
        search.results?.where((r) => !r.hasFreeUploadSlot).length ?? 0;
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      search.query,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  // State chip removed
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${search.resultCount} results',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                  Text(
                    DateFormat('MMM dd, HH:mm').format(search.searchedAt),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                  if (lockedCount > 0)
                    Row(
                      children: [
                        Icon(Icons.lock_outline,
                            color: Colors.red[400], size: 16),
                        const SizedBox(width: 4),
                        Text(
                          '$lockedCount locked',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.red[400],
                                  ),
                        ),
                      ],
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // State chip removed
}
