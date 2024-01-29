class APIData {
  getAPIHeader() {
    var headers = {
      'x-functions-key':
          'JGw9wBOm_3KMBwiMx9LcUHckNuWV1hLAcGj_daMYPgStAzFua7bcXw=='
    };
    return headers;
  }

  getBaseUrl() {
    String uri = 'https://arclightmobile.azurewebsites.net/api/';
    return uri;
  }

  getServer(String reportName) {
    String serverURL =
        'https://arclightmobile.azurewebsites.net/api/Arclight_Commun_Func_clinet_db?Report_Name=$reportName&Sp_Name=SP_Mobile_API&CON=XL24';
    return serverURL;
  }
}
