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
                  _buildStateChip(context),
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
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStateChip(BuildContext context) {
    Color chipColor;
    IconData icon;

    switch (search.state) {
      case 'Completed':
        chipColor = Colors.green;
        icon = Icons.check_circle;
        break;
      case 'InProgress':
        chipColor = Colors.blue;
        icon = Icons.search;
        break;
      case 'Failed':
        chipColor = Colors.red;
        icon = Icons.error;
        break;
      default:
        chipColor = Colors.grey;
        icon = Icons.help_outline;
    }

    return Chip(
      label: Text(
        search.state,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
        ),
      ),
      backgroundColor: chipColor,
      avatar: Icon(
        icon,
        color: Colors.white,
        size: 16,
      ),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }
}