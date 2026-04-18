import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../dashboard_page/dashboard/dashboard_tokens.dart';

class DocumentVerificationSection extends StatelessWidget {
  const DocumentVerificationSection({
    super.key,
    required this.total,
    required this.drivingLicense,
    required this.rcBook,
    required this.aadhaar,
    required this.profilePhoto,
  });

  final int total;
  final int drivingLicense;
  final int rcBook;
  final int aadhaar;
  final int profilePhoto;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(DashboardTokens.cardRadius),
        boxShadow: DashboardTokens.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Document Verification Status',
                  style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 16),
                ),
              ),
              OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  foregroundColor: DashboardTokens.primaryOrange,
                  side: BorderSide(
                    color: DashboardTokens.primaryOrange.withValues(alpha: 0.45),
                  ),
                  minimumSize: Size.zero,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text('View All'),
              ),
            ],
          ),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _tile('Driving License', drivingLicense, total),
              _tile('RC Book', rcBook, total),
              _tile('Aadhaar Card', aadhaar, total),
              _tile('Profile Photo', profilePhoto, total),
            ],
          ),
        ],
      ),
    );
  }

  Widget _tile(String title, int verified, int total) {
    return Container(
      width: 180,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFF3FBF7),
        borderRadius: BorderRadius.circular(DashboardTokens.metricRadius),
        border: Border.all(color: const Color(0xFFD6F0E2)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 13)),
        const SizedBox(height: 6),
        Text('$verified / $total', style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w700)),
        Text(
          'Verified',
          style: GoogleFonts.inter(color: const Color(0xFF1AAE6F), fontWeight: FontWeight.w600),
        ),
      ]),
    );
  }
}
