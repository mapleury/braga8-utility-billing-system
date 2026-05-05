import 'package:flutter/material.dart';

class TableCard extends StatelessWidget {
  final String? prefix;
  final String? main;
  final String? suffix;
  final List<String> columns;
  final List<Map<String, dynamic>> data;
  final List<Widget> Function(Map<String, dynamic> item) rowBuilder;
  final Function(Map<String, dynamic> item)? onRowTap;
  final bool showUnitCount;
  final String? suffixText;
  final Map<int, TableColumnWidth>? columnWidths; // kept for API compatibility

  const TableCard({
    super.key,
    this.onRowTap,
    this.prefix,
    this.main,
    this.suffix,
    required this.columns,
    required this.data,
    required this.rowBuilder,
    this.showUnitCount = true,
    this.suffixText,
    this.columnWidths,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── HEADER ──────────────────────────────────────────────────────
          if (prefix != null || main != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.06),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
              ),
              child: Row(
                children: [
                  if (prefix != null)
                    Text(
                      prefix!,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  const SizedBox(width: 8),
                  if (main != null)
                    Expanded(
                      child: Text(
                        main!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  if (suffixText != null)
                    Text(
                      suffixText!,
                      style: const TextStyle(
                        color: Colors.white38,
                        fontSize: 14,
                      ),
                    ),
                ],
              ),
            ),

          // ── TABLE (horizontal scrollable) ────────────────────────────
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: DataTable(
              border: TableBorder(
                verticalInside: BorderSide(color: Colors.white10, width: 0.5),
                horizontalInside: BorderSide(color: Colors.white10, width: 0.5),
                top: BorderSide(color: Colors.white30, width: 0.5),
                bottom: BorderSide(color: Colors.white30, width: 0.5),
                left: BorderSide(color: Colors.white30, width: 0.5),
                right: BorderSide(color: Colors.white30, width: 0.5),
              ),
              headingRowColor: WidgetStateProperty.all(
                Colors.white.withValues(alpha: 0.06),
              ),
              headingRowHeight: 42,
              dataRowMinHeight: 48,
              dataRowMaxHeight: 52,
              columnSpacing: 20,
              horizontalMargin: 12,
              dividerThickness: 0,
              // ── COLUMNS ────────────────────────────────────────────────
              columns: columns
                  .map(
                    (col) => DataColumn(
                      label: Text(
                        col,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  )
                  .toList(),

              // ── ROWS ───────────────────────────────────────────────────
              rows: data.map((item) {
                final cells = rowBuilder(item);
                return DataRow(
                  cells: cells
                      .map(
                        (widget) => DataCell(
                          widget,
                          onTap: onRowTap != null
                              ? () => onRowTap!.call(item)
                              : null,
                        ),
                      )
                      .toList(),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
