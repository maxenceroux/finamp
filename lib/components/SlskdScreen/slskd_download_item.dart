import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/slskd_models.dart';

class SlskdDownloadItem extends StatelessWidget {
  final SlskdDirectoryDownload download;
  final VoidCallback? onTap;

  const SlskdDownloadItem({
    Key? key,
    required this.download,
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
                      download.albumName,
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
              Text(
                'From: ${download.username}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${download.files.length} files • ${_formatSize(download.totalSize)}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: LinearProgressIndicator(
                      value: download.overallProgress / 100,
                      backgroundColor: Colors.grey[300],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _getProgressColor(download.state),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${download.overallProgress.toStringAsFixed(1)}%',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Started: ${DateFormat('MMM dd, HH:mm').format(download.startedAt)}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                  if (download.state == 'InProgress')
                    Text(
                      '${_formatSpeed(download.averageSpeed)}/s',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.blue[600],
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

    switch (download.state) {
      case 'Completed':
        chipColor = Colors.green;
        icon = Icons.check_circle;
        break;
      case 'InProgress':
        chipColor = Colors.blue;
        icon = Icons.downloading;
        break;
      case 'Queued':
        chipColor = Colors.orange;
        icon = Icons.schedule;
        break;
      default:
        chipColor = Colors.grey;
        icon = Icons.help_outline;
    }

    return Chip(
      label: Text(
        download.state,
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

  Color _getProgressColor(String state) {
    switch (state) {
      case 'Completed':
        return Colors.green;
      case 'InProgress':
        return Colors.blue;
      case 'Queued':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  String _formatSize(int bytes) {
    if (bytes < 1024) return '${bytes} B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  String _formatSpeed(double bytesPerSecond) {
    if (bytesPerSecond < 1024) return '${bytesPerSecond.toStringAsFixed(0)} B';
    if (bytesPerSecond < 1024 * 1024) {
      return '${(bytesPerSecond / 1024).toStringAsFixed(1)} KB';
    }
    return '${(bytesPerSecond / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}