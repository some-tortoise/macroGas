//navbar code
function openTab(evt, name) {
    tablinks = document.getElementsByClassName("nav-el-circle");
    for (i = 0; i < tablinks.length; i++) {
      tablinks[i].className = tablinks[i].className.replace(" active-nav-el", "");
    }
    tablinks = document.getElementsByClassName("nav-text");
    for (i = 0; i < tablinks.length; i++) {
      tablinks[i].className = tablinks[i].className.replace(" active-nav-text", "");
    }
    evt.currentTarget.className += " active-nav-el";
    var children = evt.currentTarget.parentElement.children
    for(i = 0; i < children.length; i++){
        if(children[i].className == 'nav-text'){
            evt.currentTarget.parentElement.children[i].className += " active-nav-text";
        }
    }
    evt.currentTarget.parentElement.children.className += " active-nav-text";


    tabcontent = document.getElementsByClassName("panel-container");
    for (i = 0; i < tabcontent.length; i++) {
      tabcontent[i].style.display = "none";
      if(tabcontent[i].classList.contains('home-panel-container') && evt.currentTarget.parentElement.classList.contains('home-nav-el')){
        tabcontent[i].style.display = "block";
      }
      if(tabcontent[i].classList.contains('upload-panel-container') && evt.currentTarget.parentElement.classList.contains('upload-nav-el')){
        tabcontent[i].style.display = "block";
      }
      if(tabcontent[i].classList.contains('flag-panel-container') && evt.currentTarget.parentElement.classList.contains('flag-nav-el')){
        tabcontent[i].style.display = "block";
      }
      if(tabcontent[i].classList.contains('calculate-panel-container') && evt.currentTarget.parentElement.classList.contains('calculate-nav-el')){
        tabcontent[i].style.display = "block";
      }
      if(tabcontent[i].classList.contains('visualization-panel-container') && evt.currentTarget.parentElement.classList.contains('visualization-nav-el')){
        tabcontent[i].style.display = "block";
      }
    }
    /*var i, tabcontent, tablinks;
    tabcontent = document.getElementsByClassName("tabcontent");
    for (i = 0; i < tabcontent.length; i++) {
      tabcontent[i].style.display = "none";
    }
    tablinks = document.getElementsByClassName("tablinks");
    for (i = 0; i < tablinks.length; i++) {
      tablinks[i].className = tablinks[i].className.replace(" active", "");
    }
    document.getElementById(cityName).style.display = "block";
    evt.currentTarget.className += " active";*/
}

// Get the element with id="defaultOpen" and click on it
//document.getElementById("defaultOpen").click();