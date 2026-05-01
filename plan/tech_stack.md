# AI Productivity Coach - Tech Stack Plan

## Summary

The app will be built with Flutter as the frontend and a backend stack that supports login, AI goal conversation, automated day planning, alarms, task popups, lag tracking, and daily/monthly/annual reports.

The first production target is Android. The app should work offline for daily planning and reminders, then sync to the cloud when internet is available.

## Recommended Tech Stack

### Frontend

Use **Flutter** for the full app UI:

- Login and signup
- AI onboarding chat
- Goal dashboard
- Automated daily planner
- Task completion popup
- Reports
- Settings

Suggested app structure:

```text
lib/
  app/
    router.dart
    theme.dart
  core/
    ai/
    database/
    models/
    notifications/
    services/
    sync/
  features/
    auth/
    onboarding_chat/
    goals/
    planner/
    reports/
    settings/
```

### Backend

Use **Supabase** for backend services:

- Authentication
- Postgres database
- User profile storage
- Goal and plan sync
- Report history
- Edge Functions for secure server-side logic

Why Supabase:

- The app data is relational: users, goals, plans, tasks, habits, check-ins, reports.
- Postgres is a strong fit for this.
- Supabase Auth works well with Flutter.
- Row Level Security can keep each user's data private.

### Local Database

Use **Drift SQLite** for offline-first local storage:

- Store daily plans locally
- Store task completion status
- Store check-ins and lag reasons
- Store reports before cloud sync
- Keep dashboard reactive and fast

The app should not depend on internet for daily alarms, task popups, or progress tracking.

### AI Layer

Use **Firebase AI Logic with Gemini** for AI features:

- AI onboarding conversation
- Extracting yearly, monthly, and daily goals
- Generating structured plans
- Creating daily/monthly/annual summaries
- Suggesting improvements when the user is lagging

The AI should return structured JSON, not only plain text, so the app can safely create goals, tasks, alarms, and reports.

Example AI output shape:

```json
{
  "annualGoals": [],
  "monthlyMilestones": [],
  "dailyHabits": [],
  "focusWindows": [],
  "riskWindows": [],
  "tomorrowPlan": [],
  "recommendedAlarms": []
}
```

### Notifications And Alarms

Use **flutter_local_notifications** for:

- Scheduled reminders
- Morning alarm-style notifications
- Task start notifications
- Task completion prompts
- Notification actions such as Done, Snooze, Not Done

Use **workmanager** for:

- Background sync
- Daily plan generation jobs
- Report generation jobs
- Periodic cleanup or retry logic

Use **android_alarm_manager_plus** only where exact Android alarm timing is required:

- Morning wake alarm
- Critical scheduled reminders

Do not start with Android floating window overlays. Start with notifications and in-app popups first. Floating overlay can be added later because it requires sensitive Android permissions and may create user trust or Play Store issues.

### Email Notifications

Use backend-driven email notifications for important summaries and account-related messages.

Recommended approach:

- Store the user's email through Supabase Auth.
- Store email preferences in the user profile table.
- Use Supabase Edge Functions to send emails.
- Use an email provider such as Resend, SendGrid, Mailgun, or Amazon SES.
- Trigger emails from backend jobs, not directly from the Flutter app.

Email use cases:

- Welcome email after signup
- Daily productivity summary
- Monthly report summary
- Annual progress report
- Missed-goal recovery message
- Important account/security messages

Suggested email flow:

```text
Flutter app
  -> saves user preferences in Supabase
  -> report or reminder event is created

Supabase database / scheduled job
  -> invokes Edge Function
  -> Edge Function calls email provider
  -> provider sends email to registered user
```

Email preferences should include:

```text
daily_summary_email: true/false
monthly_report_email: true/false
annual_report_email: true/false
missed_goal_email: true/false
marketing_email: true/false
```

Do not send AI-generated emails directly without storing the generated report first. The safer flow is:

1. Generate report.
2. Store report in database.
3. Create email summary from stored report.
4. Send through Edge Function.
5. Log email delivery status.

## End-To-End App Flow

1. **Login / Signup**
   - User creates an account or logs in with Supabase Auth.

2. **AI Goal Conversation**
   - User tells the app yearly, monthly, and daily goals.
   - AI asks about habits, distractions, wake/sleep time, focus windows, and procrastination patterns.

3. **AI Profile Creation**
   - AI converts the conversation into structured productivity profile data:
     - Annual goals
     - Monthly milestones
     - Daily habits
     - Focus windows
     - Weak hours
     - Procrastination triggers
     - Alarm preferences
     - Coaching tone

4. **Daily Plan Generation**
   - AI creates a full-day schedule:
     - Wake alarm
     - Focus blocks
     - Habit blocks
     - Breaks
     - Review time
     - Task check-ins

5. **Dashboard**
   - User sees today's productivity score, active task, next alarm, completed tasks, missed tasks, and lagging areas.

6. **Task Popup / Notification**
   - At task time, the app asks:
     - Completed?
     - Not completed?
     - Snooze?
     - Reschedule?
     - Why are you lagging?
     - What should be added?

7. **Reports**
   - Daily report:
     - Productivity score
     - Completed vs missed tasks
     - Main lag reason
     - Tomorrow's adjustment
   - Monthly report:
     - Monthly goal progress
     - Habit consistency
     - Best/worst productivity windows
   - Annual report:
     - Progress toward yearly goals
     - Long-term trend
     - AI recommendation for the next month

8. **AI Adjustment Loop**
   - If the user repeatedly misses tasks, AI changes the plan:
     - Moves hard tasks earlier
     - Breaks large tasks into smaller steps
     - Adds reminders
     - Reduces unrealistic scheduling
     - Updates monthly milestones

## Suggested Build Order

1. Convert the HTML prototype into Flutter screens.
2. Create the Flutter app theme and navigation.
3. Add Supabase Auth for login/signup.
4. Add Drift local database.
5. Build AI onboarding chat UI.
6. Store user goals and productivity profile.
7. Generate a daily plan from saved profile data.
8. Add local notifications and task actions.
9. Add daily/monthly/annual reports.
10. Add Supabase cloud sync.
11. Add advanced AI adjustment logic.
12. Add Android floating overlay only after the core app works.

## Important Defaults

- Build Android first.
- Keep the app offline-first.
- Store sensitive daily productivity data locally first.
- Use cloud sync only after the local experience works.
- Use AI for planning and summaries, but keep task data structured in the database.
- Prefer notification actions before floating windows.
