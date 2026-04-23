/* Homepage Dashboard Lovable Theme Background Effects */

(function() {
    console.log('Initializing Lovable Theme Effects...');

    // Create the background container
    const bgContainer = document.createElement('div');
    bgContainer.id = 'lovable-background';
    document.body.prepend(bgContainer);

    // 1. Holographic Grid
    const grid = document.createElement('div');
    grid.className = 'holographic-grid';
    bgContainer.appendChild(grid);

    // 2. Fog Layers
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

    // 3. Particles
    const particleCount = 40;
    for (let i = 0; i < particleCount; i++) {
        const p = document.createElement('div');
        p.className = 'particle';
        
        // Random properties
        const size = 2 + Math.random() * 4;
        const x = Math.random() * 100;
        const y = Math.random() * 100;
        const duration = 6 + Math.random() * 8;
        const delay = Math.random() * 5;
        const isJolly = Math.random() > 0.95; // Rare Easter egg
        
        p.style.width = isJolly ? 'auto' : `${size}px`;
        p.style.height = isJolly ? 'auto' : `${size}px`;
        p.style.left = `${x}%`;
        p.style.top = `${y}%`;
        p.style.animationDuration = `${duration}s`;
        p.style.animationDelay = `${delay}s`;
        
        if (isJolly) {
            p.innerText = '☠';
            p.style.fontSize = '12px';
            p.style.color = 'rgba(255, 255, 255, 0.1)';
        } else {
            p.style.backgroundColor = Math.random() > 0.5 
                ? 'hsl(190,100%,50%)' 
                : 'hsl(300,100%,50%)';
        }

        bgContainer.appendChild(p);
    }

    // 4. Inject fonts if not loaded by CSS import (redundancy)
    const fontLink = document.createElement('link');
    fontLink.href = 'https://fonts.googleapis.com/css2?family=Orbitron:wght@400;700&family=Space+Grotesk:wght@300;500&display=swap';
    fontLink.rel = 'stylesheet';
    document.head.appendChild(fontLink);

    console.log('Lovable Theme Effects Loaded.');
})();
