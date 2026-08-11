import { signal, effect } from "https://esm.sh/@preact/signals-core@1.12.1";
import { debounce, isNotNil } from "https://esm.sh/es-toolkit@1.44.0?standalone&exports=debounce,isNotNil";

document.addEventListener("DOMContentLoaded", () => {
    document.querySelectorAll(".slip > svg").forEach((svg) => {
        svg.style.width = "100%";
        svg.style.height = "auto";
    });
});

const currentSlip = signal(0);
document.addEventListener("DOMContentLoaded", () => {
    const savedSlip = sessionStorage.getItem("slipst-current-slip");
    if (savedSlip != null) {
        currentSlip.value = parseInt(savedSlip, 10);
    }
    document.documentElement.style.setProperty("--transition-time", "0s");
    setTimeout(() => {
        document.documentElement.style.setProperty("--transition-time", "0.5s");
    }, 1);
    effect(() => {
        if (currentSlip.value > 0) {
            sessionStorage.setItem("slipst-current-slip", currentSlip.value.toString());
        }
    });
});

document.addEventListener("DOMContentLoaded", () => {
    document.getElementById("container").addEventListener("click", () => currentSlip.value += 1);
    document.getElementById("container").addEventListener("wheel", debounce((event) => {
        if (event.deltaY > 0) {
            currentSlip.value += 1;
        } else if (event.deltaY < 0) {
            currentSlip.value -= 1;
        }
    }, 50, { edges: ['leading'] }));
    document.addEventListener("keydown", (event) => {
        if (["ArrowRight", "ArrowDown", "PageDown", " ", "Enter"].includes(event.key)) {
            currentSlip.value += 1;
        } else if (["ArrowLeft", "ArrowUp", "PageUp", "Backspace"].includes(event.key)) {
            currentSlip.value -= 1;
        }
    });
});

document.addEventListener("DOMContentLoaded", () => {
    const maxSlip = Array.from(document.querySelectorAll(".slip")).map((slip) => {
        return parseInt(slip.getAttribute("data-slip"), 10);
    }).reduce((a, b) => Math.max(a, b), 0);

    effect(() => {
        if (currentSlip.value <= 0) {
            currentSlip.value = 1;
        } else if (currentSlip.value > maxSlip) {
            currentSlip.value = maxSlip;
        }
    });
});

effect(() => {
    document.querySelectorAll(".slip").forEach((slip) => {
        const slipIndex = parseInt(slip.getAttribute("data-slip"), 10);
        if (slipIndex <= currentSlip.value) {
            slip.style.opacity = 1;
        } else {
            slip.style.opacity = 0;
        }
    });
});

const layoutEffect = () => {
    let up = document.querySelector(`[data-slip="${currentSlip.value}"]`)?.getAttribute("data-slip-up");
    for (let i = currentSlip.value - 1; i > 0; i--) {
        if (isNotNil(up)) break;
        up = document.querySelector(`[data-slip="${i}"]`)?.getAttribute("data-slip-up");
    }
    if (isNotNil(up)) {
        const anchor = document.querySelector(`[data-slip="${up}"]`);
        document.getElementById("container").style.top = `${-anchor.offsetTop}px`;
    } else {
        document.getElementById("container").style.top = 0;
    }
};
effect(layoutEffect);
document.defaultView.addEventListener("resize", () => {
    document.documentElement.style.setProperty("--transition-time", "0s");
    layoutEffect();
    setTimeout(() => {
        document.documentElement.style.setProperty("--transition-time", "0.5s");
    }, 1);
});