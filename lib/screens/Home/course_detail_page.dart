// lib/screens/Course/course_detail_page.dart

import 'package:BIBOL/widgets/course_widgets/course_detail_app_bar_widget.dart';
import 'package:BIBOL/widgets/course_widgets/course_details_section_widget.dart';
import 'package:BIBOL/widgets/course_widgets/course_overview_card_widget.dart';
import 'package:BIBOL/widgets/course_widgets/enrollment_fab_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:BIBOL/models/course/course_model.dart';

class CourseDetailPage extends StatefulWidget {
  final CourseModel course;

  const CourseDetailPage({Key? key, required this.course}) : super(key: key);

  @override
  State<CourseDetailPage> createState() => _CourseDetailPageState();
}

class _CourseDetailPageState extends State<CourseDetailPage>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _scaleController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _setupErrorHandling();
  }

  void _setupAnimations() {
    _fadeController = AnimationController(
      duration: Duration(milliseconds: 1000),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );
    _scaleController = AnimationController(
      duration: Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOutCubic),
    );
    _slideAnimation = Tween<Offset>(
      begin: Offset(0, 0.4),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.elasticOut),
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );

    _fadeController.forward();
    _slideController.forward();
    _scaleController.forward();
  }

  void _setupErrorHandling() {
    FlutterError.onError = (FlutterErrorDetails details) {
      if (details.exception.toString().contains('HTTP request failed') ||
          details.exception.toString().contains('images.unsplash.com') ||
          details.exception.toString().contains('404')) {
        print('🖼️ Image loading error (ignored): ${details.exception}');
        return;
      }
      FlutterError.presentError(details);
    };
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: CustomScrollView(
        slivers: [
          CourseDetailAppBarWidget(course: widget.course),
          SliverToBoxAdapter(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: Column(
                    children: [
                      CourseOverviewCardWidget(course: widget.course),
                      CourseDetailsSectionWidget(course: widget.course),
                      // CurriculumSectionWidget(course: widget.course),
                      // CareerProspectsSectionWidget(),
                      // AdmissionRequirementsSectionWidget(),
                      // ContactSectionWidget(),
                      SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: EnrollmentFabWidget(),
    );
  }
}
