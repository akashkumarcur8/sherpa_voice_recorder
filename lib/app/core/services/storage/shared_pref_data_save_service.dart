
import '../../constants/app_strings.dart';
import 'sharedPrefHelper.dart';

class SharedPrefDataSAve {
  static data(
      {
        var username = "",
        var email = "",
        var password = "",
        var empname = "",
        var storename = "",
        var user_id = "",
        var emp_type = "",
        var managerId = "",
        var teamId = "",
        var companyId = "",
        var designation = "",
        var managerUserId = "",
        var otherInstitutionType = ""
      })async {
    if (username != "" && username != null){
      await SharedPrefHelper.setpref(AppStrings.username, username);
    }
    if (email != "" && email != null){
      await SharedPrefHelper.setpref(AppStrings.email, email);
    }

    if (empname != "" && empname != null){
      await SharedPrefHelper.setpref(AppStrings.empname, empname);
    }


    if (storename != "" &&  storename!= null){
      await SharedPrefHelper.setpref(AppStrings.storename, storename);
    }

    if (user_id != "" && user_id != null){
      await SharedPrefHelper.setpref(AppStrings.user_id, user_id);
    }

    if (emp_type != "" && emp_type != null){
      await SharedPrefHelper.setpref(AppStrings.emptype, emp_type);
    }

    if (managerId != "" && managerId != null){
      await SharedPrefHelper.setpref(AppStrings.managerId, managerId);

    }


    if (teamId != "" && teamId != null){
      await SharedPrefHelper.setpref(AppStrings.teamId, teamId);
    }


    if (companyId != "" && companyId != null){
      await SharedPrefHelper.setpref(AppStrings.companyId, companyId);
    }

    if(designation != "" && designation != null) {
      await SharedPrefHelper.setpref(AppStrings.designation, designation);
    }

    if(managerUserId != "" && managerUserId != null) {
      await SharedPrefHelper.setpref(AppStrings.managerUserId, managerUserId);
    }
  }
}