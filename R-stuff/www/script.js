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

    
    let classList = evt.currentTarget.parentElement.classList;
    let topDist = 0;
    let screenSize = document.getElementsByClassName("tabbable")[0].clientHeight;
    console.log(screenSize);
    if(classList.contains('home-nav-el')){
        topDist = 0;
    }else if(classList.contains('upload-nav-el')){
        topDist = screenSize;
    }else if(classList.contains('order-nav-el')){
        topDist = 2*screenSize;
    }else if(classList.contains('flag-nav-el')){
        topDist = 3*screenSize;
    }else if(classList.contains('calculate-nav-el')){
        topDist = 4*screenSize;
    }else{
        console.log('Weird navbar behavior occured.');
    }
    content_div.scrollTo({
        top: topDist,
        behavior: 'smooth'
    });

}

document.getElementsByClassName("tabbable")[0].addEventListener("scroll", scrollOpenTab);

function scrollOpenTab() {
  var x = document.getElementsByClassName("tabbable")[0].scrollTop;
  let dist = document.getElementsByClassName("tabbable")[0].scrollTop;
  var nav_show = '';
  let screenSize = document.getElementsByClassName("tabbable")[0].clientHeight;
  if(dist < screenSize){ nav_show = 'home-nav-el'; }
  else if (dist < 2*screenSize) { nav_show = 'upload-nav-el'; }
  else if (dist < 3*screenSize) { nav_show = 'order-nav-el'; }
  else if(dist < 4*screenSize){ nav_show = 'flag-nav-el'; }
  else if(dist < 5*screenSize){ nav_show = 'calculate-nav-el'; }

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