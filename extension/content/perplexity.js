// content/perplexity.js
(function () {
    document.addEventListener('click', (e) => {
        const btn = e.target.closest('button[aria-label="Submit"],button.bg-super');
        if (btn) setTimeout(() => chrome.runtime.sendMessage({ action: 'usage', toolId: 'perplexity', count: 1 }), 800);
    }, true);
    console.log('[Synap] Perplexity tracking ✓');
})();
