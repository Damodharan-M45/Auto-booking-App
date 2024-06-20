import 'dart:ui';

//String base_url = 'http://192.168.29.199:8080/mannit';
String base_url = 'https://broadcastmessage.mannit.co/mannit';

String? proDomain="Appointment";
String? userSubDomain="User";
String? adminSubDomain="Admin";

loginUrl(phone, pass, Domain, SubDomain) {
  return '$base_url/login?domain=$Domain&subdomain=$SubDomain&phone=$phone&password=$pass';
}

signUpUrl(phone, pass,) {
  return '$base_url/signup?phone=$phone&password=$pass';
}

createProfileUrl(objectId, Domain, SubDomain) {
  return '$base_url/eCreate?domain=$Domain&subdomain=$SubDomain&userId=$objectId';
}

profileRead_url(objectId, Domain, SubDomain) {
  return '$base_url/eSearch?domain=$Domain&subdomain=$SubDomain&userId=$objectId';
}

UserProfile_Url(objectId, Domain, SubDomain) {
  return '$base_url/eCreate?domain=$Domain&subdomain=$SubDomain&userId=$objectId';
}






Color Orange_color = const Color(0xfff26522);
Color Green_color = const Color(0xff278D27);
Color Appbar_color = const Color(0xfff58221);
Color Scaffold_color = const Color(0xffffe4b3);
String code = '';
String ngrok = 'https://backendelasticsearch.mannit.co';
//String base_url = 'https://broadcastmessage.mannit.co/mannit';
//String base_url = 'http://192.168.1.3:8080/mannit';

String domain = "political";
String subdomain = "party";

// signUpUrl(phone, pass) {
//   return '$base_url/signup?domain=$domain&subdomain=$subdomain&phone=$phone&password=$pass';
// }

readEv_url(objectId, Domain, SubDomain) {
  return '$base_url/eRead?domain=$Domain&subdomain=$SubDomain&userId=$objectId';
}

ForgotPassword_Url(phno, pass, Domain, SubDomain) {
  return '$base_url/forgetpwd?domain=$Domain&subdomain=$SubDomain&phone=$phno&newpassword=$pass';
}

// loginUrl(phone, pass, objectId, Domain, SubDomain) {
//   return '$base_url/login?domain=$Domain&subdomain=$SubDomain&phone=$phone&password=$pass';
// }

// createProfileUrl(objectId, Domain, SubDomain) {
//   return '$base_url/eCreate?domain=$Domain&subdomain=$SubDomain&userId=$objectId';
// }

// profileRead_url(objectId, Domain, SubDomain) {
//   return '$base_url/eSearch?domain=$Domain&subdomain=$SubDomain&userId=$objectId';
// }

readProfile_url(objectId, Domain, SubDomain, aoid) {
  return '$base_url/eRead?domain=$Domain&subdomain=$SubDomain&userId=$objectId&aoid=$aoid';
}

addEventUrl(objectId, Domain, SubDomain) {
  return '$base_url/eCreate?domain=$Domain&subdomain=$SubDomain&userId=$objectId';
}

// readEvent_url(objectId,Domain,SubDomain){
//   return '$base_url/eRead?domain=$Domain&subdomain=$SubDomain&userId=$objectId';
// }
readEvent_url(Domain, SubDomain) {
  return '$base_url/eSearch?domain=$Domain&subdomain=$SubDomain';
}

readprofile_url(objectId, Domain, SubDomain) {
  return '$base_url/eRead?domain=$Domain&subdomain=$SubDomain&userId=$objectId';
}

EventUpdate_Url(objectId, ResourceId, Domain, SubDomain) {
  return '$base_url/eUpdate?domain=$Domain&subdomain=$SubDomain&userId=$objectId&resourceId=$ResourceId';
}

DeleteUpdate_Url(objectId, ResourceId, Domain, SubDomain) {
  return '$base_url/eUpdate?domain=$Domain&subdomain=$SubDomain&userId=$objectId&resourceId=$ResourceId';
}

DeviceTokenUpdate_Url(objectId, ResourceId, Domain, SubDomain) {
  return '$base_url/eUpdate?domain=$Domain&subdomain=$SubDomain&userId=$objectId&resourceId=$ResourceId';
}


ProfileUpdate_Url(objectId, ResourceId, Domain, SubDomain) {
  return '$base_url/eUpdate?domain=$Domain&subdomain=$SubDomain&userId=$objectId&resourceId=$ResourceId';
}

Live_Url(
  Domain,
  SubDomain,
  objectId,
  ResourceId,
) {
  return '$base_url/eUpdate?domain=$Domain&subdomain=$SubDomain&userId=$objectId&resourceId=$ResourceId';
}

