import '../../../../core/models/cefr_level.dart';
import '../../domain/models/vocabulary_word.dart';

const mockWords = <VocabularyWord>[
  // Technology
  VocabularyWord(id: 'w_tech_1', term: 'deploy', meaning: 'to release software for use', exampleSentence: 'We deploy every Friday.', categoryId: 'tech', difficulty: WordDifficulty.medium, cefrLevel: CefrLevel.b2, tags: ['software', 'release']),
  VocabularyWord(id: 'w_tech_2', term: 'bandwidth', meaning: 'data transfer capacity', exampleSentence: 'Low bandwidth today.', categoryId: 'tech', difficulty: WordDifficulty.medium, cefrLevel: CefrLevel.b2, tags: ['network', 'internet']),
  VocabularyWord(id: 'w_tech_3', term: 'cache', meaning: 'temporary fast storage', exampleSentence: 'Clear the cache.', categoryId: 'tech', difficulty: WordDifficulty.easy, cefrLevel: CefrLevel.b1, tags: ['storage', 'browser']),
  VocabularyWord(id: 'w_tech_4', term: 'latency', meaning: 'delay before a response', exampleSentence: 'The latency is high.', categoryId: 'tech', difficulty: WordDifficulty.hard, cefrLevel: CefrLevel.c1, tags: ['network', 'performance']),
  VocabularyWord(id: 'w_tech_5', term: 'firewall', meaning: 'a network security barrier', exampleSentence: 'The firewall blocks it.', categoryId: 'tech', difficulty: WordDifficulty.easy, cefrLevel: CefrLevel.b1, tags: ['security', 'network']),
  VocabularyWord(id: 'w_tech_6', term: 'protocol', meaning: 'a set of communication rules', exampleSentence: 'HTTP is a protocol.', categoryId: 'tech', difficulty: WordDifficulty.medium, cefrLevel: CefrLevel.b2, tags: ['network', 'rules']),
  VocabularyWord(id: 'w_tech_7', term: 'encryption', meaning: 'encoding data for secrecy', exampleSentence: 'End-to-end encryption.', categoryId: 'tech', difficulty: WordDifficulty.medium, cefrLevel: CefrLevel.b2, tags: ['security', 'privacy']),
  VocabularyWord(id: 'w_tech_8', term: 'backend', meaning: 'the server-side of an app', exampleSentence: 'Backend handles auth.', categoryId: 'tech', difficulty: WordDifficulty.easy, cefrLevel: CefrLevel.b1, tags: ['software', 'server']),
  VocabularyWord(id: 'w_tech_9', term: 'stack', meaning: 'technologies used together', exampleSentence: 'Our stack is Flutter.', categoryId: 'tech', difficulty: WordDifficulty.easy, cefrLevel: CefrLevel.a2, tags: ['software']),
  VocabularyWord(id: 'w_tech_10', term: 'throughput', meaning: 'amount processed per unit time', exampleSentence: 'Higher throughput now.', categoryId: 'tech', difficulty: WordDifficulty.hard, cefrLevel: CefrLevel.c1, tags: ['performance']),

  // Business
  VocabularyWord(id: 'w_biz_1', term: 'revenue', meaning: 'total income from sales', exampleSentence: 'Q3 revenue beat targets.', categoryId: 'business', difficulty: WordDifficulty.easy, cefrLevel: CefrLevel.b1, tags: ['finance', 'sales']),
  VocabularyWord(id: 'w_biz_2', term: 'stakeholder', meaning: 'someone with interest in a project', exampleSentence: 'Align with stakeholders.', categoryId: 'business', difficulty: WordDifficulty.medium, cefrLevel: CefrLevel.b2, tags: ['management']),
  VocabularyWord(id: 'w_biz_3', term: 'leverage', meaning: 'to use for advantage', exampleSentence: 'Leverage the partnership.', categoryId: 'business', difficulty: WordDifficulty.medium, cefrLevel: CefrLevel.b2, tags: ['strategy']),
  VocabularyWord(id: 'w_biz_4', term: 'scalable', meaning: 'able to grow efficiently', exampleSentence: 'The model is scalable.', categoryId: 'business', difficulty: WordDifficulty.medium, cefrLevel: CefrLevel.b2, tags: ['growth']),
  VocabularyWord(id: 'w_biz_5', term: 'margin', meaning: 'profit after costs', exampleSentence: 'Thin margin this year.', categoryId: 'business', difficulty: WordDifficulty.medium, cefrLevel: CefrLevel.b1, tags: ['finance', 'profit']),
  VocabularyWord(id: 'w_biz_6', term: 'forecast', meaning: 'a prediction of future results', exampleSentence: 'The forecast is good.', categoryId: 'business', difficulty: WordDifficulty.easy, cefrLevel: CefrLevel.b1, tags: ['planning']),
  VocabularyWord(id: 'w_biz_7', term: 'equity', meaning: 'ownership value in a company', exampleSentence: 'Employees get equity.', categoryId: 'business', difficulty: WordDifficulty.hard, cefrLevel: CefrLevel.c1, tags: ['finance', 'ownership']),
  VocabularyWord(id: 'w_biz_8', term: 'pipeline', meaning: 'sequence of prospective deals', exampleSentence: 'Strong sales pipeline.', categoryId: 'business', difficulty: WordDifficulty.medium, cefrLevel: CefrLevel.b2, tags: ['sales']),
  VocabularyWord(id: 'w_biz_9', term: 'runway', meaning: 'months of cash remaining', exampleSentence: 'We have 18 months runway.', categoryId: 'business', difficulty: WordDifficulty.hard, cefrLevel: CefrLevel.c1, tags: ['startup', 'finance']),
  VocabularyWord(id: 'w_biz_10', term: 'acquisition', meaning: 'buying another company', exampleSentence: 'The acquisition closed.', categoryId: 'business', difficulty: WordDifficulty.hard, cefrLevel: CefrLevel.b2, tags: ['finance', 'merger']),

  // Travel
  VocabularyWord(id: 'w_travel_1', term: 'itinerary', meaning: 'a planned travel schedule', exampleSentence: 'Send me the itinerary.', categoryId: 'travel', difficulty: WordDifficulty.medium, cefrLevel: CefrLevel.b2, tags: ['travel', 'planning']),
  VocabularyWord(id: 'w_travel_2', term: 'layover', meaning: 'a stop between flights', exampleSentence: 'Two-hour layover.', categoryId: 'travel', difficulty: WordDifficulty.medium, cefrLevel: CefrLevel.b1, tags: ['travel', 'airport']),
  VocabularyWord(id: 'w_travel_3', term: 'customs', meaning: 'border goods inspection', exampleSentence: 'Got through customs fast.', categoryId: 'travel', difficulty: WordDifficulty.easy, cefrLevel: CefrLevel.b1, tags: ['travel', 'airport', 'border']),
  VocabularyWord(id: 'w_travel_4', term: 'boarding', meaning: 'getting on a plane', exampleSentence: 'Boarding starts soon.', categoryId: 'travel', difficulty: WordDifficulty.easy, cefrLevel: CefrLevel.a2, tags: ['travel', 'airport']),
  VocabularyWord(id: 'w_travel_5', term: 'currency', meaning: 'the money of a country', exampleSentence: 'Which currency?', categoryId: 'travel', difficulty: WordDifficulty.easy, cefrLevel: CefrLevel.a2, tags: ['travel', 'money']),
  VocabularyWord(id: 'w_travel_6', term: 'destination', meaning: 'the place you travel to', exampleSentence: 'Kyoto is our destination.', categoryId: 'travel', difficulty: WordDifficulty.easy, cefrLevel: CefrLevel.a2, tags: ['travel']),
  VocabularyWord(id: 'w_travel_7', term: 'detour', meaning: 'an indirect route', exampleSentence: 'Taking a detour.', categoryId: 'travel', difficulty: WordDifficulty.medium, cefrLevel: CefrLevel.b2, tags: ['travel', 'road']),
  VocabularyWord(id: 'w_travel_8', term: 'embassy', meaning: "a country's official office abroad", exampleSentence: 'Visit the embassy.', categoryId: 'travel', difficulty: WordDifficulty.medium, cefrLevel: CefrLevel.b2, tags: ['travel', 'government']),
  VocabularyWord(id: 'w_travel_9', term: 'souvenir', meaning: 'an object kept as a reminder', exampleSentence: 'Bought a souvenir.', categoryId: 'travel', difficulty: WordDifficulty.medium, cefrLevel: CefrLevel.b1, tags: ['travel', 'gift']),
  VocabularyWord(id: 'w_travel_10', term: 'jet lag', meaning: 'tiredness from long flights', exampleSentence: 'Jet lag hit me hard.', categoryId: 'travel', difficulty: WordDifficulty.easy, cefrLevel: CefrLevel.b1, tags: ['travel']),

  // Daily Life
  VocabularyWord(id: 'w_daily_1', term: 'errand', meaning: 'a short trip to do a small task', exampleSentence: 'Running errands.', categoryId: 'daily', difficulty: WordDifficulty.medium, cefrLevel: CefrLevel.b1, tags: ['daily']),
  VocabularyWord(id: 'w_daily_2', term: 'commute', meaning: 'regular travel to work', exampleSentence: '45-minute commute.', categoryId: 'daily', difficulty: WordDifficulty.easy, cefrLevel: CefrLevel.b1, tags: ['daily', 'work']),
  VocabularyWord(id: 'w_daily_3', term: 'appointment', meaning: 'a planned meeting', exampleSentence: 'Doctor appointment at 3.', categoryId: 'daily', difficulty: WordDifficulty.easy, cefrLevel: CefrLevel.a2, tags: ['daily']),
  VocabularyWord(id: 'w_daily_4', term: 'chore', meaning: 'a routine household task', exampleSentence: 'Dishes are a chore.', categoryId: 'daily', difficulty: WordDifficulty.easy, cefrLevel: CefrLevel.a2, tags: ['daily', 'home']),
  VocabularyWord(id: 'w_daily_5', term: 'leftover', meaning: 'food remaining after a meal', exampleSentence: 'Ate leftovers.', categoryId: 'daily', difficulty: WordDifficulty.easy, cefrLevel: CefrLevel.a2, tags: ['daily', 'food']),
  VocabularyWord(id: 'w_daily_6', term: 'groceries', meaning: 'food and household supplies', exampleSentence: 'Getting groceries.', categoryId: 'daily', difficulty: WordDifficulty.easy, cefrLevel: CefrLevel.a2, tags: ['daily', 'food']),
  VocabularyWord(id: 'w_daily_7', term: 'laundry', meaning: 'clothes to be washed', exampleSentence: 'Laundry piling up.', categoryId: 'daily', difficulty: WordDifficulty.easy, cefrLevel: CefrLevel.a1, tags: ['daily', 'home']),
  VocabularyWord(id: 'w_daily_8', term: 'receipt', meaning: 'proof of purchase', exampleSentence: 'Keep the receipt.', categoryId: 'daily', difficulty: WordDifficulty.easy, cefrLevel: CefrLevel.a2, tags: ['daily', 'shopping']),
  VocabularyWord(id: 'w_daily_9', term: 'deadline', meaning: 'a time limit', exampleSentence: 'Deadline tomorrow.', categoryId: 'daily', difficulty: WordDifficulty.easy, cefrLevel: CefrLevel.a2, tags: ['daily', 'work']),
  VocabularyWord(id: 'w_daily_10', term: 'neighbor', meaning: 'a person living nearby', exampleSentence: 'Good neighbor.', categoryId: 'daily', difficulty: WordDifficulty.easy, cefrLevel: CefrLevel.a1, tags: ['daily', 'home']),

  // Cinema
  VocabularyWord(id: 'w_cinema_1', term: 'plot', meaning: 'the story of a film', exampleSentence: 'Twisted plot.', categoryId: 'cinema', difficulty: WordDifficulty.easy, cefrLevel: CefrLevel.a2, tags: ['cinema', 'story']),
  VocabularyWord(id: 'w_cinema_2', term: 'sequel', meaning: 'a follow-up film', exampleSentence: 'The sequel is better.', categoryId: 'cinema', difficulty: WordDifficulty.easy, cefrLevel: CefrLevel.b1, tags: ['cinema']),
  VocabularyWord(id: 'w_cinema_3', term: 'cast', meaning: 'the actors in a film', exampleSentence: 'Strong cast.', categoryId: 'cinema', difficulty: WordDifficulty.easy, cefrLevel: CefrLevel.a2, tags: ['cinema']),
  VocabularyWord(id: 'w_cinema_4', term: 'scene', meaning: 'a segment of a film', exampleSentence: 'Favorite scene.', categoryId: 'cinema', difficulty: WordDifficulty.easy, cefrLevel: CefrLevel.a1, tags: ['cinema']),
  VocabularyWord(id: 'w_cinema_5', term: 'cameo', meaning: 'a brief appearance by a famous person', exampleSentence: 'Director cameo.', categoryId: 'cinema', difficulty: WordDifficulty.hard, cefrLevel: CefrLevel.c1, tags: ['cinema']),
  VocabularyWord(id: 'w_cinema_6', term: 'soundtrack', meaning: 'the music of a film', exampleSentence: 'Great soundtrack.', categoryId: 'cinema', difficulty: WordDifficulty.easy, cefrLevel: CefrLevel.a2, tags: ['cinema', 'music']),
  VocabularyWord(id: 'w_cinema_7', term: 'protagonist', meaning: 'the main character', exampleSentence: 'The protagonist struggles.', categoryId: 'cinema', difficulty: WordDifficulty.medium, cefrLevel: CefrLevel.b2, tags: ['cinema', 'story']),
  VocabularyWord(id: 'w_cinema_8', term: 'antagonist', meaning: 'the character opposing the hero', exampleSentence: 'Sympathetic antagonist.', categoryId: 'cinema', difficulty: WordDifficulty.medium, cefrLevel: CefrLevel.b2, tags: ['cinema', 'story']),
  VocabularyWord(id: 'w_cinema_9', term: 'spoiler', meaning: 'a detail that ruins surprise', exampleSentence: 'No spoilers!', categoryId: 'cinema', difficulty: WordDifficulty.easy, cefrLevel: CefrLevel.b1, tags: ['cinema']),
  VocabularyWord(id: 'w_cinema_10', term: 'twist', meaning: 'an unexpected story change', exampleSentence: 'Surprising twist.', categoryId: 'cinema', difficulty: WordDifficulty.medium, cefrLevel: CefrLevel.b1, tags: ['cinema', 'story']),

  // Science
  VocabularyWord(id: 'w_sci_1', term: 'hypothesis', meaning: 'a testable proposed explanation', exampleSentence: 'Test the hypothesis.', categoryId: 'science', difficulty: WordDifficulty.medium, cefrLevel: CefrLevel.c1, tags: ['science']),
  VocabularyWord(id: 'w_sci_2', term: 'gravity', meaning: 'force pulling masses together', exampleSentence: 'Gravity on Earth.', categoryId: 'science', difficulty: WordDifficulty.easy, cefrLevel: CefrLevel.b1, tags: ['science', 'physics']),
  VocabularyWord(id: 'w_sci_3', term: 'molecule', meaning: 'a group of bonded atoms', exampleSentence: 'Water molecule.', categoryId: 'science', difficulty: WordDifficulty.easy, cefrLevel: CefrLevel.b2, tags: ['science', 'chemistry']),
  VocabularyWord(id: 'w_sci_4', term: 'evolution', meaning: 'gradual change over time', exampleSentence: 'Theory of evolution.', categoryId: 'science', difficulty: WordDifficulty.medium, cefrLevel: CefrLevel.b2, tags: ['science', 'biology']),
  VocabularyWord(id: 'w_sci_5', term: 'orbit', meaning: 'the path around another object', exampleSentence: "Moon's orbit.", categoryId: 'science', difficulty: WordDifficulty.easy, cefrLevel: CefrLevel.b1, tags: ['science', 'space']),
  VocabularyWord(id: 'w_sci_6', term: 'particle', meaning: 'a very small piece of matter', exampleSentence: 'Subatomic particle.', categoryId: 'science', difficulty: WordDifficulty.medium, cefrLevel: CefrLevel.b2, tags: ['science', 'physics']),
  VocabularyWord(id: 'w_sci_7', term: 'genome', meaning: 'complete set of genetic material', exampleSentence: 'Human genome.', categoryId: 'science', difficulty: WordDifficulty.hard, cefrLevel: CefrLevel.c1, tags: ['science', 'biology']),
  VocabularyWord(id: 'w_sci_8', term: 'vaccine', meaning: 'a preparation that builds immunity', exampleSentence: 'Got the vaccine.', categoryId: 'science', difficulty: WordDifficulty.easy, cefrLevel: CefrLevel.b1, tags: ['science', 'medicine']),
  VocabularyWord(id: 'w_sci_9', term: 'ecosystem', meaning: 'a community of living things', exampleSentence: 'Reef ecosystem.', categoryId: 'science', difficulty: WordDifficulty.medium, cefrLevel: CefrLevel.b2, tags: ['science', 'biology', 'environment']),
  VocabularyWord(id: 'w_sci_10', term: 'photosynthesis', meaning: 'plants converting light to energy', exampleSentence: 'Photosynthesis in leaves.', categoryId: 'science', difficulty: WordDifficulty.hard, cefrLevel: CefrLevel.c1, tags: ['science', 'biology']),
];