import 'package:flutter/material.dart';
import '../models/product.dart';

class ProductGridItem extends StatelessWidget {
  final Product product;
  final bool isSelected;
  final bool selectionMode;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final void Function(bool) onToggleEnabled;
  final VoidCallback onDelete;

  const ProductGridItem({
    super.key,
    required this.product,
    required this.isSelected,
    required this.selectionMode,
    required this.onTap,
    required this.onLongPress,
    required this.onToggleEnabled,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Card(
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
        ),
        color: isSelected ? Colors.blue.shade100 : Colors.white,
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  height: 120,
                  child: Center(
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: Image.network(
                          product.imagePath ?? '',
                          fit: BoxFit.cover,
                          errorBuilder: (ctx, err, st) => const Icon(
                            Icons.image_not_supported,
                            size: 50,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Part: ${product.partNumber ?? 'N/A'}',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '₹${product.sellingPrice}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                          Text(
                            'Stock: ${product.stock}',
                            style: TextStyle(
                              color: product.stock > 0
                                  ? Colors.grey.shade700
                                  : Colors.redAccent,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (!selectionMode)
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          const Text('Enabled'),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Switch(
                              value: product.enabled,
                              onChanged: onToggleEnabled,
                              activeColor: Colors.redAccent,
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      iconSize: 20,
                      padding: EdgeInsets.zero,
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      onPressed: onDelete,
                      tooltip: 'Delete',
                    ),
                  ],
                ),
              ),
            if (selectionMode)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Colors.black.withOpacity(0.3)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: isSelected
                      ? const Icon(
                          Icons.check_circle,
                          color: Colors.white,
                          size: 30,
                        )
                      : null,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
