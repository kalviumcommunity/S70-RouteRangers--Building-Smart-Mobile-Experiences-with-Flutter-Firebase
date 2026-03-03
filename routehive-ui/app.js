/* ===========================
   RouteHive App Logic
   =========================== */

document.addEventListener('DOMContentLoaded', () => {
  // ---- Elements ----
  const screens = document.querySelectorAll('.screen');
  const navItems = document.querySelectorAll('.nav-item');
  const fab = document.getElementById('fab-hazard');
  const hazardSheet = document.getElementById('hazard-sheet');
  const sheetOverlay = document.getElementById('sheet-overlay');
  const stars = document.querySelectorAll('#star-rating .star');
  const tagBtns = document.querySelectorAll('.tag-btn');
  const filterChips = document.querySelectorAll('.filter-chip');
  const btnLogin = document.getElementById('btn-login');
  const btnGoogle = document.getElementById('btn-google');
  const btnSubmitHazard = document.getElementById('btn-submit-hazard');

  // ---- Splash Screen Auto-Transition ----
  setTimeout(() => {
    navigateTo('screen-login');
  }, 3000);

  // ---- Screen Navigation ----
  function navigateTo(screenId) {
    const currentScreen = document.querySelector('.screen.active');
    const targetScreen = document.getElementById(screenId);

    if (!targetScreen || currentScreen === targetScreen) return;

    // Fade out current
    if (currentScreen) {
      currentScreen.classList.add('fade-out');
      setTimeout(() => {
        currentScreen.classList.remove('active', 'fade-out');
      }, 300);
    }

    // Fade in target
    setTimeout(() => {
      targetScreen.classList.add('active', 'fade-in');
      setTimeout(() => {
        targetScreen.classList.remove('fade-in');
      }, 400);
    }, currentScreen ? 280 : 0);

    // Update nav items across all screens
    document.querySelectorAll('.nav-item').forEach(item => {
      item.classList.toggle('active', item.dataset.screen === screenId);
    });
  }

  // ---- Bottom Nav Click ----
  navItems.forEach(item => {
    item.addEventListener('click', () => {
      const targetScreen = item.dataset.screen;
      if (targetScreen) {
        navigateTo(targetScreen);
      }
    });
  });

  // ---- Login Button ----
  if (btnLogin) {
    btnLogin.addEventListener('click', (e) => {
      e.preventDefault();
      // Ripple effect
      btnLogin.style.transform = 'scale(0.97)';
      setTimeout(() => {
        btnLogin.style.transform = '';
        navigateTo('screen-home');
      }, 150);
    });
  }

  if (btnGoogle) {
    btnGoogle.addEventListener('click', (e) => {
      e.preventDefault();
      navigateTo('screen-home');
    });
  }

  // ---- FAB -> Open Hazard Sheet ----
  if (fab) {
    fab.addEventListener('click', () => {
      openSheet();
    });
  }

  function openSheet() {
    hazardSheet.classList.add('active');
    sheetOverlay.classList.add('active');
  }

  function closeSheet() {
    hazardSheet.classList.remove('active');
    sheetOverlay.classList.remove('active');
  }

  if (sheetOverlay) {
    sheetOverlay.addEventListener('click', closeSheet);
  }

  // ---- Star Rating ----
  let currentRating = 0;

  stars.forEach(star => {
    star.addEventListener('click', () => {
      currentRating = parseInt(star.dataset.value);
      updateStars();
    });

    star.addEventListener('mouseenter', () => {
      highlightStars(parseInt(star.dataset.value));
    });

    star.addEventListener('mouseleave', () => {
      updateStars();
    });
  });

  function updateStars() {
    stars.forEach(star => {
      const val = parseInt(star.dataset.value);
      star.classList.toggle('active', val <= currentRating);
    });
  }

  function highlightStars(upTo) {
    stars.forEach(star => {
      const val = parseInt(star.dataset.value);
      star.classList.toggle('active', val <= upTo);
    });
  }

  // ---- Tag Toggle ----
  tagBtns.forEach(btn => {
    btn.addEventListener('click', () => {
      btn.classList.toggle('active');
    });
  });

  // ---- Filter Chips ----
  filterChips.forEach(chip => {
    chip.addEventListener('click', () => {
      filterChips.forEach(c => c.classList.remove('active'));
      chip.classList.add('active');
    });
  });

  // ---- Submit Hazard ----
  if (btnSubmitHazard) {
    btnSubmitHazard.addEventListener('click', () => {
      // Flash success feedback
      btnSubmitHazard.textContent = '✅ Report Submitted!';
      btnSubmitHazard.style.background = 'linear-gradient(135deg, #4CAF50 0%, #388E3C 100%)';
      btnSubmitHazard.style.color = '#fff';
      btnSubmitHazard.style.boxShadow = '0 4px 20px rgba(76, 175, 80, 0.35)';

      setTimeout(() => {
        closeSheet();
        // Reset button
        setTimeout(() => {
          btnSubmitHazard.innerHTML = `
            <svg viewBox="0 0 20 20" fill="none" width="18" height="18"><path d="M2 10l6 6L18 4" stroke="white" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"/></svg>
            Submit Report
          `;
          btnSubmitHazard.style.background = '';
          btnSubmitHazard.style.color = '';
          btnSubmitHazard.style.boxShadow = '';
          // Reset form
          currentRating = 0;
          updateStars();
          tagBtns.forEach(b => b.classList.remove('active'));
          document.getElementById('hazard-desc').value = '';
        }, 400);
      }, 1200);
    });
  }

  // ---- Touch drag-to-close for bottom sheet ----
  let sheetStartY = 0;
  let sheetCurrentY = 0;
  let isDragging = false;

  const sheetHandle = hazardSheet?.querySelector('.sheet-handle');

  if (sheetHandle) {
    sheetHandle.addEventListener('touchstart', (e) => {
      isDragging = true;
      sheetStartY = e.touches[0].clientY;
      hazardSheet.style.transition = 'none';
    });

    document.addEventListener('touchmove', (e) => {
      if (!isDragging) return;
      sheetCurrentY = e.touches[0].clientY;
      const diff = sheetCurrentY - sheetStartY;
      if (diff > 0) {
        hazardSheet.style.transform = `translateY(${diff}px)`;
      }
    });

    document.addEventListener('touchend', () => {
      if (!isDragging) return;
      isDragging = false;
      hazardSheet.style.transition = '';
      const diff = sheetCurrentY - sheetStartY;
      if (diff > 100) {
        closeSheet();
      } else {
        hazardSheet.style.transform = '';
        if (hazardSheet.classList.contains('active')) {
          hazardSheet.style.transform = 'translateY(0)';
        }
      }
    });
  }
});
