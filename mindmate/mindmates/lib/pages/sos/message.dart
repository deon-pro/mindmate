import 'package:flutter/material.dart';
import 'dart:math';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Encouraging Messages 🤗',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MentalHealthSupportScreen(),
    );
  }
}

class MentalHealthSupportScreen extends StatefulWidget {
  @override
  _MentalHealthSupportScreenState createState() =>
      _MentalHealthSupportScreenState();
}

class _MentalHealthSupportScreenState extends State<MentalHealthSupportScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Color?> _colorAnimation;

  List<String> positiveMessages = [
"You are not alone, reach out to someone who understands.",
"You are strong, you can overcome the challenges of mental illness.",
"Every day may not be good, but there's something good in every day.",
"Your feelings are valid, it's okay not to be okay.",
"Seek help when you need it, asking for help is a sign of strength.",
"Your mental health matters, take care of yourself.",
"Be patient with yourself, healing takes time.",
"Recovery is a journey, not a destination, be proud of your progress.",
"You are resilient, your strength is greater than any challenge.",
"Your worth is not determined by your mental health.",
"Be kind to yourself, you're doing the best you can.",
"It's okay to have setbacks, what matters is your willingness to keep going.",
"Every step you take is a step toward healing.",
"Focus on progress, not perfection.",
"Your story is not over, it's just beginning.",
"Embrace the support around you, you don't have to face this alone.",
"Your strength lies in your ability to overcome challenges.",
"Believe in yourself, you are stronger than you think.",
"Take one day at a time, one moment at a time.",
"You are worthy of love, understanding, and compassion.",
"Your feelings are valid, don't let anyone invalidate them.",
"Be gentle with yourself, you're doing the best you can.",
"Your journey is unique to you, don't compare it to others.",
"Find joy in the small victories, they matter the most.",
"Surround yourself with positivity and those who uplift you.",
"Your mental illness does not define you, your strength and courage do.",
"Be patient with your progress, big things take time.",
"Your thoughts and emotions may be overwhelming, but they are temporary.",
"Reach out to others, connections can make a world of difference.",
"Your resilience is your strength, keep going.",
"Take care of your mind, it's okay to take breaks and rest.",
"You are not a burden, your presence matters.",
"Your worth is not determined by your productivity.",
"Believe in the power of healing, it's within you.",
"Your journey toward healing is a brave one.",
"Be proud of the progress you've made, no matter how small it seems.",
"Your mental health is a priority, don't neglect it.",
"Find strength in your vulnerability, it takes courage to open up.",
"Your experiences shape you, but they don't define you.",
"Be patient with the process, healing takes time and effort.",
"Your journey is significant, embrace it.",
"Believe in your ability to cope, you've made it through tough times before.",
"Your strength is inspiring, even on the hardest days.",
"Take care of your mental health, it's a vital part of your well-being.",
"Your struggles do not diminish your worth.",
"Be kind to your mind, it's okay to have challenging days.",
"Your resilience is remarkable, celebrate it.",
"Believe in your inner strength, it's always there, even in the darkest moments.",
"Your story matters, share it with someone you trust.",
"Take a moment to breathe, you are doing great.",
"Your journey is a testament to your strength and courage.",
"Believe in your ability to overcome, you are stronger than you know.",
"Your mental health is important, prioritize it.",
"Take small steps, they lead to significant progress.",
"Your struggles do not define you, your courage does.",
"Believe in your ability to heal, it's never too late.",
"Your worth is inherent, you are valuable just as you are.",
"Take time for self-care, it's essential for your well-being.",
"Your strength is unmatched, keep going.",
"Believe in the beauty of your resilience, it shines through your challenges.",
"Your journey is a testament to your bravery, acknowledge it.",
"Take pride in your progress, no matter how slow it may seem.",
"Your mental health matters, don't hesitate to seek help.",
"Believe in your ability to rise above, you are capable of overcoming.",
"Your worth is not determined by your struggles.",
"Take a moment to acknowledge your strength, it's extraordinary.",
"Your resilience knows no bounds, embrace it.",
"Believe in the power of your story, it can inspire others.",
"Your journey is unique and valuable, honor it.",
"Take care of your mental health, it's a precious part of who you are.",
"Your strength is a beacon of hope, even on the toughest days.",
"Believe in your ability to create positive change, it starts within you.",
"Your worth is immeasurable, don't let anyone diminish it.",
"Take a step forward, you are not alone in this journey.",
"Your resilience is a testament to your courage, celebrate it.",
"Believe in your ability to overcome obstacles, you are stronger than you think.",
"Your journey is a testament to your strength, acknowledge it.",
"Take time to nurture your well-being, it's a worthy investment.",
"Your mental health matters, prioritize it without guilt.",
"Believe in your capacity for healing, it's within you.",
"Your worth is undeniable, don't let self-doubt overshadow it.",
"Take a moment to appreciate your progress, no matter how small.",
"Your resilience is inspiring, even to those around you.",
"Believe in the power of self-love, it can transform your journey.",
"Your journey is a tapestry of strength and resilience, honor it.",
"Take a deep breath, you are not defined by your struggles.",
"Your mental health is a priority, treat it with care and compassion.",
"Believe in your ability to persevere, you've come so far.",
"Your worth is intrinsic, it cannot be diminished by circumstances.",
"Take a moment to acknowledge your inner strength, it's awe-inspiring.",
"Your resilience is your superpower, embrace it.",
"Believe in the beauty of your journey, it's uniquely yours.",
"Your mental health matters, don't underestimate its importance.",
"Take small steps toward healing, they lead to profound transformations.",
"Your worth is inherent, it doesn't depend on external validation.",
"Take time to rest and recharge, self-care is a vital aspect of resilience.",
"Your journey is a testament to your bravery, honor it.",
"Take pride in your progress, no matter how gradual it may seem.",
"Your mental health is invaluable, prioritize it without hesitation.",
"Take a moment to appreciate your strength, it's a guiding light.",
"Your resilience is boundless, it can overcome any challenge.",
"Take a step towards self-compassion, you deserve kindness and understanding.",
"Your journey is a testament to your courage, celebrate it.",
"Take care of your mental health, it's a precious part of who you are.",
"Take a deep breath, you are stronger than you think.",
"Take time for self-reflection, your inner wisdom is a guiding force.",
"Take a moment to acknowledge your progress, no matter how small.",
"Take pride in your resilience, it's a reflection of your inner strength.",
"Take a step towards self-acceptance, you are enough just as you are.",
"Take care of your mental health, it's a cornerstone of your well-being.",
"Take a deep breath, you have the power to overcome any challenge.",
"Take time for self-compassion, you deserve gentleness and understanding.",
"Take a moment to appreciate your journey, it has shaped your strength.",
"Take pride in your progress, no matter how incremental it may seem.",
"Take care of your mental health, it's a vital aspect of your overall well-being.",
"Take a deep breath, you are capable of resilience and growth.",
"Take time for self-care, it nurtures your mind, body, and soul.",
"Take a moment to acknowledge your strength, it's a beacon of hope.",
"Take pride in your resilience, it's a testament to your courage.",
"Take a step towards self-love, you are deserving of compassion and acceptance.",
"Take care of your mental health, it's a fundamental part of your identity.",
"Take a deep breath, you possess the strength to face any challenge.",
"Take time for self-reflection, your inner wisdom is a source of guidance.",
"Take a moment to appreciate your progress, no matter how small or large.",
"Take pride in your resilience, it illuminates your path towards healing.",
"Take a step towards self-empowerment, you have the ability to shape your destiny.",
"Take care of your mental health, it's the cornerstone of your emotional well-being.",
"Take a deep breath, you are stronger and more resilient than you realize.",
"Take time for self-compassion, it fosters healing and self-discovery.",
"Take a moment to acknowledge your growth, it is a testament to your strength.",
"Take pride in your resilience, it demonstrates the depth of your courage.",
"Take a step towards self-appreciation, recognizing your worth is a transformative journey.",
"Take care of your mental health, it is a precious and valuable aspect of your identity.",
"Take a deep breath, you possess the inner fortitude to navigate life's challenges.",
"Take time for self-love, embracing your true self is a powerful act of healing.",
"Take a moment to celebrate your progress, each step forward is a victory.",
"Take pride in your resilience, it signifies the depth of your bravery.",
"Take a step towards self-acceptance, embracing your uniqueness is a profound gift.",
"Take care of your mental health, it is an essential and integral part of who you are.",
"Take a deep breath, you have the strength to endure and the courage to thrive.",
"Take time for self-reflection, understanding your inner world is a transformative journey.",
"Take a moment to honor your growth, it is a testament to your resilience.",
"Take pride in your journey, it embodies the depth of your courage and tenacity.",
"Take a step towards self-empowerment, your potential is limitless.",
"Take care of your mental health, it is the foundation upon which your well-being rests.",
"Take a deep breath, you possess the inner resilience to overcome any adversity.",
"Take time for self-compassion, it nurtures the soul and fosters healing.",
"Take a moment to acknowledge your progress, every step forward is a triumph.",
"Take pride in your resilience, it is a beacon of light in challenging times.",
"Take a step towards self-love, embracing your authentic self is a transformative act.",
"Take care of your mental health, it is a sanctuary for your emotional well-being.",
"Take a deep breath, you have the strength within you to conquer any obstacle.",
"Take time for self-reflection, understanding your innermost self is a powerful journey.",
"Take a moment to celebrate your growth, it is a testament to your resilience and courage.",
"Take pride in your journey, it reflects the depth of your strength and determination.",
"Take a step towards self-acceptance, embracing your true essence is a liberating experience.",
"Take care of your mental health, it is an invaluable aspect of your overall health and happiness.",
"Take a deep breath, you possess the inner fortitude to face life's challenges with grace and courage.",
"Take time for self-love, it is the foundation upon which a fulfilling and meaningful life is built.",
"Take a moment to acknowledge your progress, no matter how small, it is a testament to your strength and determination.",
"Take pride in your resilience, it is a reflection of your inner strength and the depth of your courage.",
"Take a step towards self-appreciation, recognizing your worth and unique qualities is a transformative and empowering journey.",
"Take care of your mental health, it is a vital and intrinsic part of who you are, deserving of love, care, and nurturing.",

    "You are not alone. Reach out to someone you trust.",
"You are strong. You can overcome this.",
"Every day may not be good, but there's something good in every day.",
"Believe in yourself. You are capable of amazing things.",
"Your strength is greater than any challenge you face.",
"Embrace the glorious mess that you are.",
"You have the power to create change in your life.",
"Stay positive, work hard, make it happen.",
"Your journey matters. Don't give up.",
"Every setback is a setup for a comeback.",
"You are worthy of love and kindness.",
"Your potential is endless. Keep pushing forward.",
"Difficulties in life are intended to make us better, not bitter.",
"Challenges are opportunities in disguise.",
"Let your dreams be bigger than your fears.",
"Positivity is the key to a happy life.",
"You are stronger than you think. Keep going.",
"Believe in your abilities and confidence will lead you on.",
"Life is tough, but so are you.",
"Your mind is a powerful thing. Fill it with positive thoughts.",
"Focus on the good. Life is so much brighter that way.",
"Smile, even if life gives you a thousand reasons to frown.",
"Be yourself; everyone else is already taken.",
"The best way to predict the future is to create it.",
"Believe you can and you're halfway there.",
"In the middle of difficulty lies opportunity.",
"Life is 10% what happens to us and 90% how we react to it.",
"Your attitude determines your direction.",
"Stay positive, stay fighting, stay brave, stay ambitious.",
"Life is short, make it sweet.",
"Your life does not get better by chance, it gets better by change.",
"Create a life you love.",
"The best way out is always through.",
"Believe in your infinite potential.",
"Let your hopes, not your hurts, shape your future.",
"The only way to achieve the impossible is to believe it is possible.",
"The best preparation for tomorrow is doing your best today.",
"Your vibe attracts your tribe.",
"Be the reason someone smiles today.",
"Surround yourself with those who bring out the best in you.",
"Be a voice, not an echo.",
"Your life is your message to the world. Make sure it's inspiring.",
"Make today amazing.",
"You are never too old to set another goal or to dream a new dream.",
"Start where you are. Use what you have. Do what you can.",
"Life is a journey that must be traveled no matter how bad the roads and accommodations.",
"Success is not final, failure is not fatal: It is the courage to continue that counts.",
"The only limit to our realization of tomorrow will be our doubts of today.",
"Turn your wounds into wisdom.",
"You are what you believe yourself to be.",
"Life is really simple, but we insist on making it complicated.",
"Your time is limited, don't waste it living someone else's life.",
"Do not wait for leaders; do it alone, person to person.",
"Do what you can, with what you have, where you are.",
"Life is not about waiting for the storm to pass but learning to dance in the rain.",
"Believe you can and you're halfway there.",
"Every moment is a fresh beginning.",
"Be the change that you wish to see in the world.",
"Success is not in what you have, but who you are.",
"Even the darkest night will end and the sun will rise.",
"The best way to predict your future is to create it.",
"The purpose of our lives is to be happy.",
"The way get started is to quit talking and begin doing.",
"Life is trying things to see if they work.",
"Life is short, and it is up to you to make it sweet.",
"Life is either a daring adventure or nothing at all.",
"In the end, it's not the years in your life that count. It's the life in your years.",
"Life is what happens when you're busy making other plans.",
"Life is what we make it, always has been, always will be.",
"Life is either a great adventure or nothing.",
"Life is ours to be spent, not to be saved.",
"Life is a progress, and not a station.",
"Life is too important to be taken seriously.",
"Life is made of ever so many partings welded together.",
"Life is something to do when you can't get to sleep.",
"Life is something that everyone should try at least once.",
"Life is a tragedy when seen in close-up, but a comedy in long-shot.",
"Life is a zoo in a jungle.",
"Life is really simple, but men insist on making it complicated.",
"Life is a moderately good play with a badly written third act.",
"Life is a long lesson in humility.",
"Life is a journey that must be traveled no matter how bad the roads and accommodations.",
"Life is a game, play it.",
"Life is a song, sing it.",
"Life is a challenge, meet it.",
"Life is a dream, realize it.",
"Life is a sacrifice, offer it.",
"Life is love, enjoy it.",
"Life is life, fight for it."
    // Add more positive messages here
  ];

  String message = "";

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 5),
    );

    _colorAnimation = ColorTween(
      begin: Colors.blue[100],
      end: Colors.teal[100],
    ).animate(_controller);

    _controller.repeat(reverse: true);
    generateRandomMessage();
  }

  void generateRandomMessage() {
    Random random = new Random();
    int index = random.nextInt(positiveMessages.length);
    setState(() {
      message = positiveMessages[index];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Encouraging Messages 🤗'),
        backgroundColor: _colorAnimation.value ?? Colors.blue[700],
      ),
      body: AnimatedBuilder(
        animation: _colorAnimation,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [_colorAnimation.value ?? Colors.blue[200]!, Colors.blue[700]!],
              ),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  AnimatedSwitcher(
                    duration: Duration(milliseconds: 500),
                    child: Text(
                      message,
                      key: ValueKey<String>(message),
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 22, fontFamily: 'Roboto', color: Colors.white),
                    ),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: generateRandomMessage,
                    child: Text('Get Positive Message'),
                  ),
                  SizedBox(height: 20),
                  Image.asset(
                    'assets/images/gifs.gif', // Replace with your actual GIF file path
                    width: double.infinity,
                    height: 150,
                    fit: BoxFit.cover,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
