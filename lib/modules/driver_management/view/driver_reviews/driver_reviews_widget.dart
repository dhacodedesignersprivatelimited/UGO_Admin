import '/shared/widgets/admin_drawer.dart';
import '/shared/widgets/admin_pop_scope.dart';
import '/shared/widgets/responsive_body.dart';
import '/index.dart';
import '/config/theme/flutter_flow_theme.dart';
import '/config/theme/flutter_flow_util.dart';
import '/config/theme/flutter_flow_widgets.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
// Note: Uncomment if you are using a model file in FlutterFlow
// import 'driver_reviews_model.dart';
// export 'driver_reviews_model.dart';

class DriverReviewsWidget extends StatefulWidget {
  const DriverReviewsWidget({super.key});

  static String routeName = 'DriverReviews';
  static String routePath = '/driver-reviews';

  @override
  State<DriverReviewsWidget> createState() => _DriverReviewsWidgetState();
}

class _DriverReviewsWidgetState extends State<DriverReviewsWidget> {
  // late DriverReviewsModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  // State for filter
  String _activeFilter = 'All'; // 'All', 'Positive', 'Negative'

  // MOCK DATA: Replace with your actual backend data for Driver Reviews
  final List<Map<String, dynamic>> _mockDriverReviews = [
    {
      'id': 'REV-8832',
      'driverName': 'Rajesh Kumar',
      'driverId': 'DRV-1042',
      'reviewerName': 'Amit Sharma',
      'avatar': 'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w0NTYyMDF8MHwxfHJhbmRvbXx8fHx8fHx8fDE3NjQ1NzUyMDB8&ixlib=rb-4.1.0&q=80&w=1080',
      'date': '2 days ago',
      'rating': 5,
      'comment': 'Excellent driving skills and very polite. Reached the airport right on time despite the heavy traffic. The car was spotless.',
      'upvotes': 15,
      'downvotes': 0,
    },
    {
      'id': 'REV-9910',
      'driverName': 'Suresh Reddy',
      'driverId': 'DRV-2291',
      'reviewerName': 'Priya Patel',
      'avatar': 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w0NTYyMDF8MHwxfHJhbmRvbXx8fHx8fHx8fDE3NjQ1NzUyMDF8&ixlib=rb-4.1.0&q=80&w=1080',
      'date': '1 week ago',
      'rating': 2,
      'comment': 'Driver was talking on the phone constantly while driving. Also refused to turn on the AC until I insisted multiple times.',
      'upvotes': 34,
      'downvotes': 2,
    },
    {
      'id': 'REV-7741',
      'driverName': 'Anita Desai',
      'driverId': 'DRV-0883',
      'reviewerName': 'Rahul Verma',
      'avatar': 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w0NTYyMDF8MHwxfHJhbmRvbXx8fHx8fHx8fDE3NjQ1NzUyMDJ8&ixlib=rb-4.1.0&q=80&w=1080',
      'date': '3 weeks ago',
      'rating': 4,
      'comment': 'Very smooth ride. She knew all the shortcuts to avoid the main road blocks. Dropped one star because pickup took slightly longer than estimated.',
      'upvotes': 8,
      'downvotes': 1,
    },
  ];

  @override
  void initState() {
    super.initState();
    // _model = createModel(context, () => DriverReviewsModel());
  }

