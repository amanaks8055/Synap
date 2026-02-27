// content/gemini.js
(function () {
    document.addEventListener('click', (e) => {
        const btn = e.target.closest('button.send-button,button[aria-label*="Send"]');
        if (btn) setTimeout(() => chrome.runtime.sendMessage({ action: 'usage', toolId: 'gemini', count: 1 }), 800);
    }, true);
    document.addEventListener('keydown', (e) => {
        if (e.key === 'Enter' && !e.shiftKey && e.target.closest('rich-textarea,[contenteditable]'))
            setTimeout(() => chrome.runtime.sendMessage({ action: 'usage', toolId: 'gemini', count: 1 }), 800);
    }, true);
    console.log('[Synap] Gemini tracking ✓');
})();
