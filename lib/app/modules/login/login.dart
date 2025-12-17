// import 'dart:convert';
// import 'dart:io';
// import 'package:connectivity_plus/connectivity_plus.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:dio/dio.dart';
// import 'package:mice_activeg/app/core/utils/extensions/snackbar_extensions.dart';
// import 'package:onesignal_flutter/onesignal_flutter.dart';
// import 'app/core/services/storage/sharedPrefHelper.dart';
// import 'app/core/services/storage/shared_pref_data_save_service.dart';
// import 'app/routes/app_routes.dart';
//
//
// class Login extends StatefulWidget {
//   const Login({super.key});
//
//   @override
//   State<Login> createState() => _LoginState();
// }
//
// class _LoginState extends State<Login> {
//   TextEditingController _usernameController = TextEditingController();
//   TextEditingController _passwordController = TextEditingController();
//
//
//
//   bool _isLoading = false; // For showing loading state
//   bool _obscureText = true;
//   // For password visibility
//
//   Future<void> _login() async {
//     var connectivityResult = await Connectivity().checkConnectivity();
//     if (connectivityResult.contains(ConnectivityResult.none)) {
//       if(mounted){
//         context.showWarningSnackBar('You are offline. Please reconnect to the internet and try again');
//       }
//
//       return;
//     }
//
//     final String username = _usernameController.text;
//     final String password = _passwordController.text;
//
//     if (username.isEmpty) {
//       if(mounted){
//         context.showWarningSnackBar('Please enter your username');
//       }
//       return;
//     }
//
//     if (password.isEmpty) {
//       if(mounted){
//         context.showWarningSnackBar('Please enter your password');
//       }
//       return;
//
//     }
//
//     setState(() {
//       _isLoading = true;
//     });
//
//     try {
//       Dio dio = Dio();
//
//       // Construct the login payload
//       Map<String, dynamic> data = {
//         'username': username,
//         'password': password,
//       };
//
//       // Send POST request
//       final response = await dio.post(
//         'https://dashboard.cur8.in/api/login/',
//         data: data,
//       );
//
//       // Handle successful login
//       if (response.statusCode == 200) {
//         final resData = response.data;
//         final details = jsonDecode(resData['details']);
//         if (resData['status'] == '1') {
//
//           await SharedPrefHelper.setIsloginValue(true);
//
//
//           // Extract data from 'details'
//           String username = details['username']  ?? '';
//           String email = details['email']  ?? '';
//           String emp_name = details['emp_name'] ?? '';
//           String store_name = details['store_name'] ?? '';
//           String user_id = details['user_id'].toString() ?? '';
//           String emp_type = details['emp_type'].toString() ?? '';
//           String designation = details['designation'].toString() ?? '';
//           // String teamId = details['teamId'].toString() ?? '';
//           //String companyId = details['company_id'].toString() ?? '';
//           OneSignal.login(user_id);
//           OneSignal.User.addEmail(email);
//
//
//
//           final responseData = await dio.get(
//             'https://transform.cur8.in/webservice/rest/server.php'
//                 '?wstoken=55d122d76ce0b08e792ce0d4f680b1d2'
//                 '&wsfunction=local_learningnudges_get_user_managerid_by_email'
//                 '&moodlewsrestformat=json'
//                 '&email=$email',
//           );
//
//
//           final data = responseData.data;
//
//           String managerId = 'NA';
//           String teamId='NA';
//           String companyId='NA';
//
//
//           if (data is Map<String, dynamic> && data['errorcode'] == 'invaliduser') {
//             managerId = 'NA';
//             teamId='NA';
//              companyId='NA';
//           } else if (data is List && data.isNotEmpty && data[0] is Map<String, dynamic>) {
//             final managerData = data[0] as Map<String, dynamic>;
//             managerId = managerData['managerid']?.toString() ?? 'NA';
//             teamId = managerData['teamid']?.toString() ?? 'NA';
//             companyId = managerData['companyid']?.toString() ?? 'NA';
//           }
//
//
//           SharedPrefDataSAve.data(
//             username: username,
//             email: email,
//             empname: emp_name,
//             storename: store_name,
//               emp_type: emp_type,
//               user_id: user_id,
//                managerId: managerId,
//               teamId: teamId,
//               companyId: companyId,
//               designation: designation
//
//           );
//
//     if(mounted){
//      if(designation == 'manager' || designation == 'Manager'){
//        Get.toNamed(Routes.deliveryTracker);
//      }
//      else{
//        Get.toNamed(Routes.home);}
//      }
//
//           // Clear input fields
//           _usernameController.clear();
//           _passwordController.clear();
//         }
//       }
//     } catch (e) {
//       if(mounted){
//         context.showWarningSnackBar("Incorrect username or password. Please try again.");
//       }
//     } finally {
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }
//
//
//
//
//
//
//
//   @override
//   Widget build(BuildContext context) {
//     return WillPopScope(
//       onWillPop: () => exitPopup(),
//       child: Scaffold(
//         backgroundColor: Colors.white,
//         body: SafeArea(
//           child: Column(
//             children: [
//               Container(
//                 width: double.infinity,
//                 height: MediaQuery.of(context).size.height * 0.3,
//                 child: Image.asset(
//                   'asset/images/newlogo.png',
//                   fit: BoxFit.cover,
//                 ),
//               ),
//               Expanded(
//                 child: SingleChildScrollView(
//                   child: Padding(
//                     padding: EdgeInsets.symmetric(horizontal: 24.0),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         SizedBox(height: 24.0),
//                         Text(
//                           'Hello Darwix AI',
//                           style: TextStyle(
//                             fontSize: 32.0,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                         SizedBox(height: 8.0),
//                         Text(
//                           'Sign in to your account',
//                           style: TextStyle(
//                             fontSize: 18.0,
//                             color: Color(0xFFAFB0B0),
//                           ),
//                         ),
//                         SizedBox(height: 32.0),
//                         TextField(
//                           controller: _usernameController,
//                           decoration: InputDecoration(
//                             hintText: 'Username',
//                             contentPadding: EdgeInsets.symmetric(
//                                 vertical: 16.0, horizontal: 20),
//                             border: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(50.0),
//                               borderSide: BorderSide.none,
//                             ),
//                             fillColor: Colors.grey[200],
//                             filled: true,
//                           ),
//                         ),
//                         SizedBox(height: 16.0),
//                         TextField(
//                           controller: _passwordController,
//                           obscureText: _obscureText,
//                           decoration: InputDecoration(
//                             hintText: 'Password',
//                             contentPadding: EdgeInsets.symmetric(
//                                 vertical: 16.0, horizontal: 20.0),
//                             border: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(50.0),
//                               borderSide: BorderSide.none,
//                             ),
//                             fillColor: Colors.grey[200],
//                             filled: true,
//                             suffixIcon: IconButton(
//                               icon: Icon(
//                                 _obscureText
//                                     ? Icons.visibility_off
//                                     : Icons.visibility,
//                                 color: Colors.grey,
//                               ),
//                               onPressed: () {
//                                 setState(() {
//                                   _obscureText = !_obscureText;
//                                 });
//                               },
//                             ),
//                           ),
//                         ),
//                         SizedBox(height:  32.0),
//                         Center(
//                           child: SizedBox(
//                             width: MediaQuery.of(context).size.width * 0.5,
//                             child: ElevatedButton(
//                               onPressed: _isLoading ? null : _login,
//                               style: ElevatedButton.styleFrom(
//                                 padding: EdgeInsets.symmetric(vertical: 14.0),
//                                 backgroundColor: Color(0xFF565ADD),
//                                 shape: RoundedRectangleBorder(
//                                   borderRadius: BorderRadius.circular(20.0),
//                                 ),
//                               ),
//                               child: _isLoading
//                                   ? CircularProgressIndicator(
//                                 color: Colors.white,
//                               )
//                                   : Text(
//                                 'SIGN IN',
//                                 style: TextStyle(
//                                   fontSize: 18.0,
//                                   fontWeight: FontWeight.bold,
//                                   color: Colors.white,
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ),
//                         SizedBox(height: 20.0),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//
//
//
//   Future<bool> exitPopup() async {
//     return (await showDialog<bool>(
//       context: context,
//       barrierDismissible: false,
//       builder: (context) {
//         return Dialog(
//           backgroundColor: Colors.white,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(16),
//           ),
//           child: Padding(
//             padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 // 1) The red alert icon in a pale red circle
//                 CircleAvatar(
//                   radius: 30,
//                   backgroundColor: Colors.red.withOpacity(0.1),
//                   child: const Icon(
//                     Icons.exit_to_app,
//                     color: Colors.red,
//                     size: 30,
//                   ),
//                 ),
//
//                 const SizedBox(height: 16),
//
//                 // 2) Title
//                 const Text(
//                   'Are you Sure ?',
//                   style: TextStyle(
//                     fontSize: 20,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//
//                 const SizedBox(height: 8),
//
//                 // 3) Subtitle
//                 const Text(
//                   'Do you want to exit the application',
//                   textAlign: TextAlign.center,
//                   style: TextStyle(
//                     fontSize: 14,
//                     color: Colors.grey,
//                   ),
//                 ),
//
//                 const SizedBox(height: 24),
//
//                 // 4) Buttons
//                 Row(
//                   children: [
//                     // Exit button
//                     Expanded(
//                       child: TextButton(
//                         onPressed: () => Navigator.of(context).pop(false),
//                         style: TextButton.styleFrom(
//                           backgroundColor: Colors.white,
//                           side: BorderSide(color: Colors.grey.shade300),
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(30),
//                           ),
//                           padding: const EdgeInsets.symmetric(vertical: 12,),
//                         ),
//                         child: const Text(
//                           'Cancel',
//                           style: TextStyle(
//                             color: Colors.black,
//                             fontSize: 16,
//                           ),
//                         ),
//                       ),
//                     ),
//
//                     const SizedBox(width: 16),
//
//                     // Continue button
//                     Expanded(
//                       child: TextButton(
//                         onPressed: () => exit(0),
//                         style: TextButton.styleFrom(
//                           backgroundColor: const Color(0xFF565ADD),
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(30),
//                           ),
//                           padding: const EdgeInsets.symmetric(vertical: 12),
//                         ),
//                         child: const Text(
//                           'Yes',
//                           style: TextStyle(
//                             color: Colors.white,
//                             fontSize: 16,
//                           ),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     )) ?? false;
//   }
//
//
//
//
//
// }
//