  @override
  void dispose() {
    // _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Apply Filtering logic (Positive >= 4, Negative <= 3)
    List<Map<String, dynamic>> filteredReviews = _mockDriverReviews.where((review) {
      if (_activeFilter == 'Positive') return review['rating'] >= 4;
      if (_activeFilter == 'Negative') return review['rating'] <= 3;
      return true; // 'All'
    }).toList();

    return AdminPopScope(
      child: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
          FocusManager.instance.primaryFocus?.unfocus();
        },
        child: Scaffold(
          key: scaffoldKey,
          backgroundColor: FlutterFlowTheme.of(context).secondaryBackground,
          drawer: buildAdminDrawer(context),
          appBar: AppBar(
            backgroundColor: FlutterFlowTheme.of(context).primary,
            automaticallyImplyLeading: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 28),
              onPressed: () => context.goNamedAuth(DashboardScreen.routeName, context.mounted),
            ),
            title: Text(
              'Driver Reviews',
              style: FlutterFlowTheme.of(context).headlineMedium.override(
                font: GoogleFonts.interTight(fontWeight: FontWeight.bold),
                color: Colors.white,
                fontSize: 22.0,
              ),
            ),
            centerTitle: false,
            elevation: 0,
          ),
          body: Column(
            children: [
              // Filter Chips Row
              Container(
                width: double.infinity,
                color: FlutterFlowTheme.of(context).primaryBackground,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 800),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildFilterChip('All'),
                          const SizedBox(width: 8),
                          _buildFilterChip('Positive'),
                          const SizedBox(width: 8),
                          _buildFilterChip('Negative'),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // List Content
              Expanded(
                child: filteredReviews.isEmpty
                    ? _buildEmptyState()
                    : Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 800),
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: filteredReviews.length,
                      itemBuilder: (context, index) {
                        return _buildReviewCard(filteredReviews[index]);
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- UI HELPER METHODS ---

  Widget _buildFilterChip(String label) {
    final isSelected = _activeFilter == label;
    final theme = FlutterFlowTheme.of(context);

    return FilterChip(
      label: Text(label),
      labelStyle: theme.bodyMedium.override(
        font: GoogleFonts.inter(
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
        color: isSelected ? Colors.white : theme.primaryText,
      ),
      backgroundColor: theme.secondaryBackground,
      selectedColor: theme.primary,
      selected: isSelected,
      showCheckmark: false,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isSelected ? theme.primary : theme.alternate,
        ),
      ),
      onSelected: (bool selected) {
        if (selected) {
          setState(() {
            _activeFilter = label;
          });
        }
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(48),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.star_border_rounded,
              size: 64,
              color: FlutterFlowTheme.of(context).secondaryText.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No $_activeFilter Reviews',
              style: FlutterFlowTheme.of(context).titleLarge.override(
                font: GoogleFonts.interTight(fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'There are no driver reviews matching this filter.',
              textAlign: TextAlign.center,
              style: FlutterFlowTheme.of(context).bodyMedium.override(
                color: FlutterFlowTheme.of(context).secondaryText,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewCard(Map<String, dynamic> review) {
    final theme = FlutterFlowTheme.of(context);
    final int rating = review['rating'];

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.primaryBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.alternate, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Avatar, Name, Time
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    fit: BoxFit.cover,
                    image: NetworkImage(review['avatar']),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review['driverName'],
                      style: theme.titleMedium.override(
                        font: GoogleFonts.interTight(fontWeight: FontWeight.w700),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: theme.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            review['driverId'],
                            style: theme.labelSmall.override(
                              font: GoogleFonts.inter(fontWeight: FontWeight.w600),
                              color: theme.primary,
                              fontSize: 10,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          review['date'],
                          style: theme.bodySmall.override(
                            font: GoogleFonts.inter(),
                            color: theme.secondaryText,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Optional: Action button (e.g. Delete/Hide review)
              IconButton(
                icon: Icon(Icons.more_vert_rounded, color: theme.secondaryText),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Options menu tapped')),
                  );
                },
              )
            ],
          ),
          const SizedBox(height: 12),

          // Star Rating Row
          Row(
            children: [
              ...List.generate(5, (index) {
                return Icon(
                  index < rating ? Icons.star_rounded : Icons.star_border_rounded,
                  color: theme.warning,
                  size: 20,
                );
              }),
              const SizedBox(width: 8),
              Text(
                'by ${review['reviewerName']}',
                style: theme.bodySmall.override(
                  font: GoogleFonts.inter(),
                  color: theme.secondaryText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Comment Body
          Text(
            review['comment'],
            style: theme.bodyMedium.override(
              font: GoogleFonts.inter(height: 1.5),
            ),
          ),
          const SizedBox(height: 16),

          // Footer: Upvotes & Downvotes
          Row(
            children: [
              _buildVoteBadge(Icons.thumb_up_alt_rounded, review['upvotes'], theme.success),
              const SizedBox(width: 16),
              _buildVoteBadge(Icons.thumb_down_alt_rounded, review['downvotes'], theme.error),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVoteBadge(IconData icon, int count, Color highlightColor) {
    final theme = FlutterFlowTheme.of(context);
    final hasVotes = count > 0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: hasVotes ? highlightColor.withValues(alpha: 0.1) : theme.secondaryBackground,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: hasVotes ? highlightColor : theme.secondaryText,
          ),
          const SizedBox(width: 6),
          Text(
            count.toString(),
            style: theme.bodySmall.override(
              font: GoogleFonts.inter(fontWeight: FontWeight.w600),
              color: hasVotes ? highlightColor : theme.secondaryText,
            ),
          ),
        ],
      ),
    );
  }
}