# programs
function copyText() {
  // Отримати елемент з текстом
  var copyText = document.getElementById("copyText").textContent;

  // Створити тимчасовий елемент для копіювання
  var tempInput = document.createElement("input");
  tempInput.value = copyText;
  document.body.appendChild(tempInput);
  tempInput.select();
  document.execCommand("copy");
  document.body.removeChild(tempInput);

  // Можна відобразити повідомлення про успішне копіювання
  alert("Copied: " + copyText);
}
