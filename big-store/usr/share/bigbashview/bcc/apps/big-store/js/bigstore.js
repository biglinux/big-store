// Javascript to replace div content using file
// Example to enable disabled div: $('#pkgInstallBtn').attr('disabled', false);

function fileReplaceDiv(i, div, file) {
  if (i == true) {
    setTimeout(function () {
      $.ajax({
        url: file,
        type: "GET",
        error: function () {
          console.log("Loop");
          fileReplaceDiv(true, div, file);
        },
        success: function () {
          $(div).load(file);
          fileReplaceDiv(false);
        },
      });
    }, 500);
  }
}

function fileEnableDiv(i, div, file) {
  if (i == true) {
    setTimeout(function () {
      $.ajax({
        url: file,
        type: "GET",
        error: function () {
          console.log("Loop");
          fileEnableDiv(true, div, file);
        },
        success: function () {
          $(div).attr("disabled", false);
          fileEnableDiv(false);
        },
      });
    }, 500);
  }
}

if (sessionStorage.getItem("refresh") == "true") {
  window.location.reload();
}

// Avatar with colors from https://marcoslooten.com/blog/creating-avatars-with-colors-using-the-modulus/
const colors = [
  "#d50000",
  "#9c27b0",
  "#3f51b5",
  "#00796b",
  "#8d6e63",
  "#b71c1c",
  "#880e4f",
  "#4a148c",
  "#3f51b5",
  "#2196f3",
  "#827717",
  "#ef6c00",
  "#e65100",
  "#546e7a",
  "#009688",
];

function runAvatarAppstream() {
  function numberFromText(text) {
    // numberFromText("AA");
    const charCodes = text
      .split("") // => ["A", "A"]
      .map((char) => char.charCodeAt(0)) // => [65, 65]
      .join(""); // => "6565"
    return parseInt(charCodes, 10);
  }

  const avatars = document.querySelectorAll(".avatar_appstream");

  avatars.forEach((avatar) => {
    const text = avatar.innerText; // => "AA"
    avatar.style.backgroundColor = colors[numberFromText(text) % colors.length]; // => "#DC2A2A"
  });
}

function runAvatarAur() {
  function numberFromText(text) {
    // numberFromText("AA");
    const charCodes = text
      .split("") // => ["A", "A"]
      .map((char) => char.charCodeAt(0)) // => [65, 65]
      .join(""); // => "6565"
    return parseInt(charCodes, 10);
  }

  const avatars = document.querySelectorAll(".avatar_aur");

  avatars.forEach((avatar) => {
    const text = avatar.innerText; // => "AA"
    avatar.style.backgroundColor = colors[numberFromText(text) % colors.length]; // => "#DC2A2A"
  });
}

function runAvatarFlatpak() {
  function numberFromText(text) {
    // numberFromText("AA");
    const charCodes = text
      .split("") // => ["A", "A"]
      .map((char) => char.charCodeAt(0)) // => [65, 65]
      .join(""); // => "6565"
    return parseInt(charCodes, 10);
  }

  const avatars = document.querySelectorAll(".avatar_flatpak");

  avatars.forEach((avatar) => {
    const text = avatar.innerText; // => "AA"
    avatar.style.backgroundColor = colors[numberFromText(text) % colors.length]; // => "#DC2A2A"
  });
}

function runAvatarSnap() {
  function numberFromText(text) {
    // numberFromText("AA");
    const charCodes = text
      .split("") // => ["A", "A"]
      .map((char) => char.charCodeAt(0)) // => [65, 65]
      .join(""); // => "6565"
    return parseInt(charCodes, 10);
  }

  const avatars = document.querySelectorAll(".avatar_snap");

  avatars.forEach((avatar) => {
    const text = avatar.innerText; // => "AA"
    avatar.style.backgroundColor = colors[numberFromText(text) % colors.length]; // => "#DC2A2A"
  });
}

function disableBody() {
  $("body").css({
    "pointer-events": "none",
  });
  $("#box_progress").css({
    display: "inline-flex",
  });
}

function disableBodyConfig() {
  $("#box_progress_config").css({
    display: "inline-flex",
  });
}
/*
function disableBodySnapInstall() {
  $('#box_progress_snap_install').css({
    'display':'inline'
  });
}

function disableBodySnapRemove() {
  $('#box_progress_snap_remove').css({
    'display':'inline'
  });
}

function disableBodyFlatpakInstall() {
  $('#box_progress_flatpak_install').css({
    'display':'inline'
  });
}

function disableBodyFlatpakRemove() {
  $('#box_progress_flatpak_remove').css({
    'display':'inline'
  });
}



function disableButtonFlatpakInstall() {
  $('#box_progress_flatpak_cancel').css({
    'display':'none'
  });
}*/

function disableBodySnapInstall() {
  $("#box_progress_config").css({
    display: "inline",
  });
}

function disableBodySnapRemove() {
  $("#box_progress_config").css({
    display: "inline",
  });
}

function disableBodyFlatpakInstall() {
  $("#box_progress_config").css({
    display: "inline",
  });

  $("#box_progress_flatpak_cancel").css({
    display: "inline",
  });
}

function disableBodyFlatpakRemove() {
  $("#box_progress_config").css({
    display: "inline",
  });
}

function disableButtonFlatpakInstall() {
  $("#box_progress_config").css({
    display: "inline",
  });
}

function disableBodyConfigSimple() {
  $("#box_progress_config").css({
    display: "inline",
  });
}
function disableBodyConfig() {
  $("#box_progress_config").css({
    display: "inline",
  });
}
