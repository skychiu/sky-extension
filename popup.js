const loveBtn = document.getElementById('loveBtn');
const mainContent = document.getElementById('mainContent');
const loveMessage = document.getElementById('loveMessage');
const backBtn = document.getElementById('backBtn');

loveBtn.addEventListener('click', () => {
    console.log('Button clicked!');
    mainContent.classList.add('hidden');
    loveMessage.classList.add('show');
});

backBtn.addEventListener('click', () => {
    console.log('Back button clicked!');
    loveMessage.classList.remove('show');
    mainContent.classList.remove('hidden');
});