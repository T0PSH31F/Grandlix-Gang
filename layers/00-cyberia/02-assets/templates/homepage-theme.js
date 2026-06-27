/* Homepage Dashboard Lovable Theme — Background + Host Badge + Search Labels + Status Dots */

(function () {
  console.log('Initializing Lovable Theme Effects...');

  // ==================================================================
  // 1. BACKGROUND  —  CSS gradient (no remote image fetch for fast load)
  // ==================================================================
  const bgContainer = document.createElement('div');
  bgContainer.id = 'lovable-background';
  document.body.prepend(bgContainer);

  // Holographic grid
  const grid = document.createElement('div');
  grid.className = 'holographic-grid';
  bgContainer.appendChild(grid);

  // Fog layers
  const fog1 = document.createElement('div');
  fog1.className = 'fog-layer';
  fog1.style.top = '30%';
  fog1.style.height = '200px';
  fog1.style.background = 'radial-gradient(ellipse at center, hsl(190,100%,50%), transparent)';
  bgContainer.appendChild(fog1);

  const fog2 = document.createElement('div');
  fog2.className = 'fog-layer';
  fog2.style.top = '50%';
  fog2.style.height = '300px';
  fog2.style.background = 'radial-gradient(ellipse at center, hsl(280,100%,50%), transparent)';
  bgContainer.appendChild(fog2);

  // Particles — reduced count for performance
  const particleCount = 20;
  for (let i = 0; i < particleCount; i++) {
    const p = document.createElement('div');
    p.className = 'particle';

    const size = 2 + Math.random() * 4;
    const x = Math.random() * 100;
    const y = Math.random() * 100;
    const duration = 6 + Math.random() * 8;
    const delay = Math.random() * 5;
    const isJolly = Math.random() > 0.95;

    p.style.width = isJolly ? 'auto' : size + 'px';
    p.style.height = isJolly ? 'auto' : size + 'px';
    p.style.left = x + '%';
    p.style.top = y + '%';
    p.style.animationDuration = duration + 's';
    p.style.animationDelay = delay + 's';

    if (isJolly) {
      p.innerText = '\u2620';
      p.style.fontSize = '12px';
      p.style.color = 'rgba(255, 255, 255, 0.1)';
    } else {
      p.style.backgroundColor =
        Math.random() > 0.5 ? 'hsl(190,100%,50%)' : 'hsl(300,100%,50%)';
    }

    bgContainer.appendChild(p);
  }

  // ==================================================================
  // 2. HOST BADGE INJECTION
  // ==================================================================
  function injectHostBadges(root) {
    const walker = document.createTreeWalker(
      root,
      NodeFilter.SHOW_TEXT,
      null,
      false,
    );

    const nodesToReplace = [];
    while (walker.nextNode()) {
      const node = walker.currentNode;
      const text = node.textContent;
      const match = text.match(/@(z0r0|luffy)/i);
      if (match) {
        nodesToReplace.push({ node, text, host: match[1].toLowerCase() });
      }
    }

    for (const { node, text, host } of nodesToReplace) {
      const frag = document.createDocumentFragment();
      const parts = text.split(new RegExp('@' + host, 'i'));
      for (let i = 0; i < parts.length; i++) {
        frag.appendChild(document.createTextNode(parts[i]));
        if (i < parts.length - 1) {
          const badge = document.createElement('span');
          badge.className = 'host-badge host-badge--' + host;
          badge.textContent = '@' + host;
          frag.appendChild(badge);
        }
      }
      node.parentNode.replaceChild(frag, node);
    }
  }

  // ==================================================================
  // 3. SEARCH BAR LABELS  —  inject banner labels above each search bar
  // ==================================================================
  function injectSearchLabels() {
    // Homepage 1.13.1 renders search widgets as <div class="widget">
    // containing an <input> — find them by looking for input[type="text"]
    // inside a widget wrapper.
    const seen = new Set();

    document.querySelectorAll('.widget').forEach((container) => {
      if (seen.has(container)) return;
      if (container.querySelector('.search-banner-label')) return;

      const input = container.querySelector('input[type="text"], input[type="search"]');
      if (!input) return;

      // Try to get the search URL from the closest form action, or the input placeholder
      let labelText = '\u25C6 Search';
      let labelClass = 'search-banner-label';

      const form = input.closest('form');
      const action = form ? (form.getAttribute('action') || '') : '';
      const placeholder = (input.getAttribute('placeholder') || '').toLowerCase();

      if (action.includes('perplexity') || placeholder.includes('perplex')) {
        labelText = '\u25C6 Perplexity Search';
        labelClass += ' search-banner-label--perplexity';
      } else if (action.includes('searx') || action.includes('8888') || placeholder.includes('searx')) {
        labelText = '\u25C6 SearXNG Meta Search';
        labelClass += ' search-banner-label--searxng';
      }

      const label = document.createElement('div');
      label.className = labelClass;
      label.textContent = labelText;

      container.insertBefore(label, container.firstChild);
      seen.add(container);
    });
  }

  // ==================================================================
  // 4. STATUS DOT ENHANCEMENT  —  add glow and pulse to status dots
  // ==================================================================
  function enhanceStatusDots() {
    // Find all status dots (homepage uses various class patterns)
    const dots = document.querySelectorAll('[class*="dot"], .status-indicator, [class*="status"]');
    dots.forEach(dot => {
      // Skip if already processed
      if (dot.dataset.lovableEnhanced) return;
      dot.dataset.lovableEnhanced = 'true';

      // Check for green/up or red/down styling
      const style = window.getComputedStyle(dot);
      const bg = style.backgroundColor || '';

      if (bg.includes('rgb(16, 185, 129)') || bg.includes('emerald') || bg.includes('green')) {
        dot.style.animation = 'status-pulse-up 2s ease-in-out infinite';
        dot.style.boxShadow = '0 0 6px var(--status-up)';
      } else if (bg.includes('rgb(244, 63, 94)') || bg.includes('rose') || bg.includes('red')) {
        dot.style.animation = 'status-pulse-down 1.5s ease-in-out infinite';
        dot.style.boxShadow = '0 0 6px var(--status-down)';
      }
    });
  }

  // ==================================================================
  // 5. CARD STATUS BORDER  —  colored left border based on up/down
  // ==================================================================
  function enhanceCardStatus() {
    const cards = document.querySelectorAll('.service-card, .services-group .service');
    cards.forEach(card => {
      if (card.dataset.lovableCard) return;
      card.dataset.lovableCard = 'true';

      // Look for status indicators within the card
      const statusEl = card.querySelector('[class*="dot"], [class*="status"], .bg-emerald, .bg-rose');
      if (!statusEl) return;

      const style = window.getComputedStyle(statusEl);
      const bg = style.backgroundColor || '';

      if (bg.includes('rgb(16, 185, 129)') || bg.includes('emerald') || bg.includes('green')) {
        card.style.borderLeft = '3px solid var(--status-up)';
      } else if (bg.includes('rgb(244, 63, 94)') || bg.includes('rose') || bg.includes('red')) {
        card.style.borderLeft = '3px solid var(--status-down)';
        card.style.boxShadow = '0 0 12px hsla(0, 84%, 60%, 0.15)';
      }
    });
  }

  // ==================================================================
  // 6. GROUP HEADER ENHANCEMENT
  // ==================================================================
  function enhanceGroupHeaders() {
    const groups = document.querySelectorAll('.services-group');
    groups.forEach((group, idx) => {
      const header = group.querySelector('.group-title, h2');
      if (!header) return;
      if (header.dataset.lovableHeader) return;
      header.dataset.lovableHeader = 'true';

      header.style.borderLeft = '3px solid';
      header.style.paddingLeft = '0.75rem';
    });
  }

  // ==================================================================
  // RUN ALL ENHANCEMENTS  —  debounced for performance
  // ==================================================================
  let enhancementTimer = null;

  function runAllEnhancements() {
    injectHostBadges(document.body);
    injectSearchLabels();
    enhanceGroupHeaders();
    enhanceStatusDots();
    enhanceCardStatus();
  }

  // Run on initial load
  runAllEnhancements();

  // Watch for new cards added dynamically — debounced for performance
  const observer = new MutationObserver(() => {
    if (enhancementTimer) clearTimeout(enhancementTimer);
    enhancementTimer = setTimeout(runAllEnhancements, 100);
  });
  observer.observe(document.body, { childList: true, subtree: true });

  // ==================================================================
  // 7. FONT REDUNDANCY
  // ==================================================================
  const fontLink = document.createElement('link');
  fontLink.href =
    'https://fonts.googleapis.com/css2?family=Orbitron:wght@400;700&family=Space+Grotesk:wght@300;500&display=swap';
  fontLink.rel = 'stylesheet';
  document.head.appendChild(fontLink);

  console.log('Lovable Theme Effects Loaded.');
})();
