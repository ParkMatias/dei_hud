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
        break;
      case "hideHud":
        $(".container").fadeOut();
        break;
      case "showSpeed":
        $(".speedo").fadeIn();
        $(".speed").text(`${v.speed}`);
        $(".progressBar").css("width", `${v.fuel}`);
        break;
      case "showLights":
        $(".lights").css("color", "yellow");
        break;
      case "hideLights":
        $(".lights").css("color", "white");
        break;
      case "showEngine":
        $(".engine").css("color", "white");
        break;
      case "hideEngine":
        $(".engine").css("color", "red");
        break;
      case "hideSpeed":
        $(".speedo").fadeOut();
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
