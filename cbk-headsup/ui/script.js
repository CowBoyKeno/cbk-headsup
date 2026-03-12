const resourceName = typeof GetParentResourceName === 'function'
    ? GetParentResourceName()
    : (window.location.hostname || 'cbk-headsup');

const bubbleLayer = document.getElementById('bubble-layer');
const inputRoot = document.getElementById('input-root');
const panel = document.getElementById('panel');
const panelHeader = document.getElementById('panelHeader');
const messageInput = document.getElementById('message');
const sendButton = document.getElementById('send');
const closeButton = document.getElementById('close');

let dragState = null;
let movedByUser = false;
const bubbleNodes = new Map();

function centerPanel() {
    panel.style.left = '50%';
    panel.style.top = '50%';
    panel.style.transform = 'translate(-50%, -50%)';
}

function clampToViewport(nextLeft, nextTop) {
    const rect = panel.getBoundingClientRect();
    const maxLeft = Math.max(12, window.innerWidth - rect.width - 12);
    const maxTop = Math.max(12, window.innerHeight - rect.height - 12);

    return {
        left: clamp(nextLeft, 12, maxLeft),
        top: clamp(nextTop, 12, maxTop)
    };
}

function postNui(eventName, data = {}) {
    fetch(`https://${resourceName}/${eventName}`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json; charset=UTF-8'
        },
        body: JSON.stringify(data)
    }).catch(() => {});
}

function setInputVisible(visible) {
    if (visible) {
        inputRoot.classList.remove('hidden');
        messageInput.value = '';
        if (!movedByUser) {
            centerPanel();
        }
        messageInput.focus();
    } else {
        inputRoot.classList.add('hidden');
        messageInput.value = '';
    }
}

function clamp(value, min, max) {
    return Math.max(min, Math.min(max, value));
}

function renderBubbles(bubbles) {
    const seen = new Set();

    for (let i = 0; i < bubbles.length; i++) {
        const b = bubbles[i];
        const id = String(b.id || i);
        seen.add(id);

        let el = bubbleNodes.get(id);
        if (!el) {
            el = document.createElement('div');
            el.className = 'bubble';
            bubbleNodes.set(id, el);
            bubbleLayer.appendChild(el);
        }

        el.style.left = `${clamp(b.x * 100, 0, 100)}%`;
        el.style.top = `${clamp(b.y * 100, 0, 100)}%`;
        el.style.opacity = `${clamp(Number(b.alpha) || 0, 0, 1)}`;
        el.textContent = b.text || '';
    }

    for (const [id, node] of bubbleNodes.entries()) {
        if (!seen.has(id)) {
            node.remove();
            bubbleNodes.delete(id);
        }
    }
}

window.addEventListener('message', (event) => {
    const data = event.data;
    if (!data || typeof data !== 'object') {
        return;
    }

    if (data.action === 'setInputVisible') {
        setInputVisible(!!data.visible)
        return;
    }

    if (data.action === 'renderBubbles') {
        renderBubbles(Array.isArray(data.bubbles) ? data.bubbles : []);
    }
});

function sendCurrentMessage() {
    const text = (messageInput.value || '').trim();
    postNui('send', { text });
}

panelHeader.addEventListener('mousedown', (event) => {
    if (event.button !== 0) {
        return;
    }

    const rect = panel.getBoundingClientRect();
    dragState = {
        offsetX: event.clientX - rect.left,
        offsetY: event.clientY - rect.top
    };

    panel.style.transform = 'none';
    panel.style.left = `${rect.left}px`;
    panel.style.top = `${rect.top}px`;

    movedByUser = true;
});

window.addEventListener('mousemove', (event) => {
    if (!dragState || inputRoot.classList.contains('hidden')) {
        return;
    }

    const next = clampToViewport(
        event.clientX - dragState.offsetX,
        event.clientY - dragState.offsetY
    );

    panel.style.left = `${next.left}px`;
    panel.style.top = `${next.top}px`;
});

window.addEventListener('mouseup', () => {
    dragState = null;
});

window.addEventListener('resize', () => {
    if (!movedByUser || inputRoot.classList.contains('hidden')) {
        return;
    }

    const rect = panel.getBoundingClientRect();
    const next = clampToViewport(rect.left, rect.top);
    panel.style.left = `${next.left}px`;
    panel.style.top = `${next.top}px`;
});

centerPanel();

sendButton.addEventListener('click', sendCurrentMessage);

closeButton.addEventListener('click', () => {
    postNui('close');
});

document.addEventListener('keydown', (event) => {
    if (inputRoot.classList.contains('hidden')) {
        return;
    }

    if (event.key === 'Escape') {
        event.preventDefault();
        postNui('close');
        return;
    }

    if (event.key === 'Enter' && !event.shiftKey) {
        event.preventDefault();
        sendCurrentMessage();
    }
});