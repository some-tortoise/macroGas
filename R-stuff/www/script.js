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
    var content_div = document.getElementsByClassName("tabbable")[0];
    for (i = 0; i < tabcontent.length; i++) {
      tabcontent[i].style.display = "block";
      if(tabcontent[i].classList.contains('home-panel-container') && evt.currentTarget.parentElement.classList.contains('home-nav-el')){
        tabcontent[i].style.display = "block";
        content_div.scrollTo({
            top: 0,
            behavior: 'smooth'
        });
      }
      if(tabcontent[i].classList.contains('upload-panel-container') && evt.currentTarget.parentElement.classList.contains('upload-nav-el')){
        tabcontent[i].style.display = "block";
        content_div.scrollTo({
            top: 740,
            behavior: 'smooth'
        });
      }
      if(tabcontent[i].classList.contains('flag-panel-container') && evt.currentTarget.parentElement.classList.contains('flag-nav-el')){
        tabcontent[i].style.display = "block";
        content_div.scrollTo({
            top: 1520,
            behavior: 'smooth'
        });
      }
      if(tabcontent[i].classList.contains('calculate-panel-container') && evt.currentTarget.parentElement.classList.contains('calculate-nav-el')){
        tabcontent[i].style.display = "block";
        content_div.scrollTo({
            top: 2277,
            behavior: 'smooth'
        });
      }
      if(tabcontent[i].classList.contains('visualize-panel-container') && evt.currentTarget.parentElement.classList.contains('visualize-nav-el')){
        tabcontent[i].style.display = "block";
        content_div.scrollTo({
            top: 3032,
            behavior: 'smooth'
        });
      }
    }  
}

document.getElementsByClassName("tabbable")[0].addEventListener("scroll", scrollOpenTab);

function scrollOpenTab() {
  //document.getElementById("demo").innerHTML = "You scrolled in div.";
  var x = document.getElementsByClassName("tabbable")[0].scrollTop;
  var nav_show = '';
  if(x >= 0 && x < 740){
    nav_show = 'home-nav-el';
  }else if (x >= 740 && x < 1520) {
    nav_show = 'upload-nav-el';
  } else if(x >= 1520 && x < 2277){
    nav_show = 'flag-nav-el';
  }else if(x >= 2277 && x < 3032){
    nav_show = 'calculate-nav-el';
  }else if(x >= 3032){
    nav_show = 'visualize-nav-el';
  } 
  tablinks = document.getElementsByClassName("nav-el-circle");
  for (i = 0; i < tablinks.length; i++) {
    tablinks[i].className = tablinks[i].className.replace(" active-nav-el", "");
  }
  tablinks = document.getElementsByClassName("nav-text");
  for (i = 0; i < tablinks.length; i++) {
    tablinks[i].className = tablinks[i].className.replace(" active-nav-text", "");
  }
  document.getElementsByClassName(nav_show)[0].children[0].className += " active-nav-el";
  document.getElementsByClassName(nav_show)[0].children[1].className += " active-nav-text";
}