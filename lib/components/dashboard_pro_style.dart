import 'package:flutter/material.dart';

class DashboardProStyle extends StatelessWidget {
  const DashboardProStyle({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _SectionCard(
            title: 'KPIs (Top Stats)',
            child: Column(
              children: [
                _KpiRow(
                  icon: Icons.calendar_today,
                  label: "Today's Sales",
                  value: '₱1,250',
                  color: Colors.red,
                ),
                _KpiRow(
                  icon: Icons.shopping_cart,
                  label: 'Items Sold Today',
                  value: '85',
                  color: Colors.brown,
                ),
                _KpiRow(
                  icon: Icons.payment,
                  label: 'Payment Type',
                  value: 'GCash (75%)',
                  color: Colors.purple,
                ),
                _KpiRow(
                  icon: Icons.star,
                  label: 'Top Product',
                  value: 'Softdrinks',
                  color: Colors.blue,
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          _SectionCard(
            title: 'Daily Sales Summary (Last 3 Days)',
            child: Column(
              children: [
                _SummaryRow(label: 'Jul 23 (Today)', value: '₱1,250', highlight: true),
                _SummaryRow(label: 'Jul 22', value: '₱980'),
                _SummaryRow(label: 'Jul 21', value: '₱1,400'),
                const SizedBox(height: 6),
                _ProRow(label: 'View more'),
              ],
            ),
          ),
          const SizedBox(height: 18),
          _SectionCard(
            title: 'Weekly & Monthly Totals',
            child: Column(
              children: [
                _SummaryRow(icon: Icons.calendar_view_week, label: 'This Week', value: '₱6,400'),
                _SummaryRow(icon: Icons.calendar_month, label: 'This Month', value: '₱28,750'),
                const SizedBox(height: 6),
                _ProRow(label: 'Compare Past Weeks'),
              ],
            ),
          ),
          const SizedBox(height: 18),
          _SectionCard(
            title: 'Progress Toward Sales Target',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Today's Goal: ₱2,000", style: TextStyle(fontWeight: FontWeight.w500)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: LinearProgressIndicator(
                        value: 0.63,
                        minHeight: 10,
                        backgroundColor: Colors.grey.shade200,
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text('63%', style: TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 8),
                _ProRow(label: 'Set Custom Targets'),
              ],
            ),
          ),
          const SizedBox(height: 18),
          _SectionCard(
            title: 'Top Products This Week',
            child: Column(
              children: [
                _SummaryRow(label: '1. Softdrinks', value: '₱1,200'),
                _SummaryRow(label: '2. Sardines', value: '₱980'),
                _SummaryRow(label: '3. Biscuits', value: '₱720'),
                const SizedBox(height: 6),
                _ProRow(label: 'View Top 10'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;
  const _SectionCard({required this.title, required this.child});
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              ),
              const Icon(Icons.more_horiz, size: 18, color: Colors.grey),
            ],
          ),
          const Divider(height: 18),
          child,
        ],
      ),
    );
  }
}

class _KpiRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  const _KpiRow({required this.icon, required this.label, required this.value, required this.color});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.5),
      child: Row(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 8),
          Expanded(child: Text(label, style: const TextStyle(fontSize: 14))),
          Text(value, style: TextStyle(fontWeight: FontWeight.w600, color: color, fontSize: 15)),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final IconData? icon;
  final String label;
  final String value;
  final bool highlight;
  const _SummaryRow({this.icon, required this.label, required this.value, this.highlight = false});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.5),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, size: 16, color: Colors.deepPurple),
            const SizedBox(width: 4),
          ],
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontWeight: highlight ? FontWeight.bold : FontWeight.normal,
                color: highlight ? Colors.deepPurple : Colors.black87,
                fontSize: 14,
              ),
            ),
          ),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        ],
      ),
    );
  }
}

class _ProRow extends StatelessWidget {
  final String label;
  const _ProRow({required this.label});
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(Icons.lock, size: 16, color: Colors.amber.shade700),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontWeight: FontWeight.w500, color: Colors.black54)),
        const SizedBox(width: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.amber.shade100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Text('Pro', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.amber)),
        ),
      ],
    );
  }
} 