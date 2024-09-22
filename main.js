function showAlert() {
    alert("More details coming soon. Stay tuned for the SensationX script!");
}

console.log('Bisam - About Me page loaded.');

// Animated counters for skill percentages
const counters = document.querySelectorAll('.counter');
const speed = 200; // The lower the speed, the faster the animation

counters.forEach(counter => {
    const updateCount = () => {
        const target = +counter.getAttribute('data-target');
        const count = +counter.innerText;

        const inc = target / speed;

        if (count < target) {
            counter.innerText = Math.ceil(count + inc);
            setTimeout(updateCount, 10);
        } else {
            counter.innerText = target;
        }
    };

    updateCount();
});

// Scroll-triggered animations
const faders = document.querySelectorAll('.fade-in-on-scroll');
const cards = document.querySelectorAll('.floating-card');

const appearOptions = {
    threshold: 0.1,
    rootMargin: "0px 0px -100px 0px"
};

const appearOnScroll = new IntersectionObserver(function(entries, appearOnScroll) {
    entries.forEach(entry => {
        if (!entry.isIntersecting) {
            return;
        } else {
            entry.target.classList.add('active');
            appearOnScroll.unobserve(entry.target);
        }
    });
}, appearOptions);

faders.forEach(fader => {
    appearOnScroll.observe(fader);
});

cards.forEach(card => {
    appearOnScroll.observe(card);
});
