# programs
function copyText() {
  var copyText = document.getElementById("copyText").textContent;

  var tempInput = document.createElement("input");
  tempInput.value = copyText;
  document.body.appendChild(tempInput);
  tempInput.select();
  document.execCommand("copy");
  document.body.removeChild(tempInput);

  alert("Copied: " + copyText);
}
