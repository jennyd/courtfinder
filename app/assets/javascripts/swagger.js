//= require swagger-ui/shred.bundle.js
//= require swagger-ui/jquery-1.8.0.min.js
//= require swagger-ui/jquery.slideto.min.js
//= require swagger-ui/jquery.wiggle.min.js
//= require swagger-ui/jquery.ba-bbq.min.js
//= require swagger-ui/handlebars-1.0.0.js
//= require swagger-ui/underscore-min.js
//= require swagger-ui/backbone-min.js
//= require swagger-ui/swagger.js
//= require swagger-ui/highlight.7.3.pack.js
//= require swagger-ui.js
//= require_self


// It appears that swagger will allow authorizations to be specified via json config
//
// "authorizations" : {
//   "local-oauth": {
//     "type": "oauth2",
//     "scopes": [
//       "PUBLIC"
//     ],
//     "grantTypes" : {
//       "implicit" : {
//         "loginEndpoint" : {
//           "url" : "http://sample.com/oauth/dialog"
//         },
//         "tokenName" : "access_code"
//       },
//       "authorization_code" : {
//         "tokenRequestEndpoint" : {
//           "url" : "http://sample.com/oauth/requestToken",
//           "clientIdName" : "client_id",
//           "clientSecretName" : "client_secret"
//         },
//         "tokenEndpoint" : {
//           "url" : "http://sample.com/oauth/token",
//           "tokenName" : "access_code"
//         }
//       }
//     }
//   },
//   "apiKey" : {
//     "type" : "apiKey",
//     "passAs" : "header"
//   }
// }


$(function () {
  window.swaggerUi = new SwaggerUi({
    url: "/swagger_doc.json",
    dom_id: "swagger-ui-container",
    supportedSubmitMethods: ['get', 'post', 'put', 'patch','delete'],
    onComplete: function(swaggerApi, swaggerUi){
      if(console) {
        console.log("Loaded SwaggerUI")
      }
      $('pre code').each(function(i, e) {hljs.highlightBlock(e)});
    },
    onFailure: function(data) {
      if(console) {
        console.log("Unable to Load SwaggerUI");
        console.log(data);
      }
    },
    docExpansion: "none"
  });

  $('#explore').click(function(e){
    e.preventDefault();

    $.get('/api_docs/get_token.json', function(data){
      $('#input_apiKey').val(data.token);
      $('#input_apiKey').trigger('change');
    });

    return false;

  });

  $('#input_apiKey').change(function() {
    var key = $('#input_apiKey')[0].value;
    console.log("key: " + key);
    if(key && key.trim() != "") {
      console.log("added key " + key);
      window.authorizations.add("key", new ApiKeyAuthorization("Authorization", "Bearer " + key, "header"));
    }
  })
  window.swaggerUi.load();
});