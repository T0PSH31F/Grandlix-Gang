/* Homepage Dashboard Lovable Theme — One Piece Crew Mascots + Background + Host Badges + Search Labels */

(function () {
  console.log('NFP Lovable Theme — Crew Mascots Initializing...');

  // ==================================================================
  // 0. CREW DATA
  // ==================================================================
  const crew = [
    { name: 'luffy',  group: 4, color: 'hsl(340,100%,50%)', img: '/images/luffy.png' },
    { name: 'zoro',   group: 2, color: 'hsl(110,100%,54%)', img: '/images/zoro.png' },
    { name: 'robin',  group: 0, color: 'hsl(190,100%,50%)', img: '/images/robin.png' },
    { name: 'vegapunk', group: 1, color: 'hsl(280,100%,50%)', img: '/images/vegapunk.png' },
    { name: 'franky', group: 2, color: 'hsl(220,100%,60%)', img: '/images/franky.png' },
    { name: 'nami',   group: 3, color: 'hsl(35,100%,50%)', img: '/images/nami.png' },
    { name: 'sanji',  group: 4, color: 'hsl(51,100%,50%)', img: '/images/sanji.png' },
    { name: 'usopp',  group: 5, color: 'hsl(110,100%,54%)', img: '/images/usopp.png' },
  ];

  // Group index → crew member
  const groupMascot = {
    0: crew.find(c => c.name === 'robin'),    // Observability
    1: crew.find(c => c.name === 'vegapunk'), // AI / Agents
    2: crew.find(c => c.name === 'franky'),   // Infrastructure
    3: crew.find(c => c.name === 'nami'),     // Communications
    4: crew.find(c => c.name === 'sanji'),    // Media
    5: crew.find(c => c.name === 'usopp'),    // Automation
  };

  // ==================================================================
  // 1. BACKGROUND — CSS gradient + holographic grid + character cameos
  // ==================================================================
  const bgContainer = document.createElement('div');
  bgContainer.id = 'lovable-background';
  document.body.prepend(bgContainer);

  // Holographic grid
  const grid = document.createElement('div');
  grid.className = 'holographic-grid';
  bgContainer.appendChild(grid);

  // Fog layers
  ['30%', '60%'].forEach((top, i) => {
    const fog = document.createElement('div');
    fog.className = 'fog-layer';
    fog.style.top = top;
    fog.style.height = i === 0 ? '200px' : '300px';
    fog.style.background = `radial-gradient(ellipse at center, ${i === 0 ? 'hsl(190,100%,50%)' : 'hsl(280,100%,50%)'}, transparent)`;
    bgContainer.appendChild(fog);
  });

  // Crew cameo images — float in background at very low opacity
  crew.forEach((mate, i) => {
    const cameo = document.createElement('img');
    cameo.src = mate.img;
    cameo.className = 'crew-cameo';
    cameo.style.cssText = `
      position: absolute;
      width: ${60 + Math.random() * 40}px;
      height: auto;
      opacity: 0.06;
      left: ${5 + (i * 13) % 85}%;
      top: ${10 + (i * 17) % 75}%;
      filter: drop-shadow(0 0 20px ${mate.color});
      animation: float ${8 + Math.random() * 6}s ease-in-out infinite;
      animation-delay: ${Math.random() * 4}s;
      pointer-events: none;
      z-index: 0;
    `;
    bgContainer.appendChild(cameo);
  });

  // Particles with jolly roger
  for (let i = 0; i < 15; i++) {
    const p = document.createElement('div');
    p.className = 'particle';
    p.style.cssText = `
      width: ${2 + Math.random() * 3}px;
      height: ${2 + Math.random() * 3}px;
      left: ${Math.random() * 100}%;
      top: ${Math.random() * 100}%;
      animation-duration: ${6 + Math.random() * 8}s;
      animation-delay: ${Math.random() * 5}s;
      background: ${Math.random() > 0.5 ? 'hsl(190,100%,50%)' : 'hsl(300,100%,50%)'};
    `;
    bgContainer.appendChild(p);
  }

  // ==================================================================
  // 2. HOST BADGE INJECTION
  // ==================================================================
  function injectHostBadges(root) {
    const walker = document.createTreeWalker(root, NodeFilter.SHOW_TEXT, null, false);
    const nodesToReplace = [];
    while (walker.nextNode()) {
      const node = walker.currentNode;
      const match = node.textContent.match(/@(z0r0|luffy)/i);
      if (match) nodesToReplace.push({ node, text: node.textContent, host: match[1].toLowerCase() });
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
  // 3. CREW MASCOT INJECTION — add character icons to group headers
  // ==================================================================
  function injectCrewMascots() {
    const groups = document.querySelectorAll('.services-group');
    groups.forEach((group, idx) => {
      if (group.querySelector('.crew-mascot')) return;
      const mate = groupMascot[idx];
      if (!mate) return;

      const header = group.querySelector('.group-title, h2');
      if (!header) return;

      const mascot = document.createElement('img');
      mascot.src = mate.img;
      mascot.className = 'crew-mascot';
      mascot.style.cssText = `
        width: 32px;
        height: 32px;
        margin-right: 8px;
        vertical-align: middle;
        filter: drop-shadow(0 0 6px ${mate.color});
        image-rendering: auto;
      `;
      header.prepend(mascot);
    });
  }

  // ==================================================================
  // 4. SEARCH BAR LABELS
  // ==================================================================
  function injectSearchLabels() {
    const seen = new Set();
    document.querySelectorAll('.widget').forEach(container => {
      if (seen.has(container) || container.querySelector('.search-banner-label')) return;
      const input = container.querySelector('input[type="text"], input[type="search"]');
      if (!input) return;

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
  // 5. STATUS DOT ENHANCEMENT
  // ==================================================================
  function enhanceStatusDots() {
    document.querySelectorAll('[class*="dot"], .status-indicator, [class*="status"]').forEach(dot => {
      if (dot.dataset.lovableEnhanced) return;
      dot.dataset.lovableEnhanced = 'true';
      const bg = window.getComputedStyle(dot).backgroundColor || '';
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
  // 6. CARD STATUS BORDER
  // ==================================================================
  function enhanceCardStatus() {
    document.querySelectorAll('.service-card, .services-group .service').forEach(card => {
      if (card.dataset.lovableCard) return;
      card.dataset.lovableCard = 'true';
      const statusEl = card.querySelector('[class*="dot"], [class*="status"], .bg-emerald, .bg-rose');
      if (!statusEl) return;
      const bg = window.getComputedStyle(statusEl).backgroundColor || '';
      if (bg.includes('rgb(16, 185, 129)') || bg.includes('emerald') || bg.includes('green')) {
        card.style.borderLeft = '3px solid var(--status-up)';
      } else if (bg.includes('rgb(244, 63, 94)') || bg.includes('rose') || bg.includes('red')) {
        card.style.borderLeft = '3px solid var(--status-down)';
        card.style.boxShadow = '0 0 12px hsla(0, 84%, 60%, 0.15)';
      }
    });
  }

  // ==================================================================
  // 7. GROUP HEADER ENHANCEMENT
  // ==================================================================
  function enhanceGroupHeaders() {
    document.querySelectorAll('.services-group').forEach((group, idx) => {
      const header = group.querySelector('.group-title, h2');
      if (!header || header.dataset.lovableHeader) return;
      header.dataset.lovableHeader = 'true';
      header.style.borderLeft = '3px solid';
      header.style.paddingLeft = '0.75rem';
    });
  }

  // ==================================================================
  // RUN ALL + OBSERVER
  // ==================================================================
  let timer = null;
  function runAll() {
    injectHostBadges(document.body);
    injectCrewMascots();
    injectSearchLabels();
    enhanceGroupHeaders();
    enhanceStatusDots();
    enhanceCardStatus();
  }

  runAll();
  new MutationObserver(() => {
    if (timer) clearTimeout(timer);
    timer = setTimeout(runAll, 100);
  }).observe(document.body, { childList: true, subtree: true });

  // Font redundancy
  const fl = document.createElement('link');
  fl.href = 'https://fonts.googleapis.com/css2?family=Orbitron:wght@400;700&family=Space+Grotesk:wght@300;500&display=swap';
  fl.rel = 'stylesheet';
  document.head.appendChild(fl);

  console.log('NFP Crew Mascots Loaded.');
})();
