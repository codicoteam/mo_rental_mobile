// lib/app/routes/app_pages.dart
import 'package:get/get.dart';
import '../../domain/repositories/driver_profile_repository.dart';
import '../../domain/repositories/vehicle_model_repository.dart';
import '../../domain/repositories/vehicle_repository.dart';
import '../bindings/app_bindings.dart';
import '../features/data/models/branch_models/branch_models.dart';
import '../features/modules/auth/views/forgot_password_screen.dart';
import '../features/modules/auth/views/login_screen.dart';
import '../features/modules/auth/views/register_screen.dart';
import '../features/modules/auth/views/verify_email_screen.dart';
import '../features/modules/bindings/branch_binding.dart';
import '../features/modules/bindings/chat_binding.dart';
import '../features/modules/bindings/rate_plan_binding.dart';
import '../features/modules/bindings/reservation_binding.dart';
import '../features/modules/branches/views/branch_detail_screen.dart';
import '../features/modules/branches/views/branches_list_screen.dart';
import '../features/modules/branches/views/nearby_branches_screen.dart';
import '../features/modules/chat/views/chat_detail_screen.dart';
import '../features/modules/chat/views/conversations_list_screen.dart';
import '../features/modules/chat/views/create_conversation_screen.dart';
import '../features/modules/drivers/controllers/driver_profile_controller.dart';
import '../features/modules/drivers/views/driver_profile_form_screen.dart';
import '../features/modules/drivers/views/my_driver_profile_screen.dart';
import '../features/modules/drivers/views/public_drivers_screen.dart';
import '../features/modules/profile/views/delete_account_screen.dart';
import '../features/modules/profile/views/edit_profile_screen.dart'; // ADD THIS IMPORT
import '../features/modules/profile/views/profile_screen.dart'; // ADD THIS IMPORT
import '../features/modules/rate_plans/views/rate_plans_screen.dart';
import '../features/modules/reservations/views/availability_screen.dart';
import '../features/modules/reservations/views/create_reservation_screen.dart';
import '../features/modules/reservations/views/reservation_detail_screen.dart';
import '../features/modules/reservations/views/reservation_list_screen.dart';
import '../features/modules/vehicles/controllers/vehicle_controller.dart';
import '../features/modules/vehicles/controllers/vehicle_model_controller.dart';
import '../features/modules/vehicles/views/vehicle_models_screen.dart';
import '../features/modules/vehicles/views/vehicle_selection_screen.dart';
import '../features/modules/vehicles/views/vehicles_screen.dart';
import '../features/modules/welcome_screens/onboarding_screens/views/onboarding_screen.dart';
import '../features/modules/welcome_screens/splash_screen/views/splash_screen.dart';
import '../features/widgets/agent_botton_nav/agent_botton_nav_tabs.dart';
import 'app_routes.dart';
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
    GetPage(
      name: AppRoutes.checkAvailability,
      page: () => const AvailabilityScreen(),
      binding: ReservationBinding(),
    ),
    GetPage(
      name: AppRoutes.branches,
      page: () => const BranchesListScreen(),
      binding: BranchBinding(),
    ),
    GetPage(
      name: AppRoutes.nearbyBranches,
      page: () => const NearbyBranchesScreen(),
      binding: BranchBinding(),
    ),
    GetPage(
      name: '/BranchDetailScreen',
      page: () {
        final branch = Get.arguments as Branch;
        return BranchDetailScreen(branch: branch);
      },
    ),
    GetPage(
      name: AppRoutes.createReservation,
      page: () {
        final args = Get.arguments as Map<String, dynamic>?;
        return CreateReservationScreen(initialData: args);
      },
      binding: ReservationBinding(),
    ),
    GetPage(
      name: AppRoutes.reservationList,
      page: () => const ReservationListScreen(),
      binding: ReservationBinding(),
    ),
    GetPage(
      name: AppRoutes.reservationDetail,
      page: () => const ReservationDetailScreen(),
      binding: ReservationBinding(),
    ),
    GetPage(
      name: AppRoutes.vehicleModels,
      page: () => const VehicleModelsScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut<VehicleModelRepository>(() => VehicleModelRepository());
        Get.lazyPut<VehicleModelController>(
          () => VehicleModelController(Get.find<VehicleModelRepository>()),
        );
      }),
    ),
    GetPage(
      name: AppRoutes.vehicleFleet,
      page: () => const VehiclesScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut<VehicleRepository>(() => VehicleRepository());
        Get.lazyPut<VehicleController>(
          () => VehicleController(Get.find<VehicleRepository>()),
        );
      }),
    ),
    GetPage(
      name: AppRoutes.vehicleSelection,
      page: () => VehicleSelectionScreen(
        isSelectionMode: Get.arguments?['isSelectionMode'] ?? true,
      ),
    ),
    GetPage(
      name: AppRoutes.publicDrivers,
      page: () => const PublicDriversScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut<DriverProfileRepository>(() => DriverProfileRepository());
        Get.lazyPut<DriverProfileController>(
          () => DriverProfileController(Get.find<DriverProfileRepository>()),
        );
      }),
    ),
    GetPage(
      name: AppRoutes.myDriverProfile,
      page: () => const MyDriverProfileScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut<DriverProfileRepository>(() => DriverProfileRepository());
        Get.lazyPut<DriverProfileController>(
          () => DriverProfileController(Get.find<DriverProfileRepository>()),
        );
      }),
    ),
    GetPage(
      name: AppRoutes.createDriverProfile,
      page: () => const DriverProfileFormScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut<DriverProfileRepository>(() => DriverProfileRepository());
        Get.lazyPut<DriverProfileController>(
          () => DriverProfileController(Get.find<DriverProfileRepository>()),
        );
      }),
    ),
    GetPage(
      name: AppRoutes.editDriverProfile,
      page: () => DriverProfileFormScreen(isEditMode: true),
      binding: BindingsBuilder(() {
        Get.lazyPut<DriverProfileRepository>(() => DriverProfileRepository());
        Get.lazyPut<DriverProfileController>(
          () => DriverProfileController(Get.find<DriverProfileRepository>()),
        );
      }),
    ),
    // ADD THESE PROFILE ROUTES
    GetPage(
      name: AppRoutes.profile,
      page: () => const ProfileScreen(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.editProfile,
      page: () => const EditProfileScreen(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.deleteAccount,
      page: () => const DeleteAccountScreen(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.forgotPassword,
      page: () => const ForgotPasswordScreen(),
      binding: AuthBinding(),
    ),
  ];
}
