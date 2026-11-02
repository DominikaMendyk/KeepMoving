import '../models/stretch.dart';

const List<Stretch> stretchLibrary = [
  // Quick ones: suitable for any session, even 25 minutes.
  Stretch(
    name: 'Neck side tilt',
    instruction:
        'Drop your right ear toward your right shoulder. Hold, then switch sides.',
    seconds: 20,
    area: BodyArea.neck,
  ),
  Stretch(
    name: 'Chin tucks',
    instruction:
        'Pull your chin straight back, as if making a double chin. Release and repeat.',
    seconds: 15,
    area: BodyArea.neck,
  ),
  Stretch(
    name: 'Shoulder rolls',
    instruction: 'Roll both shoulders up, back and down in big slow circles.',
    seconds: 20,
    area: BodyArea.shoulders,
  ),
  Stretch(
    name: 'Cross-body shoulder stretch',
    instruction:
        'Pull one arm across your chest with the other hand. Hold, then switch.',
    seconds: 20,
    area: BodyArea.shoulders,
  ),
  Stretch(
    name: 'Wrist flexor stretch',
    instruction:
        'Extend an arm palm-up and gently pull your fingers back. Switch hands.',
    seconds: 20,
    area: BodyArea.wrists,
  ),
  Stretch(
    name: 'Wrist circles',
    instruction: 'Make loose fists and circle both wrists in each direction.',
    seconds: 15,
    area: BodyArea.wrists,
  ),
  Stretch(
    name: '20-20-20 eye break',
    instruction: 'Look at something about 6 metres away and let your eyes relax.',
    seconds: 20,
    area: BodyArea.eyes,
  ),

  // Medium sessions (30+ min): add the back.
  Stretch(
    name: 'Seated spinal twist',
    instruction:
        'Sit tall, place a hand on the opposite knee and twist gently. Switch sides.',
    seconds: 30,
    area: BodyArea.back,
    minSessionMinutes: 30,
  ),
  Stretch(
    name: 'Seated cat-cow',
    instruction:
        'Hands on knees. Arch your back and look up, then round it and look down.',
    seconds: 30,
    area: BodyArea.back,
    minSessionMinutes: 30,
  ),
  Stretch(
    name: 'Standing back extension',
    instruction:
        'Stand, hands on your lower back, and lean back slightly. Breathe.',
    seconds: 20,
    area: BodyArea.back,
    minSessionMinutes: 30,
  ),

  // Long sessions (60+ min): hips, legs and chest.
  Stretch(
    name: 'Seated figure-four',
    instruction:
        'Rest one ankle on the opposite knee and lean forward slightly. Switch legs.',
    seconds: 30,
    area: BodyArea.hips,
    minSessionMinutes: 60,
  ),
  Stretch(
    name: 'Standing hip flexor stretch',
    instruction: 'Step one foot back into a lunge and tuck your pelvis. Switch legs.',
    seconds: 30,
    area: BodyArea.hips,
    minSessionMinutes: 60,
  ),
  Stretch(
    name: 'Standing quad stretch',
    instruction: 'Hold one ankle behind you, knees together. Switch legs.',
    seconds: 30,
    area: BodyArea.legs,
    minSessionMinutes: 60,
  ),
  Stretch(
    name: 'Doorway chest stretch',
    instruction:
        'Forearms on a door frame, step through until you feel your chest open.',
    seconds: 30,
    area: BodyArea.shoulders,
    minSessionMinutes: 60,
  ),

  // Very long sessions (90+ min): get up and move.
  Stretch(
    name: 'Forward fold',
    instruction:
        'Stand, hinge at the hips and let your arms hang. Bend your knees if needed.',
    seconds: 30,
    area: BodyArea.legs,
    minSessionMinutes: 90,
  ),
  Stretch(
    name: 'Walk it off',
    instruction: 'Stand up and walk around for two minutes. Climb a few stairs if you can.',
    seconds: 120,
    area: BodyArea.fullBody,
    minSessionMinutes: 90,
  ),
];
