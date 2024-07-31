/*
#  /usr/share/bigbashview/bcc/apps/big-store/js/script.js
#  Description: JS Library for BigLinux Config
#
#  Created: 2024/05/31
#  Altered: 2024/07/14
#
#  Copyright (c) 2023-2024, Vilmar Catafesta <vcatafesta@gmail.com>
#                2020-2023, Bruno Gonçalves <www.biglinux.com.br>
#                2020-2023, Rafael Ruscher <rruscher@gmail.com>
#                2020-2023, eltonff <www.biglinux.com.br>
#  All rights reserved.
#
#  Redistribution and use in source and binary forms, with or without
#  modification, are permitted provided that the following conditions
#  are met:
#  1. Redistributions of source code must retain the above copyright
#     notice, this list of conditions and the following disclaimer.
#  2. Redistributions in binary form must reproduce the above copyright
#     notice, this list of conditions and the following disclaimer in the
#     documentation and/or other materials provided with the distribution.
#
#  THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR
#  IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
#  OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
#  IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT,
#  INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
#  NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
#  DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
#  THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
#  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
#  THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

/* LEGENDA BOX STATUS BAR */
$(".box-items").mouseover(function () {
  $(this).children("#box-status-bar").css("display", "block");
});

$(".box-items").mouseout(function () {
  $(this).children("#box-status-bar").css("display", "none");
});
/* FIM LEGENDA BOX STATUS BAR */

$(document).on("click", "#point-container", function () {
  var show = $(this).data("show");
  $(show).removeClass("hide").siblings().addClass("hide");
});

$(function () {
  $(".menu-link").click(function () {
    $(".menu-link").removeClass("is-active");
    $(this).addClass("is-active");
  });
});

$(function () {
  $(".main-header-link").click(function () {
    $(".main-header-link").removeClass("is-active");
    $(this).addClass("is-active");
  });
});

const dropdowns = document.querySelectorAll(".dropdown");
dropdowns.forEach((dropdown) => {
  dropdown.addEventListener("click", (e) => {
    e.stopPropagation();
    dropdowns.forEach((c) => c.classList.remove("is-active"));
    dropdown.classList.add("is-active");
  });
});

$(".search-bar input")
  .focusin(function () {
    $(".header").addClass("wide");
  })
  .focusout(function () {
    $(".header").removeClass("wide");
  });

//##################################################################################################

$(".dark-light").click(function (e) {
  e.preventDefault();
  var state = $("body").hasClass("light-mode");
  _run("sh_bstr_setbgcolor " + state);
  console.log("light-mode =:", state);
  $("body").toggleClass("light-mode");
  state = $("body").hasClass("light-mode");
  console.log("light-mode =:", state);
});

//##################################################################################################

var modals = document.getElementsByClassName("modal");
var modalOpenBtn = document.getElementsByClassName("modalOpenBtn");
var currentModal = null;

// Function to open modal by id
function openModal(id) {
  for (i = 0; i < modals.length; i++) {
    if (modals[i].getAttribute("id") == id) {
      currentModal = modals[i];
      currentModal.style.display = "block";
      break;
    }
  }
}

// When the user clicks the button, open modal with the same id
modalOpenBtn.onclick = function () {
  let currentID = modalOpenBtn.getAttribute("id");
  openModal(currentID);
};

// When the user clicks anywhere outside of the modal or the X, close
window.onclick = function (event) {
  if (
    event.target == currentModal ||
    event.target.getAttribute("class") == "modalClose"
  ) {
    currentModal.style.display = "none";
  }
};

//Fecha welcome
$(function () {
  $(".content-wrapper-header .close").click(function () {
    $("#welcome").css("display", "none");
  });
});

var bigcount = 1;
$("#btn-big").click(function () {
  if (bigcount >= 3 && bigcount <= 3) {
    $("#welcome").css("display", "flex");
  } else if (bigcount >= 6 && bigcount <= 6) {
    $("body").css("background-image", 'url("img/body-bg.jpg")');
  } else if (bigcount >= 9) {
    window.location = ".javascript-racer-master/racer.sh.htm";
  }
  ++bigcount;
});

$('input[name="searchFilter_checkbox"]').change(function (e) {
  e.preventDefault();
  const dataValue = $(this).data("value");
  console.log("Data-value:", dataValue);
  if ($(this).is(":checked")) {
    _run(`TIni.Set ${dataValue} bigstore searchFilter checked`);
  } else {
    _run(`TIni.Set ${dataValue} bigstore searchFilter`);
  }
});

$('input[name="resultFilter_checkbox"]').change(function (e) {
  e.preventDefault();
  const dataValue = $(this).data("value");
  console.log("Data-value:", dataValue);
  if ($(this).is(":checked")) {
    _run(`TIni.Set ${dataValue} bigstore resultFilter checked`);
  } else {
    _run(`TIni.Set ${dataValue} bigstore resultFilter`);
  }
});

