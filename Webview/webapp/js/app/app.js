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

            calliOSFunction("initApp", [],function(__result__){
                //var _t = $.parseJSON( __result__ );
                myApp.alert(__result__,"Value from ios:");
            }, onErrorCallingNativeFunction);
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

//ios to js
function onErrorCallingNativeFunction (err){
    if (err)
    {
        alert(err.message);
    }
}
 
function callJS (__arg__){
    
    $(".page-login").html("<br><br>**** js was invoked fom ios *****<br><br>Value:<br><br>"+__arg__);
}

 









