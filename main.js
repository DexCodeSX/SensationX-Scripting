// Wait until the DOM is fully loaded
document.addEventListener('DOMContentLoaded', () => {
  
  // Variables for interactive elements
  const learnMoreBtn = document.getElementById('learnMoreBtn');
  const extraInfo = document.getElementById('extraInfo');
  let isInfoVisible = false;

  // Event listener for 'Learn More' button click
  learnMoreBtn.addEventListener('click', () => {
    if (!isInfoVisible) {
      showExtraInfo();
    } else {
      hideExtraInfo();
    }
  });

  // Function to show additional information with a smooth fade-in
  function showExtraInfo() {
    extraInfo.style.display = 'block';
    extraInfo.innerHTML = `
      <p>Welcome to the next level of Roblox scripting! Stay tuned for powerful exploits with SensationX!</p>
    `;
    learnMoreBtn.innerText = 'Show Less';
    isInfoVisible = true;
  }

  // Function to hide additional information
  function hideExtraInfo() {
    extraInfo.style.display = 'none';
    learnMoreBtn.innerText = 'Learn More';
    isInfoVisible = false;
  }

  // Button hover effect (optional, more dynamic)
  learnMoreBtn.addEventListener('mouseenter', () => {
    learnMoreBtn.style.transform = 'translateY(-3px)';
  });

  learnMoreBtn.addEventListener('mouseleave', () => {
    learnMoreBtn.style.transform = 'translateY(0px)';
  });
  
  // Optional: Make the logo respond to a click with a smooth effect
  const logo = document.querySelector('.logo');
  logo.addEventListener('click', () => {
    logo.style.transform = 'rotate(360deg)';
    setTimeout(() => {
      logo.style.transform = 'rotate(0deg)'; // Reset after animation
    }, 500);
  });

  // Accessibility improvement: Ensure key navigation for buttons
  learnMoreBtn.addEventListener('keydown', (e) => {
    if (e.key === 'Enter' || e.key === ' ') {
      learnMoreBtn.click();
    }
  });

});
