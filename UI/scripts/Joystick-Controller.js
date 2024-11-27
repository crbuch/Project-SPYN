const joystickContainer = document.getElementById("joystick-container");
const joystick = document.getElementById("joystick");
const slider = document.getElementById("slider");

const joystickRadius = joystickContainer.offsetWidth / 2;
const joystickMaxMovement = joystickRadius - joystick.offsetWidth / 2;
let isDraggingJoystick = false;
let isDraggingSlider = false;

let lr = 0;
let ud = 0;
let lift = 0;
let htmlComponent;

function moveJoystick(event) {
  let x, y;

  if (event.touches) {
    x = event.touches[0].clientX;
    y = event.touches[0].clientY;
  } else {
    x = event.clientX;
    y = event.clientY;
  }

  const containerRect = joystickContainer.getBoundingClientRect();
  const centerX = containerRect.left + joystickRadius;
  const centerY = containerRect.top + joystickRadius;

  let deltaX = x - centerX;
  let deltaY = y - centerY;

  const distance = Math.min(
    Math.sqrt(deltaX * deltaX + deltaY * deltaY),
    joystickMaxMovement
  );
  const angle = Math.atan2(deltaY, deltaX);

  joystick.style.left = `${
    joystickRadius + distance * Math.cos(angle) - joystick.offsetWidth / 2
  }px`;
  joystick.style.top = `${
    joystickRadius + distance * Math.sin(angle) - joystick.offsetHeight / 2
  }px`;

  const horizontal = deltaX / joystickMaxMovement;
  const vertical = deltaY / joystickMaxMovement;

  lr = Math.min(Math.max(horizontal.toFixed(2), -1), 1);
  ud = Math.min(Math.max(vertical.toFixed(2) * -1, -1), 1);

}

function startJoystickDrag(event) {
  isDraggingJoystick = true;
  moveJoystick(event);
}

function stopJoystickDrag() {
  isDraggingJoystick = false;
  joystick.style.left = `${joystickRadius - joystick.offsetWidth / 2}px`;
  joystick.style.top = `${joystickRadius - joystick.offsetHeight / 2}px`;

  lr = 0;
  ud = 0;
}

function setup(htmlComp) {
  htmlComponent = htmlComp;
}

setInterval(function(){
  if(htmlComponent!==undefined){
    htmlComponent.sendEventToMATLAB("DataChange", [lr, ud, lift]);
  }
}, 200)


function moveSlider(event) {
  if (isDraggingSlider) {
    let x, y;

    if (event.touches) {
      x = event.touches[0].clientX;
      y = event.touches[0].clientY;
    } else {
      x = event.clientX;
      y = event.clientY;
    }

    const containerRect = document
      .getElementById("slider-container")
      .getBoundingClientRect();
    let newTop = y - containerRect.top - slider.offsetHeight / 2;

    newTop = Math.max(
      0,
      Math.min(newTop, containerRect.height - slider.offsetHeight)
    );

    slider.style.top = `${newTop}px`;

    const liftValue = newTop / (containerRect.height - slider.offsetHeight);
    lift = -2 * liftValue.toFixed(2) + 1;
  }
}

function startSliderDrag(event) {
  isDraggingSlider = true;
  moveSlider(event);
}

window.onload = function () {
  const containerRect = document
    .getElementById("slider-container")
    .getBoundingClientRect();
  slider.style.top = `${(containerRect.height - slider.offsetHeight) / 2}px`;
};

function stopSliderDrag() {
  isDraggingSlider = false;
  const containerRect = document
    .getElementById("slider-container")
    .getBoundingClientRect();
  slider.style.top = `${(containerRect.height - slider.offsetHeight) / 2}px`;

  lift = 0;
}

joystickContainer.addEventListener("mousedown", startJoystickDrag);
joystickContainer.addEventListener("touchstart", startJoystickDrag);

document.addEventListener("mousemove", (event) => {
  if (isDraggingJoystick) {
    moveJoystick(event);
  } else if (isDraggingSlider) {
    moveSlider(event);
  }
});

document.addEventListener("touchmove", (event) => {
  if (isDraggingJoystick) {
    moveJoystick(event);
  } else if (isDraggingSlider) {
    moveSlider(event);
  }
});

document.addEventListener("mouseup", stopJoystickDrag);
document.addEventListener("touchend", stopJoystickDrag);

slider.addEventListener("mousedown", startSliderDrag);
slider.addEventListener("touchstart", startSliderDrag);

document.addEventListener("mouseup", stopSliderDrag);
document.addEventListener("touchend", stopSliderDrag);


document.getElementById("startDrivingBtn").onclick = function(){
  htmlComponent.sendEventToMATLAB("ControlStateChange", true);
}


