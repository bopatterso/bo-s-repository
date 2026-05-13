const store = {
  get(key, fallback) {
    try {
      const value = localStorage.getItem(key);
      return value ? JSON.parse(value) : fallback;
    } catch {
      return fallback;
    }
  },
  set(key, value) {
    localStorage.setItem(key, JSON.stringify(value));
  }
};

const timers = {
  wbtb: null,
  ssild: null,
  training: null,
  trainingPrompt: null,
  tlr: null,
  reality: null
};

let audioContext;
let uploadedCueDataUrl = store.get("lucid_uploaded_cue", null);

function $(selector) {
  return document.querySelector(selector);
}

function openModal(title, message) {
  const modal = $("#modal");
  if (!modal) {
    alert(`${title}\n\n${message}`);
    return;
  }
  $("#modal-title").textContent = title;
  $("#modal-message").textContent = message;
  modal.classList.remove("hidden");
}

function closeModal() {
  $("#modal")?.classList.add("hidden");
}

function ensureAudioContext() {
  audioContext ||= new (window.AudioContext || window.webkitAudioContext)();
  if (audioContext.state === "suspended") audioContext.resume();
  return audioContext;
}

function speak(text) {
  if (!("speechSynthesis" in window)) return;
  speechSynthesis.cancel();
  const utterance = new SpeechSynthesisUtterance(text);
  utterance.rate = 0.86;
  utterance.pitch = 0.95;
  speechSynthesis.speak(utterance);
}

function playGeneratedCue(type, volume = 0.2, rampSeconds = 1.5) {
  const ctx = ensureAudioContext();
  const now = ctx.currentTime;
  const master = ctx.createGain();
  master.gain.setValueAtTime(0.001, now);
  master.gain.exponentialRampToValueAtTime(Math.max(0.001, volume), now + rampSeconds);
  master.gain.exponentialRampToValueAtTime(0.001, now + rampSeconds + 2.4);
  master.connect(ctx.destination);

  const makeOsc = (frequency, start, duration, wave = "sine") => {
    const osc = ctx.createOscillator();
    const gain = ctx.createGain();
    osc.type = wave;
    osc.frequency.value = frequency;
    gain.gain.setValueAtTime(0.001, now + start);
    gain.gain.exponentialRampToValueAtTime(1, now + start + 0.05);
    gain.gain.exponentialRampToValueAtTime(0.001, now + start + duration);
    osc.connect(gain).connect(master);
    osc.start(now + start);
    osc.stop(now + start + duration + 0.05);
  };

  if (type === "beep-pair") {
    makeOsc(660, 0, 0.35);
    makeOsc(660, 0.7, 0.35);
  } else if (type === "low-chime") {
    makeOsc(392, 0, 1.4, "triangle");
    makeOsc(588, 0.08, 1.1, "sine");
  } else {
    makeOsc(528, 0, 1.5);
  }
}

function playUploadedCue(volume = 0.2) {
  if (!uploadedCueDataUrl) return false;
  const audio = new Audio(uploadedCueDataUrl);
  audio.volume = volume;
  audio.play();
  return true;
}

function playCue({ volume = 0.2, rampSeconds = 1.5 } = {}) {
  const settings = store.get("lucid_tlr_settings", { cue: "sine-528" });
  if (settings.cue === "uploaded" && playUploadedCue(volume)) return;
  playGeneratedCue(settings.cue || "sine-528", volume, rampSeconds);
}

function scheduleTimeout(callback, delayMs) {
  const maxDelay = 2_147_483_647;
  if (delayMs <= maxDelay) return setTimeout(callback, delayMs);
  return setTimeout(() => scheduleTimeout(callback, delayMs - maxDelay), maxDelay);
}

function initJournal() {
  const form = $("#journal-form");
  if (!form) return;
  const dateInput = $("#dream-date");
  dateInput.valueAsDate = new Date();

  const render = () => {
    const entries = store.get("lucid_journal_entries", []);
    const list = $("#journal-list");
    const count = $("#entry-count");
    count.textContent = `${entries.length} ${entries.length === 1 ? "entry" : "entries"}`;
    list.innerHTML = "";

    if (!entries.length) {
      list.innerHTML = `<p class="note">No entries yet. Add your first dream above.</p>`;
      return;
    }

    entries
      .sort((a, b) => b.date.localeCompare(a.date) || b.createdAt - a.createdAt)
      .forEach((entry) => {
        const article = document.createElement("article");
        article.className = "entry-card";
        article.innerHTML = `
          <header>
            <time datetime="${entry.date}">${new Date(`${entry.date}T00:00:00`).toLocaleDateString(undefined, { dateStyle: "long" })}</time>
            <button class="button ghost" type="button" data-delete="${entry.id}">Delete</button>
          </header>
          <p></p>`;
        article.querySelector("p").textContent = entry.text;
        list.append(article);
      });
  };

  form.addEventListener("submit", (event) => {
    event.preventDefault();
    const text = $("#dream-text").value.trim();
    const date = dateInput.value;
    if (!text || !date) return;
    const entries = store.get("lucid_journal_entries", []);
    entries.push({ id: crypto.randomUUID(), date, text, createdAt: Date.now() });
    store.set("lucid_journal_entries", entries);
    form.reset();
    dateInput.valueAsDate = new Date();
    render();
  });

  $("#journal-list").addEventListener("click", (event) => {
    const id = event.target.closest("[data-delete]")?.dataset.delete;
    if (!id) return;
    const entries = store.get("lucid_journal_entries", []).filter((entry) => entry.id !== id);
    store.set("lucid_journal_entries", entries);
    render();
  });

  render();
}

