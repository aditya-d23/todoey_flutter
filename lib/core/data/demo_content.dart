class DayTask {
  const DayTask({
    required this.time,
    required this.title,
    required this.description,
    required this.status,
  });

  final String time;
  final String title;
  final String description;
  final String status;
}

const demoTasks = [
  DayTask(
    time: '6:15 AM',
    title: 'Wake alarm + mood check',
    description: 'Start the day and tell the coach your energy level.',
    status: 'Set',
  ),
  DayTask(
    time: '7:00 AM',
    title: 'Health habit',
    description: '20 min walk, water, and quick planning.',
    status: 'Pending',
  ),
  DayTask(
    time: '9:00 AM',
    title: 'App deep work',
    description: 'Build the productivity app while focus is highest.',
    status: 'Now',
  ),
  DayTask(
    time: '2:00 PM',
    title: 'Lag check popup',
    description: 'Report what blocked progress and what needs to change.',
    status: 'Pending',
  ),
  DayTask(
    time: '8:30 PM',
    title: 'Daily report',
    description: 'Generate score, missed tasks, and tomorrow adjustment.',
    status: 'Pending',
  ),
];

const monthlyMilestones = [
  'Complete the demo flow and Flutter screens',
  'Exercise 20 days this month',
  'Study every day for at least 45 minutes',
  'Reduce evening scrolling with automated check-ins',
];

const lagReasons = [
  'Phone scrolling after lunch',
  'Tasks are too large',
  'Late sleep reduces morning focus',
  'Unclear next action',
];
