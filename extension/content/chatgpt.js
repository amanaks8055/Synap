// ══════════════════════════════════════════
// content/chatgpt.js
// ══════════════════════════════════════════
(function () {
    let lastAssistant = 0;

    // Watch DOM for new assistant replies (most reliable)
    new MutationObserver(() => {
        const msgs = document.querySelectorAll('[data-message-author-role="assistant"]');
        if (msgs.length > lastAssistant) {
            lastAssistant = msgs.length;
            chrome.runtime.sendMessage({ action: 'usage', toolId: 'chatgpt_gpt4o', count: 1 });
        }
    }).observe(document.body, { childList: true, subtree: true });

    // Fallback: Enter key
    document.addEventListener('keydown', (e) => {
        if (e.key === 'Enter' && !e.shiftKey) {
            const inInput = document.activeElement?.closest('textarea,[contenteditable]');
            if (inInput) setTimeout(() =>
                chrome.runtime.sendMessage({ action: 'usage', toolId: 'chatgpt_gpt4o', count: 1 }), 1000);
        }
    }, true);

    console.log('[Synap] ChatGPT tracking ✓');
})();
