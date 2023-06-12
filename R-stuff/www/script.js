let BUTTON_CLICK_COUNT = 0;

// Check for if one of the file close buttons were clicked
$(document).on('click', 'button', function(e) {
    e.stopPropagation()
    if(typeof BUTTON_CLICK_COUNT == "undefined") {
        BUTTON_CLICK_COUNT = 1; 
    } else {
        BUTTON_CLICK_COUNT ++;
    }
    if($(this).hasClass('del-btn')){
        console.log('finally');
        $(this).parent().remove();
    }
    Shiny.onInputChange("js.button_clicked", 
        e.target.id + "_" + BUTTON_CLICK_COUNT);
});

// Receive the custom variable from the server
Shiny.addCustomMessageHandler("names", function(message) {
    var myVariableValue = message;
    Shiny.onInputChange("dataFromJS", message[0]);
    console.log(myVariableValue); // Output the variable value to the console
});