function setDemoTime() {
  const node = document.querySelector("[data-time]");
  if (!node) return;
  node.textContent = new Date().toLocaleTimeString([], {
    hour: "2-digit",
    minute: "2-digit"
  });
}

function wireTaskButtons() {
  document.querySelectorAll("[data-task-action]").forEach((button) => {
    button.addEventListener("click", () => {
      const task = button.closest(".task");
      if (!task) return;
      task.classList.remove("done", "skipped");
      const action = button.dataset.taskAction;
      if (action === "done") {
        task.classList.add("done");
        task.querySelector("[data-status]").textContent = "Done";
      }
      if (action === "snooze") {
        task.querySelector("[data-status]").textContent = "Snoozed 15 min";
      }
      if (action === "skip") {
        task.classList.add("skipped");
        task.querySelector("[data-status]").textContent = "Rescheduled";
      }
      updateScore();
    });
  });
}

function updateScore() {
  const score = document.querySelector("[data-score]");
  if (!score) return;
  const tasks = Array.from(document.querySelectorAll(".task"));
  const done = tasks.filter((task) => task.classList.contains("done")).length;
  const value = Math.round((done / Math.max(tasks.length, 1)) * 100);
  score.textContent = `${value}%`;
}

function wireTabs() {
  document.querySelectorAll("[data-tab]").forEach((tab) => {
    tab.addEventListener("click", () => {
      const target = tab.dataset.tab;
      document.querySelectorAll("[data-tab]").forEach((item) => {
        item.classList.toggle("active", item === tab);
      });
      document.querySelectorAll("[data-panel]").forEach((panel) => {
        panel.classList.toggle("active", panel.dataset.panel === target);
      });
    });
  });
}

function wireCoachActions() {
  document.querySelectorAll("[data-coach-action]").forEach((button) => {
    button.addEventListener("click", () => {
      const status = document.querySelector("[data-coach-status]");
      if (!status) return;
      status.textContent = button.dataset.coachAction;
    });
  });
}

const onboardingSteps = [
  {
    nextQuestion: "What is your monthly goal that supports this yearly goal?",
    nextAnswer: "This month I want to complete the demo, build the Flutter screens, exercise 20 days, and study daily.",
    tag: "Annual goal captured"
  },
  {
    nextQuestion: "What should your ideal daily goal look like?",
    nextAnswer: "Wake up early, exercise, work on the app for 2 focused hours, study, and review my day at night.",
    tag: "Monthly goal captured"
  },
  {
    nextQuestion: "What time should I wake you up and when should I start your first task?",
    nextAnswer: "Wake me at 6:15 AM and start my first planning task at 7:00 AM.",
    tag: "Daily goal captured"
  },
  {
    nextQuestion: "Where do you usually lag or procrastinate?",
    nextAnswer: "After lunch I start scrolling, and at night I delay important work until it becomes too late.",
    tag: "Alarm preference captured"
  },
  {
    nextQuestion: "When a popup appears, what responses should it let you give?",
    nextAnswer: "Done, not done, snooze, reschedule, and add why I am stuck.",
    tag: "Lag pattern captured"
  },
  {
    nextQuestion: "What should I add automatically if you are falling behind?",
    nextAnswer: "Add smaller tasks, extra reminders, recovery breaks, and move hard work to the morning.",
    tag: "Popup responses captured"
  },
  {
    nextQuestion: "Perfect. I will create a full-day plan with alarms, task popups, lag tracking, and reports.",
    nextAnswer: "",
    tag: "Auto-adjust rules captured",
    complete: true
  },
];

function appendBubble(log, type, text) {
  const bubble = document.createElement("div");
  bubble.className = `bubble ${type}`;
  bubble.textContent = text;
  log.appendChild(bubble);
  log.scrollTop = log.scrollHeight;
  return bubble;
}

function appendTyping(log) {
  const bubble = document.createElement("div");
  bubble.className = "bubble ai";
  bubble.innerHTML = '<span class="typing"><i></i><i></i><i></i></span>';
  log.appendChild(bubble);
  log.scrollTop = log.scrollHeight;
  return bubble;
}

function wireOnboardingChat() {
  const log = document.querySelector("[data-chat-log]");
  const input = document.querySelector("[data-chat-input]");
  const send = document.querySelector("[data-chat-send]");
  const tags = document.querySelector("[data-captured-tags]");
  const progress = document.querySelector("[data-chat-progress]");
  const count = document.querySelector("[data-chat-count]");
  if (!log || !input || !send || !tags || !progress || !count) return;

  let stepIndex = 0;
  const totalSteps = onboardingSteps.length + 1;

  const sendCurrentAnswer = () => {
    const value = input.value.trim();
    if (!value) return;
    appendBubble(log, "user", value);

    const step = onboardingSteps[stepIndex];
    tags.innerHTML += `<span class="tag ${stepIndex % 2 ? "blue" : ""}">${step.tag}</span>`;
    stepIndex += 1;
    const progressValue = Math.min(100, Math.round(((stepIndex + 1) / totalSteps) * 100));
    progress.style.width = `${progressValue}%`;
    count.textContent = `${Math.min(stepIndex + 1, totalSteps)} / ${totalSteps}`;

    input.value = step.nextAnswer;
    send.disabled = true;
    const typing = appendTyping(log);
    window.setTimeout(() => {
      typing.remove();
      appendBubble(log, "ai", step.nextQuestion);
      send.disabled = false;

      if (step.complete) {
        input.value = "Ready to see my profile";
        send.outerHTML = '<a class="icon-btn" href="profile-summary.html" aria-label="Open summary"><svg viewBox="0 0 24 24" width="20" height="20" fill="none" stroke="currentColor" stroke-width="2"><path d="M5 12h14"/><path d="m12 5 7 7-7 7"/></svg></a>';
      }
    }, 520);
  };

  send.addEventListener("click", sendCurrentAnswer);
  input.addEventListener("keydown", (event) => {
    if (event.key === "Enter") sendCurrentAnswer();
  });
}

document.addEventListener("DOMContentLoaded", () => {
  setDemoTime();
  wireTaskButtons();
  wireTabs();
  wireCoachActions();
  wireOnboardingChat();
});
