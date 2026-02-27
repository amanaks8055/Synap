// content/claude.js
(function () {
    let lastHuman = 0;
    new MutationObserver(() => {
        const msgs = document.querySelectorAll('[data-testid="user-message"],.human-turn');
        if (msgs.length > lastHuman) {
            lastHuman = msgs.length;
            chrome.runtime.sendMessage({ action: 'usage', toolId: 'claude', count: 1 });
        }
    }).observe(document.body, { childList: true, subtree: true });

    document.addEventListener('keydown', (e) => {
        if (e.key === 'Enter' && !e.shiftKey) {
            const inInput = e.target.closest('[contenteditable="true"]');
            if (inInput) setTimeout(() =>
                chrome.runtime.sendMessage({ action: 'usage', toolId: 'claude', count: 1 }), 1000);
        }
    }, true);
    console.log('[Synap] Claude tracking ✓');
})();
