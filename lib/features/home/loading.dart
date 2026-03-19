import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:mobo_expenses/provider/bottom_nav_provider.dart';
import 'package:mobo_expenses/provider/user_provider.dart';
import 'package:provider/provider.dart';
import '../../core/constants/constants.dart';
import '../../shared/widgets/snackbars/custom_snackbar.dart';
import '../company/providers/company_provider.dart';
import '../login/pages/server_setup_screen.dart';
import '../profile/providers/profile_provider.dart';
import 'home_screen.dart';

class Loading extends StatefulWidget {
  const Loading({super.key});

  @override
  State<Loading> createState() => _LoadingState();
}

class _LoadingState extends State<Loading> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        initialLoading();
        context.read<CompanyProvider>().initialize();
        context.read<ProfileProvider>().fetchUserProfile();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: LoadingAnimationWidget.staggeredDotsWave(
          color: MoboColor.redColor,
          size: 40,
        ),
      ),
    );
  }

  ///initial loading
  initialLoading() async {
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final bottomProvider = Provider.of<BottomNavProvider>(
        context,
        listen: false,
      );
      bottomProvider.changeIndex(0);

      await userProvider.checkCurrentUserRole();
      if (!mounted) return;

      await context.read<ProfileProvider>().fetchUserProfile();
      if (!mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen()),
        (Route<dynamic> route) => false,
      );
    } catch (e) {
      if (!mounted) return;
      CustomSnackbar.showError(
        context,
        ' ${e.toString().split("message:").last.split(",").first.trim()}',
      );

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => ServerSetupScreen()),
        (Route<dynamic> route) => false,
      );
    }
  }
}
