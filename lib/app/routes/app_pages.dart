import 'package:get/get_navigation/src/routes/get_route.dart';
import 'package:mice_activeg/app/modules/home/home_screen.dart';
import '../modules/analytics/analytics_widget.dart';
import '../modules/analytics/bindings/analytics_binding.dart';
import '../modules/complaint_center/bindings/complaint_center_binding.dart';
import '../modules/complaint_center/view/complaint_center_screen.dart';
import '../modules/conversation/bindings/conversation_view_binding.dart';
import '../modules/conversation/conversation_view.dart';
import '../modules/delivery_tracker/bindings/agent_detail_binding.dart';
import '../modules/delivery_tracker/bindings/delivery_tracker_binding.dart';
import '../modules/delivery_tracker/views/agent_detail_screen.dart';
import '../modules/delivery_tracker/views/delivery_tracker_screen.dart';
import '../modules/home/bindings/home_binding.dart';
import '../modules/login/bindings/login_binding.dart';
import '../modules/login/view/login_view.dart';
import '../modules/home/onboarding/onboarding_screen.dart';
import '../modules/profile/profile_page.dart';
import '../modules/raise_ticket/bindings/raise_ticket_binding.dart';
import '../modules/raise_ticket/views/raise_ticket_screen.dart';
import '../modules/splash_screen/SpleshScreen.dart';
import 'app_routes.dart';

class AppPages {
  static final pages = [
    GetPage(
      name: Routes.splash,
      page: () => const SpleshScreen(),
    ),
    GetPage(
      name: Routes.onboarding,
      page: () => OnboardingScreen(),
    ),
    GetPage(
      name: Routes.home,
      page: () => HomeScreen(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: Routes.deliveryTracker,
      page: () => const DeliveryTrackerScreen(),
      binding: DeliveryTrackerBinding(),
    ),
    GetPage(
      name: Routes.agentDetail,
      page: () => const AgentDetailScreen(),
      binding: AgentDetailBinding(),
    ),
    GetPage(
      name: Routes.raiseTicket,
      page: () => const RaiseTicketScreen(),
      binding: RaiseTicketBinding(),
    ),
    GetPage(
      name: Routes.complaintcenter,
      page: () => const ComplaintCenterScreen(),
      binding: ComplaintCenterBinding(),
    ),
    GetPage(
      name: Routes.analyticsDashboard,
      page: () => const AnalyticsDashboard(),
      binding: AnalyticsBinding(),
    ),
    GetPage(
      name: Routes.conversationView,
      page: () => const ConversationView(),
      binding: ConversationViewBinding(),
    ),
    GetPage(
      name: Routes.profile,
      page: () => const ProfileScreen(),
    ),
    GetPage(
      name: Routes.login,
      page: () => const LoginView(),
      binding: LoginBinding(),
    ),
  ];
}
