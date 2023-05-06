import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vsod_flutter/screens/Doctor/cases/open_cases_screen.dart';
import 'package:vsod_flutter/screens/Doctor/cases/pending_cases_screen.dart';
import 'package:vsod_flutter/utils/app_colors.dart';

class DoctorCasesScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _DoctorCasesScreenState();

  final String caseType;

  DoctorCasesScreen({required this.caseType});
}

class _DoctorCasesScreenState extends State<DoctorCasesScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this, initialIndex: widget.caseType == "PENDING" ? 0 : 1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Column(
          children: [
            Container(
              color: AppColors.headerColor,
              margin: EdgeInsets.only(top: 20),
              height: 60,
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.headerColor,
                      blurRadius: 15.0,
                      offset: Offset(0.0, 0.75),
                    )
                  ],
                  border: Border(
                    bottom: BorderSide(width: 6, color: Colors.white),
                  ),
                  color: AppColors.headerColor,
                ),
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white.withOpacity(0.5),
                tabs: [
                  Tab(
                    child: Text(
                      'Pending Cases',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.roboto(fontSize: 18, fontWeight: FontWeight.w400, letterSpacing: 0.15),
                    ),
                  ),
                  Tab(
                    child: Text(
                      'Open Cases',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.roboto(fontSize: 18, fontWeight: FontWeight.w400, letterSpacing: 0.15),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                child: TabBarView(
                  controller: _tabController,
                  children: [PendingCasesScreen(), OpenCasesScreen()],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
