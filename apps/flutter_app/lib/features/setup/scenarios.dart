import '../../domain/conversation/session_enums.dart';

/// Ready-made role-play situations (spec §2.3 roleplay): who the AI plays,
/// the situation and the learner's goal. Sent to the model in English.
final class Scenario {
  const Scenario(
    this.labelKo, {
    required this.role,
    required this.situation,
    required this.goal,
  });

  final String labelKo;
  final String role;
  final String situation;
  final String goal;
}

const roleplayScenarios = [
  Scenario(
    '호텔 체크인',
    role: 'hotel front desk clerk',
    situation: 'Checking in at a hotel late at night',
    goal: 'Get a quiet room for two nights',
  ),
  Scenario(
    '식당 주문',
    role: 'restaurant server',
    situation: 'Ordering dinner at a busy restaurant',
    goal: 'Order a meal with one special request',
  ),
  Scenario(
    '카페 주문',
    role: 'barista',
    situation: 'Ordering at a coffee shop',
    goal: 'Order drinks for you and a friend',
  ),
  Scenario(
    '공항 체크인',
    role: 'airline check-in agent',
    situation: 'Checking in for an international flight',
    goal: 'Check a bag and ask for a window seat',
  ),
  Scenario(
    '길 묻기',
    role: 'friendly local',
    situation: 'Lost in a new city',
    goal: 'Find the way to the train station',
  ),
  Scenario(
    '취업 면접',
    role: 'job interviewer',
    situation: 'A job interview',
    goal: 'Introduce yourself and answer three questions',
  ),
  Scenario(
    '병원 진료',
    role: 'doctor',
    situation: 'Seeing a doctor about a cold',
    goal: 'Explain your symptoms and ask about medicine',
  ),
  Scenario(
    '물건 환불',
    role: 'store clerk',
    situation: 'Returning a broken product',
    goal: 'Get a refund or an exchange',
  ),
];

/// Topic ideas per mode; the learner can also type their own.
const topicSuggestions = <SessionMode, List<String>>{
  SessionMode.daily: ['My weekend', 'Hobbies', 'Today at work', 'Food I like'],
  SessionMode.theme: [
    'Travel',
    'Food and cooking',
    'Work life',
    'Movies and music',
    'Technology',
    'Health',
    'My hometown',
    'Future plans',
  ],
  SessionMode.storytelling: [
    'A memorable trip',
    'My first job',
    'An embarrassing moment',
    'A childhood memory',
    'A difficult decision',
  ],
  SessionMode.opinion: [
    'Remote work vs. the office',
    'Is social media good for us?',
    'Should cities ban cars downtown?',
    'AI in education',
    'A four-day work week',
  ],
};
