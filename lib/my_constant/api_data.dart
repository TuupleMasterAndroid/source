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
}
