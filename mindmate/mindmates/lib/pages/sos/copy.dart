import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Coping Strategies 🌟',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        hintColor: Colors.pink, // Custom color for the app's accent color
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: SafetyDartPage(),
    );
  }
}

class SafetyDartPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Coping Strategies', style: TextStyle(color: Colors.white)),
        backgroundColor: Theme.of(context).colorScheme.secondary, // Use accent color for the app bar
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            CopingStrategyCard(
  title: 'Practice Positive Self-Talk',
  description: 'Challenge and replace negative thoughts with positive and empowering affirmations. Be your own supportive friend.',
  cardColor: Colors.orangeAccent,
  titleColor: Colors.white,
  descriptionColor: Colors.black,
),
CopingStrategyCard(
  title: 'Engage in Cognitive Behavioral Therapy (CBT)',
  description: 'Learn CBT techniques to identify and change negative thought patterns. CBT is effective for managing various mental health conditions.',
  cardColor: Colors.blueAccent,
  titleColor: Colors.white,
  descriptionColor: Colors.black,
),
CopingStrategyCard(
  title: 'Explore Mind-Body Connection',
  description: 'Practice activities like yoga, tai chi, or meditation to connect your mental and physical well-being. These practices promote relaxation and mindfulness.',
  cardColor: Colors.orangeAccent,
  titleColor: Colors.white,
  descriptionColor: Colors.black,
),
CopingStrategyCard(
  title: 'Develop a Gratitude Ritual',
  description: 'Express gratitude daily by listing things you are thankful for. Gratitude practices enhance overall mental and emotional well-being.',
  cardColor: Colors.blueAccent,
  titleColor: Colors.white,
  descriptionColor: Colors.black,
),
CopingStrategyCard(
  title: 'Seek Social Support',
  description: 'Share your feelings and concerns with trusted friends or family members. Social support is vital for coping with mental health challenges.',
  cardColor: Colors.orangeAccent,
  titleColor: Colors.white,
  descriptionColor: Colors.black,
),
CopingStrategyCard(
  title: 'Practice Acceptance and Commitment Therapy (ACT)',
  description: 'Accept your thoughts and feelings without judgment. ACT teaches mindfulness skills to cope with difficult emotions and thoughts.',
  cardColor: Colors.blueAccent,
  titleColor: Colors.white,
  descriptionColor: Colors.black,
),
CopingStrategyCard(
  title: 'Explore Art Therapy',
  description: 'Engage in creative artistic activities as a way to express emotions. Art therapy can be particularly helpful for processing complex feelings.',
  cardColor: Colors.orangeAccent,
  titleColor: Colors.white,
  descriptionColor: Colors.black,
),
CopingStrategyCard(
  title: 'Establish a Relaxing Bedtime Routine',
  description: 'Create a calming bedtime ritual to improve sleep quality. Relaxing activities before sleep promote better mental and physical health.',
  cardColor: Colors.blueAccent,
  titleColor: Colors.white,
  descriptionColor: Colors.black,
),
CopingStrategyCard(
  title: 'Practice Emotional Regulation',
  description: 'Learn to identify, understand, and manage your emotions. Emotional regulation skills enhance mental resilience and well-being.',
  cardColor: Colors.orangeAccent,
  titleColor: Colors.white,
  descriptionColor: Colors.black,
),
CopingStrategyCard(
  title: 'Engage in Mindful Walking',
  description: 'Take mindful walks, focusing on your surroundings and sensations. Mindful walking can clear the mind and reduce stress.',
  cardColor: Colors.blueAccent,
  titleColor: Colors.white,
  descriptionColor: Colors.black,
),

            CopingStrategyCard(
  title: 'Practice Mindfulness',
  description: 'Engage in mindfulness meditation or breathing exercises to stay present and reduce anxiety.',
  cardColor: Colors.orangeAccent,
  titleColor: Colors.white,
  descriptionColor: Colors.black,
),
CopingStrategyCard(
  title: 'Stay Connected',
  description: 'Reach out to friends, family, or support groups. Social connections are crucial for mental well-being.',
  cardColor: Colors.blueAccent,
  titleColor: Colors.white,
  descriptionColor: Colors.black,
),
CopingStrategyCard(
  title: 'Express Gratitude',
  description: 'Take a moment each day to appreciate the positive aspects of your life. Gratitude can enhance overall happiness.',
  cardColor: Colors.orangeAccent,
  titleColor: Colors.white,
  descriptionColor: Colors.black,
),
CopingStrategyCard(
  title: 'Practice Self-Compassion',
  description: 'Be kind and understanding to yourself. Treat yourself with the same compassion you would offer to a friend facing similar struggles.',
  cardColor: Colors.blueAccent,
  titleColor: Colors.white,
  descriptionColor: Colors.black,
),
CopingStrategyCard(
  title: 'Stay Active',
  description: 'Engage in physical activities such as walking, jogging, or dancing. Exercise boosts mood and overall well-being.',
  cardColor: Colors.orangeAccent,
  titleColor: Colors.white,
  descriptionColor: Colors.black,
),
CopingStrategyCard(
  title: 'Limit Social Media',
  description: 'Reduce time spent on social media platforms to avoid negative influences and promote real-life connections.',
  cardColor: Colors.blueAccent,
  titleColor: Colors.white,
  descriptionColor: Colors.black,
),
CopingStrategyCard(
  title: 'Practice Relaxation Techniques',
  description: 'Learn relaxation methods like deep breathing or progressive muscle relaxation. These techniques reduce stress and promote calmness.',
  cardColor: Colors.orangeAccent,
  titleColor: Colors.white,
  descriptionColor: Colors.black,
),
CopingStrategyCard(
  title: 'Set Realistic Goals',
  description: 'Break down tasks into manageable steps and set achievable goals. Celebrate your accomplishments to boost self-esteem.',
  cardColor: Colors.blueAccent,
  titleColor: Colors.white,
  descriptionColor: Colors.black,
),
CopingStrategyCard(
  title: 'Help Others',
  description: 'Volunteer or help someone in need. Acts of kindness boost your mood and create a sense of fulfillment.',
  cardColor: Colors.orangeAccent,
  titleColor: Colors.white,
  descriptionColor: Colors.black,
),
CopingStrategyCard(
  title: 'Connect with Nature',
  description: 'Spend time outdoors and connect with nature. Nature has a calming effect and promotes relaxation and well-being.',
  cardColor: Colors.blueAccent,
  titleColor: Colors.white,
  descriptionColor: Colors.black,
),
CopingStrategyCard(
  title: 'Take Breaks',
  description: 'Schedule short breaks during work or study sessions. Relaxation can improve focus and productivity.',
  cardColor: Colors.orangeAccent,
  titleColor: Colors.white,
  descriptionColor: Colors.black,
),
CopingStrategyCard(
  title: 'Practice Breathing Exercises',
  description: 'Practice deep breathing exercises to calm your mind and reduce stress. Inhale deeply, hold, and exhale slowly.',
  cardColor: Colors.blueAccent,
  titleColor: Colors.white,
  descriptionColor: Colors.black,
),
CopingStrategyCard(
  title: 'Engage in Creative Activities',
  description: 'Explore your creative side through art, writing, or music. Creative expression can be therapeutic and enjoyable.',
  cardColor: Colors.orangeAccent,
  titleColor: Colors.white,
  descriptionColor: Colors.black,
),
CopingStrategyCard(
  title: 'Learn a New Skill',
  description: 'Pick up a new hobby or learn something new. Lifelong learning keeps the mind engaged and boosts self-confidence.',
  cardColor: Colors.blueAccent,
  titleColor: Colors.white,
  descriptionColor: Colors.black,
),
CopingStrategyCard(
  title: 'Practice Positive Affirmations',
  description: 'Repeat positive affirmations daily to boost self-esteem and promote a positive mindset. Believe in your abilities.',
  cardColor: Colors.orangeAccent,
  titleColor: Colors.white,
  descriptionColor: Colors.black,
),
CopingStrategyCard(
  title: 'Maintain a Journal',
  description: 'Write down your thoughts, feelings, and experiences in a journal. Journaling can provide clarity and emotional release.',
  cardColor: Colors.blueAccent,
  titleColor: Colors.white,
  descriptionColor: Colors.black,
),
CopingStrategyCard(
  title: 'Volunteer for a Cause',
  description: 'Contribute to a cause you care about. Volunteering gives a sense of purpose and strengthens the sense of community.',
  cardColor: Colors.orangeAccent,
  titleColor: Colors.white,
  descriptionColor: Colors.black,
),
CopingStrategyCard(
  title: 'Practice Mindful Eating',
  description: 'Pay attention to your food while eating. Mindful eating promotes a healthier relationship with food and body.',
  cardColor: Colors.blueAccent,
  titleColor: Colors.white,
  descriptionColor: Colors.black,
),
CopingStrategyCard(
  title: 'Explore Nature',
  description: 'Take nature walks, go camping, or simply spend time in natural surroundings. Nature promotes relaxation and reduces stress.',
  cardColor: Colors.orangeAccent,
  titleColor: Colors.white,
  descriptionColor: Colors.black,
),
CopingStrategyCard(
  title: 'Practice the 5-4-3-2-1 Technique',
  description: 'Engage your senses by acknowledging 5 things you can see, 4 things you can touch, 3 things you hear, 2 things you smell, and 1 thing you taste.',
  cardColor: Colors.blueAccent,
  titleColor: Colors.white,
  descriptionColor: Colors.black,
),
CopingStrategyCard(
  title: 'Practice Progressive Muscle Relaxation',
  description: 'Tense and then relax different muscle groups to reduce physical and mental tension. This promotes relaxation and stress relief.',
  cardColor: Colors.orangeAccent,
  titleColor: Colors.white,
  descriptionColor: Colors.black,
),
CopingStrategyCard(
  title: 'Engage in Digital Detox',
  description: 'Take a break from screens (phone, computer, TV) to reduce eye strain and mental fatigue. Use this time for other activities or hobbies.',
  cardColor: Colors.blueAccent,
  titleColor: Colors.white,
  descriptionColor: Colors.black,
),
CopingStrategyCard(
  title: 'Practice Grounding Techniques',
  description: 'Ground yourself in the present moment by focusing on your senses. Notice what you see, hear, smell, touch, and taste. This can reduce anxiety.',
  cardColor: Colors.orangeAccent,
  titleColor: Colors.white,
  descriptionColor: Colors.black,
),
CopingStrategyCard(
  title: 'Set Healthy Boundaries',
  description: 'Clearly define what you are comfortable with and communicate your limits to others. Setting boundaries is essential for emotional well-being.',
  cardColor: Colors.blueAccent,
  titleColor: Colors.white,
  descriptionColor: Colors.black,
),
CopingStrategyCard(
  title: 'Practice Guided Imagery',
  description: 'Imagine a peaceful place or scenario to relax your mind. Guided imagery can reduce stress and promote a sense of calmness.',
  cardColor: Colors.orangeAccent,
  titleColor: Colors.white,
  descriptionColor: Colors.black,
),
CopingStrategyCard(
  title: 'Engage in Laughter Therapy',
  description: 'Watch a comedy show, read jokes, or spend time with people who make you laugh. Laughter releases endorphins, boosting your mood.',
  cardColor: Colors.blueAccent,
  titleColor: Colors.white,
  descriptionColor: Colors.black,
),
CopingStrategyCard(
  title: 'Practice Emotional Freedom Techniques (EFT)',
  description: 'Tap specific points on your body while focusing on a negative emotion. EFT is believed to release emotional blockages and reduce anxiety.',
  cardColor: Colors.orangeAccent,
  titleColor: Colors.white,
  descriptionColor: Colors.black,
),
CopingStrategyCard(
  title: 'Learn Stress-Reduction Breathing Techniques',
  description: 'Practice techniques like box breathing or 4-7-8 breathing. These methods can calm the nervous system and reduce stress levels.',
  cardColor: Colors.blueAccent,
  titleColor: Colors.white,
  descriptionColor: Colors.black,
),
CopingStrategyCard(
  title: 'Create a Relaxation Playlist',
  description: 'Compile a playlist of calming music or nature sounds. Listening to relaxing music can reduce stress and promote relaxation.',
  cardColor: Colors.orangeAccent,
  titleColor: Colors.white,
  descriptionColor: Colors.black,
),
CopingStrategyCard(
  title: 'Learn and Practice Time Management',
  description: 'Improve your time management skills to reduce feelings of overwhelm. Prioritize tasks and allocate time effectively for better productivity.',
  cardColor: Colors.blueAccent,
  titleColor: Colors.white,
  descriptionColor: Colors.black,
),
CopingStrategyCard(
  title: 'Practice Mindful Breathing',
  description: 'Focus on your breath, inhaling and exhaling slowly. Mindful breathing calms the mind and reduces stress and anxiety.',
  cardColor: Colors.orangeAccent,
  titleColor: Colors.white,
  descriptionColor: Colors.black,
),
CopingStrategyCard(
  title: 'Engage in Positive Visualization',
  description: 'Visualize yourself in a calm and positive situation. Visualization can reduce anxiety and promote a sense of well-being.',
  cardColor: Colors.blueAccent,
  titleColor: Colors.white,
  descriptionColor: Colors.black,
),
CopingStrategyCard(
  title: 'Develop a Relaxation Routine',
  description: 'Establish a daily relaxation routine with activities like reading, listening to music, or taking a warm bath. Consistent relaxation promotes mental peace.',
  cardColor: Colors.orangeAccent,
  titleColor: Colors.white,
  descriptionColor: Colors.black,
),
CopingStrategyCard(
  title: 'Engage in Laughter Yoga',
  description: 'Combine laughter exercises with yogic deep breathing. Laughter yoga reduces stress and boosts mood and energy levels.',
  cardColor: Colors.blueAccent,
  titleColor: Colors.white,
  descriptionColor: Colors.black,
),
CopingStrategyCard(
  title: 'Practice Compassion Meditation',
  description: 'Meditate on feelings of compassion and love. Compassion meditation enhances empathy and reduces negative emotions.',
  cardColor: Colors.orangeAccent,
  titleColor: Colors.white,
  descriptionColor: Colors.black,
),
CopingStrategyCard(
  title: 'Engage in Nature Therapy',
  description: 'Spend time in nature and engage with the natural environment. Nature therapy, or ecotherapy, promotes mental and emotional well-being.',
  cardColor: Colors.blueAccent,
  titleColor: Colors.white,
  descriptionColor: Colors.black,
),
CopingStrategyCard(
  title: 'Develop a Growth Mindset',
  description: 'Cultivate a belief in your ability to learn and adapt. Embracing challenges and setbacks as opportunities for growth enhances resilience.',
  cardColor: Colors.orangeAccent,
  titleColor: Colors.white,
  descriptionColor: Colors.black,
),
CopingStrategyCard(
  title: 'Practice Body Scan Meditation',
  description: 'Scan your body for sensations, releasing tension in each area. Body scan meditation promotes relaxation and body awareness.',
  cardColor: Colors.blueAccent,
  titleColor: Colors.white,
  descriptionColor: Colors.black,
),
CopingStrategyCard(
  title: 'Explore Holistic Healing',
  description: 'Consider complementary therapies like acupuncture, massage, or aromatherapy. Holistic healing approaches support overall mental and physical health.',
  cardColor: Colors.orangeAccent,
  titleColor: Colors.white,
  descriptionColor: Colors.black,
),
CopingStrategyCard(
  title: 'Engage in Mindful Journaling',
  description: 'Write about your thoughts, emotions, and experiences in a mindful and reflective way. Mindful journaling promotes self-awareness and emotional expression.',
  cardColor: Colors.blueAccent,
  titleColor: Colors.white,
  descriptionColor: Colors.black,
),
CopingStrategyCard(
  title: 'Engage in Community Service',
  description: 'Volunteer for community service projects. Giving back to others can provide a sense of purpose and fulfillment.',
  cardColor: Colors.orangeAccent,
  titleColor: Colors.white,
  descriptionColor: Colors.black,
),
CopingStrategyCard(
  title: 'Practice Progressive Relaxation',
  description: 'Progressively tense and relax muscle groups to release physical and mental tension. This technique promotes deep relaxation.',
  cardColor: Colors.blueAccent,
  titleColor: Colors.white,
  descriptionColor: Colors.black,
),
CopingStrategyCard(
  title: 'Create a Supportive Network',
  description: 'Surround yourself with positive and supportive individuals. Building a strong social network enhances resilience and well-being.',
  cardColor: Colors.orangeAccent,
  titleColor: Colors.white,
  descriptionColor: Colors.black,
),
CopingStrategyCard(
  title: 'Engage in Therapeutic Art',
  description: 'Participate in art therapy activities like painting, drawing, or sculpting. Therapeutic art expression can aid emotional healing.',
  cardColor: Colors.blueAccent,
  titleColor: Colors.white,
  descriptionColor: Colors.black,
),
CopingStrategyCard(
  title: 'Practice Loving-Kindness Meditation',
  description: 'Meditate on developing feelings of love and compassion towards yourself and others. Loving-kindness meditation enhances emotional well-being.',
  cardColor: Colors.orangeAccent,
  titleColor: Colors.white,
  descriptionColor: Colors.black,
),
CopingStrategyCard(
  title: 'Establish Healthy Sleep Hygiene',
  description: 'Create a conducive sleep environment and follow a regular sleep schedule. Quality sleep is essential for mental and physical health.',
  cardColor: Colors.blueAccent,
  titleColor: Colors.white,
  descriptionColor: Colors.black,
),
CopingStrategyCard(
  title: 'Engage in Play Therapy',
  description: 'Participate in playful activities to reduce stress. Play therapy is not just for children; it can benefit adults too.',
  cardColor: Colors.orangeAccent,
  titleColor: Colors.white,
  descriptionColor: Colors.black,
),
CopingStrategyCard(
  title: 'Practice Mindful Self-Compassion',
  description: 'Be kind and understanding toward yourself in moments of struggle. Mindful self-compassion enhances self-love and emotional resilience.',
  cardColor: Colors.blueAccent,
  titleColor: Colors.white,
  descriptionColor: Colors.black,
),
CopingStrategyCard(
  title: 'Engage in Humor Therapy',
  description: 'Watch comedy shows, read jokes, or engage in humor-based activities. Laughter therapy can boost mood and reduce stress.',
  cardColor: Colors.orangeAccent,
  titleColor: Colors.white,
  descriptionColor: Colors.black,
),
CopingStrategyCard(
  title: 'Practice Grounding Meditation',
  description: 'Ground yourself in the present moment using meditation techniques. Grounding promotes stability and reduces feelings of disconnection.',
  cardColor: Colors.blueAccent,
  titleColor: Colors.white,
  descriptionColor: Colors.black,
),
CopingStrategyCard(
  title: 'Engage in Mindful Eating',
  description: 'Eat mindfully, savoring each bite. Mindful eating practices enhance the relationship between food, body, and emotions.',
  cardColor: Colors.orangeAccent,
  titleColor: Colors.white,
  descriptionColor: Colors.black,
),
CopingStrategyCard(
  title: 'Embrace the Power of Affirmations',
  description: 'Repeat positive affirmations daily to reinforce self-belief and positive thinking. Affirmations can reshape your mindset.',
  cardColor: Colors.blueAccent,
  titleColor: Colors.white,
  descriptionColor: Colors.black,
),
CopingStrategyCard(
  title: 'Engage in Sensory Activities',
  description: 'Explore sensory experiences like aromatherapy, massage, or nature walks. Sensory activities can promote relaxation and stress relief.',
  cardColor: Colors.orangeAccent,
  titleColor: Colors.white,
  descriptionColor: Colors.black,
),
CopingStrategyCard(
  title: 'Practice Emotional Freedom Techniques (EFT)',
  description: 'Use tapping techniques to release emotional blockages. EFT can reduce anxiety, stress, and negative emotions.',
  cardColor: Colors.blueAccent,
  titleColor: Colors.white,
  descriptionColor: Colors.black,
),
CopingStrategyCard(
  title: 'Engage in Playful Activities',
  description: 'Participate in activities that bring joy, such as playing games or engaging in hobbies. Playfulness promotes a positive mindset.',
  cardColor: Colors.orangeAccent,
  titleColor: Colors.white,
  descriptionColor: Colors.black,
),


            // Add more CopingStrategyCard widgets as needed
          ],
        ),
      ),
    );
  }
}

class CopingStrategyCard extends StatelessWidget {
  final String title;
  final String description;
  final Color cardColor;
  final Color titleColor;
  final Color descriptionColor;

  CopingStrategyCard({
    required this.title,
    required this.description,
    required this.cardColor,
    required this.titleColor,
    required this.descriptionColor,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4.0,
      margin: EdgeInsets.symmetric(vertical: 8.0),
      color: cardColor, // Set the card's background color
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              title,
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold, color: titleColor),
            ),
            SizedBox(height: 8.0),
            Text(
              description,
              style: TextStyle(color: descriptionColor),
            ),
          ],
        ),
      ),
    );
  }
}
