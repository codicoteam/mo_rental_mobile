import 'package:get/get.dart';
import '../bindings/app_bindings.dart';
import '../features/modules/auth/views/login_screen.dart';
import '../features/modules/auth/views/register_screen.dart';
import '../features/modules/auth/views/verify_email_screen.dart';
import '../features/modules/bindings/chat_binding.dart';
import '../features/modules/bindings/rate_plan_binding.dart';
import '../features/modules/chat/views/chat_detail_screen.dart';
import '../features/modules/chat/views/conversations_list_screen.dart';
import '../features/modules/chat/views/create_conversation_screen.dart';
import '../features/modules/rate_plans/views/rate_plans_screen.dart';
import '../features/modules/welcome_screens/onboarding_screens/views/onboarding_screen.dart';
import '../features/modules/welcome_screens/splash_screen/views/splash_screen.dart';
import '../features/widgets/agent_botton_nav/agent_botton_nav_tabs.dart';
import 'app_routes.dart';

// Import PromoCodeScreen
import '../features/modules/promo_code/views/promo_code_screen.dart';

class AppPages {
  static final pages = [
    GetPage(
      name: AppRoutes.splash,
      page: () => const SplashScreen(),
    ),
    GetPage(
      name: AppRoutes.onboarding,
      page: () => const OnboardingScreen(),
    ),
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginScreen(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.register,
      page: () => const RegisterScreen(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.verifyEmail,
      page: () => const VerifyEmailScreen(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.main,
      page: () => const MainNavigation(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.ratePlans,
      page: () => const RatePlansScreen(),
      binding: RatePlanBinding(),
    ),
    // Simple GetPage without binding - we'll handle initialization differently
    GetPage(
      name: AppRoutes.promoCodes,
      page: () => PromoCodeScreen(),
    ),
     GetPage(
      name: AppRoutes.chatConversations,
      page: () => const ConversationsListScreen(),
      binding: ChatBinding(),
    ),
    GetPage(
      name: AppRoutes.chatDetail,
      page: () => ChatDetailScreen(conversationId: Get.parameters['id'] ?? ''),
      binding: ChatBinding(),
    ),
    GetPage(
      name: AppRoutes.createChat,
      page: () => const CreateConversationScreen(),
      binding: ChatBinding(),
    ),

  ];
}