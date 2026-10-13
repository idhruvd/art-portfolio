document.addEventListener('DOMContentLoaded', () => {
  "use strict";

  /**
   * Mobile nav toggle
   */
  const body = document.body;
  const showBtn = document.querySelector('.mobile-nav-show');
  const hideBtn = document.querySelector('.mobile-nav-hide');

  function toggleMobileNav() {
    body.classList.toggle('mobile-nav-active');
    showBtn.classList.toggle('d-none');
    hideBtn.classList.toggle('d-none');
  }

  document.querySelectorAll('.mobile-nav-toggle').forEach(btn => {
    btn.addEventListener('click', toggleMobileNav);
  });

  // Close the mobile menu after picking a section
  document.querySelectorAll('#navbar a').forEach(link => {
    link.addEventListener('click', () => {
      if (body.classList.contains('mobile-nav-active')) toggleMobileNav();
    });
  });

  /**
   * Highlight the nav link for the section in view
   */
  const navLinks = [...document.querySelectorAll('#navbar a[href^="#"]')];
  const sections = navLinks
    .map(link => document.querySelector(link.hash))
    .filter(Boolean);

  if ('IntersectionObserver' in window) {
    const observer = new IntersectionObserver(entries => {
      entries.forEach(entry => {
        if (!entry.isIntersecting) return;
        navLinks.forEach(link => {
          link.classList.toggle('active', link.hash === '#' + entry.target.id);
        });
      });
    }, { rootMargin: '-45% 0px -50% 0px' });
    sections.forEach(section => observer.observe(section));
  }

  /**
   * Lightbox for the paintings
   */
  GLightbox({ selector: '.glightbox' });

  /**
   * Copy email button, for visitors whose mailto links open the wrong app
   */
  document.querySelectorAll('.copy-btn').forEach(btn => {
    btn.addEventListener('click', async () => {
      const label = btn.querySelector('span');
      try {
        await navigator.clipboard.writeText(btn.dataset.copy);
        label.textContent = 'Copied';
      } catch (e) {
        label.textContent = 'Copy failed';
      }
      setTimeout(() => { label.textContent = 'Copy'; }, 2000);
    });
  });

  document.getElementById('year').textContent = new Date().getFullYear();
});
