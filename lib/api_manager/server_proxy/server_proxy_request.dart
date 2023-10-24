class ApiServerRequest {
  ApiServerRequest({
     this.url ='',
     this.method ='Get',
     this.parameters,
     this.headers,
  });

   String url;
   String method;
   Map<String, dynamic>? parameters;
   Map<String, dynamic>? headers;

  factory ApiServerRequest.fromJson(Map<String, dynamic> json){
    return ApiServerRequest(
      url: json["url"] ?? "",
      method: json["method"] ?? "",
    );
  }

  Map<String, dynamic> toJson() => {
    "url": url,
    "method": method,
    "parameters": parameters,
    "headers": headers,
  };

}
