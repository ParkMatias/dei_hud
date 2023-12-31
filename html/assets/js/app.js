$(function () {
  window.addEventListener("message", function (event) {
    var v = event.data;
    switch (v.action) {
      case "showHud":
        $(".container").fadeIn();
        $(".id").text(`${v.playerid}`);
        $(".health").text(`${v.health}`);
        $(".armor").text(`${v.armor}`);
        $(".stamina").text(`${v.stamina}`);
        $(".thirst").text(`${v.thirst}`);
        $(".hunger").text(`${v.hunger}`);
        if (v.job) {
          $(".job").text(`${v.job}`);
        } else {
          $(".jobrp").css("display", "none");
        }
        if (v.map) {
          $("#left-panel").css("left", "30vh");
        }
        break;
      case "hideHud":
        $(".container").fadeOut();
        break;
      case "showSpeed":
        $(".speedo").fadeIn();
        if (v.map) {
          $("#left-panel").css("left", "30vh");
        }
        break;
      case "hideSpeed":
        $(".speedo").fadeOut();
        if (!v.map) {
          $("#left-panel").css("left", "1.5vh");
        }
        break;
      case "vehicleStatus":
        const enginecolor = v.engine == 1 ? "white" : "red";
        const lightcolor = v.light == 1 ? "white" : "red";
        $(".speed").text(`${v.speed}`);
        $(".engine").css("color", enginecolor);
        $(".light").css("color", lightcolor);
        $(".progressBar").css("width", `${v.rpm}`);
        break;
      case "cruiseControl":
        const cruise = v.cruise == 1 ? "white" : "red";
        $(".limiter").css("color", cruise);
        break;
      case "toggleColor":
        $(".icon-circle").css("background-color", $(".icon-circle").css("background-color") === 'rgb(0, 0, 0)' ? 'white' : 'black');
        $("#left-panel div i").css("color", $("#left-panel div i").css("color") === 'rgb(255, 255, 255)' ? 'black' : 'white');
        $("#right-panel div i").css("color", $("#right-panel div i").css("color") === 'rgb(255, 255, 255)' ? 'black' : 'white');
        break;
    }
  });

  const logo = document.querySelector(".rotating");
  let isRotating = false;

  function rotateLogo() {
    if (!isRotating) {
      isRotating = true;

      logo.style.transition = "transform 1s linear";
      logo.style.transform = "rotateY(360deg)";

      setTimeout(function () {
        logo.style.transition = "none";
        logo.style.transform = "rotateY(0deg)";

        isRotating = false;
      }, 2000);
    }
  }

  rotateLogo();
  setInterval(rotateLogo, 30000);
});
