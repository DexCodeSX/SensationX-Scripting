window.onload = function() {
    console.log('Page fully loaded. Starting animations and counters...');

    // Smooth scroll for internal links
    document.querySelectorAll('a[href^="#"]').forEach(anchor => {
        anchor.addEventListener('click', function(e) {
            e.preventDefault();
            document.querySelector(this.getAttribute('href')).scrollIntoView({
                behavior: 'smooth'
            });
        });
    });

    // Alert for the "Learn More About Me" button
    document.querySelector('.btn')?.addEventListener('click', function() {
        alert("More details coming soon. Stay tuned for the SensationX script!");
    });

    // Animated counters for skill percentages
    const counters = document.querySelectorAll('.counter');
    const speed = 200; // Lower the number, faster the animation

    counters.forEach(counter => {
        const updateCount = () => {
            const target = +counter.getAttribute('data-target');
            const count = +counter.innerText;

            // Calculate increment
            const increment = target / speed;

            // Update count until the target is reached
            if (count < target) {
                counter.innerText = Math.ceil(count + increment);
                setTimeout(updateCount, 20);
            } else {
                counter.innerText = target;
            }
        };
        updateCount();
    });

    // Fade-in animations for elements on scroll
    const faders = document.querySelectorAll('.fade-in-on-scroll');
    const appearOptions = {
        threshold: 0.1,
        rootMargin: "0px 0px -100px 0px"
    };

    const appearOnScroll = new IntersectionObserver(function(entries, observer) {
        entries.forEach(entry => {
            if (!entry.isIntersecting) {
                return;
            } else {
                entry.target.classList.add('active');
                observer.unobserve(entry.target);
            }
        });
    }, appearOptions);

    faders.forEach(fader => {
        appearOnScroll.observe(fader);
    });

    // Ensure floating cards also wait for full page load before appearing
    const cards = document.querySelectorAll('.floating-card');
    cards.forEach(card => {
        appearOnScroll.observe(card);
    });
};
