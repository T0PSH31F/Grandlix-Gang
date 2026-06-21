/* Homepage Dashboard Lovable Theme — Background + Host Badge Injection */

(function () {
  console.log('Initializing Lovable Theme Effects...');

  // ==================================================================
  // 1. BACKGROUND
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

  // Particles
  const particleCount = 40;
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
  // Walks all text nodes inside service descriptions and wraps @host tags
  // in <span class="host-badge host-badge--{host}"> so the CSS can style
  // them as neon pills.
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
      // Split on @host (case-insensitive)
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

  // Run on initial load and after any dynamic DOM mutation.
  injectHostBadges(document.body);

  // Watch for new cards added dynamically (Homepage lazy-loads groups).
  const observer = new MutationObserver(() => injectHostBadges(document.body));
  observer.observe(document.body, { childList: true, subtree: true });

  // ==================================================================
  // 3. FONT REDUNDANCY
  // ==================================================================
  const fontLink = document.createElement('link');
  fontLink.href =
    'https://fonts.googleapis.com/css2?family=Orbitron:wght@400;700&family=Space+Grotesk:wght@300;500&display=swap';
  fontLink.rel = 'stylesheet';
  document.head.appendChild(fontLink);

  console.log('Lovable Theme Effects Loaded.');
})();