super_UpUrl(phone, pass) {
  return '$base_url/signup?domain=political&subdomain=party&phone=$phone&password=$pass';
}
// EventReport_Url(objectId,Domain,SubDomain, startdate, enddate) {
//   return '$base_url/eSearch?domain=Domain&subdomain=SubDomain&userId=$objectId&f=startDate_S gte $startdate and endDate_S lte $enddate ';
// }

//'http://192.168.199.84:8080/mannit/eSearch?domain=$Domain&subdomain=$SubDomain&filtercount=3&f1_field=startDate_S&f1_op=gte&f1_value=${start_date.text}&f2_field=status_S&f2_op=eq&f2_value=false&f3_field=endDate_S&f3_op=lte&f3_value=${end_date.text}'

EventReport_Url(Domain, SubDomain, startdate, enddate, userId) {
  return '$base_url/eSearch?domain=$Domain&subdomain=$SubDomain&filtercount=4&f1_field=startDate_S&f1_op=gte&f1_value=$startdate&f2_field=status_S&f2_op=eq&f2_value=false&f3_field=endDate_S&f3_op=lte&f3_value=$enddate&f4_field=selectedPeople.boothuserId_S&f4_op=eq&f4_value=$userId';
}

Event_api1_url(Domain, SubDomain, startdate, enddate) {
  return 'https://broadcastmessage.mannit.co/mannit/eSearch?domain=$Domain&subdomain=$SubDomain&filtercount=3&f1_field=startDate_S&f1_op=gte&f1_value=$startdate&f2_field=endDate_S&f2_op=lte&f2_value=$enddate&f3_field=groupid_S&f3_op=eq&f3_value=12345';
}

UsderProfile_Url(objectId, Domain, SubDomain) {
  return '$base_url/eCreate?domain=$Domain&subdomain=$SubDomain&userId=$objectId';
}

addBoothUrl(objectId, Domain, SubDomain) {
  return '$base_url/eCreate?domain=$Domain&subdomain=$SubDomain&userId=$objectId';
}

// 'http://192.168.199.84:8080/mannit/eSearch?domain=political&subdomain=party&filtercount=1&f1_field=category_S&f1_op=eq&f1_value=$selectedCategory');
membersearch_url(Domain, SubDomain, posting) {
  return '$base_url/eSearch?domain=$Domain&subdomain=$SubDomain&filtercount=1&f1_field=category_S&f1_op=ep&f1_value=$posting';
}

//http://localhost:8080/mannit/eSearch?domain=political&subdomain=party&userId=65d435473a90b828d7b06a18&f=startDate_S gte 2024-02-20 and endDate_S lte 2024-02-23
//localhost:8080/mannit/eSearch?domain=political&subdomain=party&userId=65cdb4c4143da564eca4651e&f=startDate_S eq 2024-02-15 lt endDate_S eq 2024-02-24
////////////////////////////
// loginUrl(phno, pass) {
//   return '$ngrok/api/auth?domain=politicalparty&subdomain=bjp&phone=$phno&password=$pass';
// }

// signUpUrl(phno, pass) {
//   return '$ngrok/api/signup?domain=politicalparty&subdomain=bjp&phone=$phno&password=$pass';
// }

updateProfileUrl(phno) {
  return '$ngrok/api/update?domain=politicalparty&subdomain=bjp&phone=$phno';
}

mapSearchUrl(category, searchstr, lat, long) {
  return '$ngrok/api/search?domain=politicalparty&subdomain=bjp&category=$category&searchstring=$searchstr&latitude=$lat&longitude=$long';
}

// addEventUrl(phno) {
//   return '$ngrok/api/event?domain=politicalparty&subdomain=bjp&phone=$phno&crud=create';
// }

providerHomeUrl(String phno) {
  return '$ngrok/api/getSpecificDocument?phone=$phno&domain=politicalparty&subdomain=bjp';
}

deleteEventUrl(phno, id) {
  return '$ngrok/api/event?domain=politicalparty&subdomain=bjp&phone=$phno&crud=delete&eventid=$id';
}

updateEventUrl(phno) {
  return '$ngrok/api/event?domain=politicalparty&subdomain=bjp&phone=$phno&crud=edit';
}

// Live_Url(lat, long, phno) {
//   return '$ngrok/api/livelocation?domain=politicalparty&subdomain=bjp&latitude=$lat&longitude=$long&phone=$phno';
// }

// ForgotPassword_Url(phno, pass) {
//   return '$ngrok/api/forgotpassword?domain=politicalparty&subdomain=bjp&phone=$phno&newpassword=$pass';
// }

eventReport_Url(phno, startdate, enddate) {
  return '$ngrok/api/getReport?domain=politicalparty&subdomain=bjp&phone=$phno&startdate=$startdate&enddate=$enddate';
}
