# programs
<div class="copy-container">
  <code id="copyText">https://example.com</code>
  <button class="copy-btn" onclick="copyText()">
    <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" width="24" height="24">
      <path fill="#999" d="M16 1H4c-1.1 0-2 .9-2 2v14h2V3h12V1zm3 4H8c-1.1 0-2 .9-2 2v14c0 1.1.9 2 2 2h11c1.1 0 2-.9 2-2V7c0-1.1-.9-2-2-2zm0 16H8V7h11v14z"/>
    </svg>
  </button>
</div>
.copy-container {
  display: flex;
  align-items: center;
}

.copy-btn {
  margin-left: 10px;
  background: none;
  border: none;
  cursor: pointer;
  padding: 0;
  display: inline-flex;
  align-items: center;
}

.copy-btn svg {
  fill: #999;
  transition: fill 0.3s ease;
}

.copy-btn:hover svg {
  fill: #4CAF50;
}
