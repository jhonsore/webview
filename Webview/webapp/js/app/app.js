(function($) {
    "use strict";

    function App(){
		"use strict";
	}
	
	App.prototype.constructor = App;
	
	App.prototype.init = function(){
		$.app.calliOSInit();
	}
	
	App.prototype.calliOSInit = function (){
		var dataStr = '';

            calliOSFunction("initApp", [],function(ret){
                 //var listValues = JSON.parse(ret.result);
            }, onErrorCallingNativeFunction);
	}
	 /*
	App.prototype.callList = function(__arg__){
		var _json;
		var _dados;
		
		try {
			_json = $.parseJSON( __arg__ );
			_dados = _json.dados;
			
			var myList = myApp.virtualList('.list-block.virtual-list', {
			// Array with items data
			items: _dados,
			// Template 7 template to render each item
			template: '<li class="item-content">' +
			'<div class="item-media">{{nome}}</div>' +
			'<div class="item-media">{{idade}}</div>' +
			'<div class="item-media">{{profession}}</div>' +
			'<div class="item-inner">' +
			'<div class="item-title">{{texto}}</div>' +
			'</div>' +
			'</li>'
			});
		}
		catch(err) {
			alert(err);
		}
		
	}*/
 
    function onErrorCallingNativeFunction (err)
	{
        if (err)
        {
            alert(err.message);
        }
	}

    //---------------------------------------
    $.app = new App();

    jQuery(document).ready(
        function ()
        {
            $.app.init();
        });
    //---------------------------------------
})(jQuery);

//----------------
// Initialize your app
var myApp = new Framework7({
	animateNavBackIcon:true,
	pushState:true,
	pushStateSeparator:'',
	pushStateNoAnimation:true
});

// Export selectors engine
var $$ = Dom7;

// Add main View
var mainView = myApp.addView('.view-main', {
	/*// Enable dynamic Navbar
	dynamicNavbar: true,*/
	// Enable Dom Cache so we can use all inline pages
	domCache: true
                             });
 
function callJS (__arg__){
    
    $(".page-login").html("**** js was invoked *****<br><br>"+__arg__);
}

 