function initAlarm() {
  if (document.body.dataset.page !== "alarm") return;
  $("#modal-close")?.addEventListener("click", closeModal);

  const settings = store.get("lucid_tlr_settings", { cue: "sine-528", volume: 20, delay: 6, realityInterval: 60, realityEnabled: false });
  $("#cue-select").value = settings.cue === "uploaded" ? "sine-528" : settings.cue;
  $("#cue-volume").value = settings.volume;
  $("#cue-delay").value = settings.delay;
  $("#reality-interval").value = settings.realityInterval || 60;
  $("#reality-toggle").checked = !!settings.realityEnabled;

  const updateLabels = () => {
    $("#volume-value").textContent = `${$("#cue-volume").value}%`;
    $("#delay-value").textContent = `${$("#cue-delay").value} hours`;
    $("#reality-interval-value").textContent = `${$("#reality-interval").value} minutes`;
  };
  updateLabels();
  ["#cue-volume", "#cue-delay", "#reality-interval"].forEach((id) => $(id).addEventListener("input", updateLabels));

  $("#wbtb-form").addEventListener("submit", (event) => {
    event.preventDefault();
    clearTimeout(timers.wbtb);
    const [hours, minutes] = $("#bedtime").value.split(":").map(Number);
    const delayHours = Math.max(5, Number($("#wbtb-hours").value));
    $("#wbtb-hours").value = delayHours;
    const bedtime = new Date();
    bedtime.setHours(hours, minutes, 0, 0);
    if (bedtime < new Date()) bedtime.setDate(bedtime.getDate() + 1);
    const alarmAt = new Date(bedtime.getTime() + delayHours * 60 * 60 * 1000);
    const delayMs = Math.max(0, alarmAt.getTime() - Date.now());
    timers.wbtb = scheduleTimeout(() => {
      playCue({ volume: 0.28, rampSeconds: 0.8 });
      openModal("Wake Back to Bed", "Stay awake for 30–120 minutes. Keep lights low, recall your last dream, practice MILD or SSILD, then return to sleep with a clear intention to notice the next dream.");
      $("#wbtb-status").textContent = "WBTB alarm fired. Practice gently, then return to sleep.";
    }, delayMs);
    $("#wbtb-status").textContent = `WBTB scheduled for ${alarmAt.toLocaleString()} (${delayHours} hours after bedtime).`;
  });

  $("#cancel-wbtb").addEventListener("click", () => {
    clearTimeout(timers.wbtb);
    $("#wbtb-status").textContent = "WBTB timer canceled.";
  });

  $("#mild-form").addEventListener("submit", (event) => {
    event.preventDefault();
    const dream = $("#mild-dream").value.trim() || "your last dream";
    const phrase = $("#mild-phrase").value.trim();
    $("#mild-output").textContent = `Close your eyes and picture ${dream}. Imagine noticing an odd detail, becoming lucid, and calmly repeating: “${phrase}.” Repeat for 2–5 minutes before sleep.`;
    speak(`${phrase}. Imagine becoming aware inside the dream. ${phrase}.`);
  });

  const ssildSteps = [
    ["Vision", "Notice darkness, colors, shapes, and visual noise behind closed eyes without straining."],
    ["Hearing", "Notice near and far sounds, then internal sounds, while staying relaxed."],
    ["Body", "Notice touch, weight, temperature, breath, and subtle sensations throughout the body."]
  ];
  $("#start-ssild").addEventListener("click", () => {
    clearInterval(timers.ssild);
    let index = 0;
    const showStep = () => {
      const [name, text] = ssildSteps[index % ssildSteps.length];
      $("#ssild-step").textContent = name;
      $("#ssild-instructions").textContent = text;
      speak(`${name}. ${text}`);
      playGeneratedCue("low-chime", 0.08, 0.3);
      index += 1;
    };
    showStep();
    timers.ssild = setInterval(showStep, 30000);
  });
  $("#stop-ssild").addEventListener("click", () => {
    clearInterval(timers.ssild);
    window.speechSynthesis?.cancel();
    $("#ssild-step").textContent = "Stopped";
  });

  $("#cue-upload").addEventListener("change", (event) => {
    const file = event.target.files?.[0];
    if (!file) return;
    const reader = new FileReader();
    reader.onload = () => {
      uploadedCueDataUrl = reader.result;
      store.set("lucid_uploaded_cue", uploadedCueDataUrl);
      store.set("lucid_tlr_settings", { ...getTlrSettings(), cue: "uploaded" });
      $("#tlr-status").textContent = `Uploaded cue saved: ${file.name}`;
    };
    reader.readAsDataURL(file);
  });

  function getTlrSettings() {
    return {
      cue: uploadedCueDataUrl && store.get("lucid_tlr_settings", {}).cue === "uploaded" ? "uploaded" : $("#cue-select").value,
      volume: Number($("#cue-volume").value),
      delay: Number($("#cue-delay").value),
      realityInterval: Number($("#reality-interval").value),
      realityEnabled: $("#reality-toggle").checked
    };
  }

  $("#save-cue").addEventListener("click", () => {
    store.set("lucid_tlr_settings", getTlrSettings());
    $("#tlr-status").textContent = "Cue volume, timing, and sound settings saved locally.";
  });

  $("#test-cue").addEventListener("click", () => {
    store.set("lucid_tlr_settings", getTlrSettings());
    playCue({ volume: Number($("#cue-volume").value) / 100, rampSeconds: 1.2 });
    $("#tlr-status").textContent = "Test cue played. Lower the volume if it feels startling.";
  });

  $("#start-training").addEventListener("click", () => {
    clearInterval(timers.training);
    clearInterval(timers.trainingPrompt);
    store.set("lucid_tlr_settings", getTlrSettings());
    const endAt = Date.now() + 20 * 60 * 1000;
    const trainingTick = () => {
      playCue({ volume: Number($("#cue-volume").value) / 100, rampSeconds: 0.8 });
      $("#training-prompt").textContent = "Cue played. Pause and adopt a lucid mindset: this could be a dream; look for dream signs; remember your intention.";
      if (Date.now() >= endAt) {
        clearInterval(timers.training);
        clearInterval(timers.trainingPrompt);
        $("#training-prompt").textContent = "Training complete. The cue is saved for later sleep playback.";
      }
    };
    trainingTick();
    timers.training = setInterval(trainingTick, 2 * 60 * 1000);
    timers.trainingPrompt = setInterval(() => {
      const remaining = Math.max(0, Math.ceil((endAt - Date.now()) / 60000));
      $("#training-prompt").textContent = `${remaining} minutes left. When the cue plays, rehearse: “I recognize when I am dreaming.”`;
    }, 30000);
  });

  $("#stop-training").addEventListener("click", () => {
    clearInterval(timers.training);
    clearInterval(timers.trainingPrompt);
    $("#training-prompt").textContent = "Training stopped.";
  });

  $("#schedule-tlr").addEventListener("click", () => {
    clearTimeout(timers.tlr);
    store.set("lucid_tlr_settings", getTlrSettings());
    const delayMs = Number($("#cue-delay").value) * 60 * 60 * 1000;
    const firstCue = new Date(Date.now() + delayMs);
    timers.tlr = scheduleTimeout(() => {
      let plays = 0;
      const playSeries = () => {
        const targetVolume = Number($("#cue-volume").value) / 100;
        playCue({ volume: targetVolume, rampSeconds: 8 });
        plays += 1;
        $("#tlr-status").textContent = `Sleep cue ${plays} played with a gradual volume ramp.`;
        if (plays < 6) timers.tlr = setTimeout(playSeries, 20 * 60 * 1000);
      };
      playSeries();
    }, delayMs);
    $("#tlr-status").textContent = `TLR cues scheduled to begin around ${firstCue.toLocaleString()} and repeat intermittently.`;
  });

  $("#cancel-tlr").addEventListener("click", () => {
    clearTimeout(timers.tlr);
    $("#tlr-status").textContent = "TLR sleep cues canceled.";
  });

  const configureRealityChecks = () => {
    clearInterval(timers.reality);
    store.set("lucid_tlr_settings", getTlrSettings());
    if (!$("#reality-toggle").checked) {
      $("#reality-status").textContent = "Reality-check reminders are off.";
      return;
    }
    const minutes = Number($("#reality-interval").value);
    $("#reality-status").textContent = `Reality-check prompts enabled every ${minutes} minutes while this page stays open.`;
    timers.reality = setInterval(() => {
      openModal("Am I dreaming?", "Pause. Read text twice, look at your hands, notice gravity and light, and ask whether anything is dreamlike.");
    }, minutes * 60 * 1000);
  };
  $("#reality-toggle").addEventListener("change", configureRealityChecks);
  $("#reality-interval").addEventListener("change", configureRealityChecks);
  configureRealityChecks();
}

document.addEventListener("DOMContentLoaded", () => {
  initJournal();
  initAlarm();
});
