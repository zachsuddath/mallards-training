-- ============================================================
-- MALLARDS BAR TRACK — QUIZZES + MENU CORRECTIONS
-- Adds quizzes to all 6 Bar modules
-- Also fixes Jambalaya description (now risotto-based, not rice)
-- Run AFTER seed-bar-content.sql
-- Safe to run multiple times — skips if already seeded
-- ============================================================

DO $$
DECLARE
  v_track_id   uuid;
  v_module_id  uuid;
BEGIN

  -- Try both 'title' and 'name' column to handle schema variation
  SELECT id INTO v_track_id FROM tracks WHERE name = 'Bar' LIMIT 1;
  IF v_track_id IS NULL THEN
    SELECT id INTO v_track_id FROM tracks WHERE name = 'Bar' LIMIT 1;
  END IF;
  IF v_track_id IS NULL THEN
    RAISE EXCEPTION 'Bar track not found. Please check that a track named "Bar" exists.';
  END IF;

  -- ── Fix Jambalaya description in Bar Welcome module ──────────
  UPDATE module_items
  SET content = REPLACE(
    content,
    'classic New Orleans-style with chicken, andouille sausage, shrimp, peppers, tomato, and brown rice',
    'classic New Orleans-style with chicken, andouille sausage, shrimp, peppers, and tomato — <strong>NOTE: now made risotto-style</strong>, not traditional rice. Always communicate this to guests who expect traditional jambalaya.'
  )
  WHERE module_id IN (SELECT id FROM modules WHERE track_id = v_track_id)
    AND type = 'info'
    AND content LIKE '%brown rice%';
  RAISE NOTICE 'Jambalaya description updated (risotto-based correction)';

  -- ============================================================
  -- MODULE 1 QUIZ: Welcome to Mallards
  -- ============================================================
  SELECT id INTO v_module_id
    FROM modules WHERE track_id = v_track_id AND title = 'Welcome to Mallards' LIMIT 1;

  IF v_module_id IS NOT NULL AND NOT EXISTS (
    SELECT 1 FROM module_items WHERE module_id = v_module_id AND type = 'quiz'
  ) THEN
    INSERT INTO module_items (module_id, type, title, content, order_index) VALUES (
      v_module_id, 'quiz', 'Welcome to Mallards Quiz',
      '{"questions":[
        {"question":"Mallards is best described as:","options":["A fast casual burger chain","A family-owned Cajun, seafood, and Southern kitchen with multiple MN/WI locations","A fine dining French restaurant","A sports bar with a full menu"],"correctIndex":1},
        {"question":"When a guest asks what Boudin Balls are, you should describe them as:","options":["Deep-fried mozzarella balls","A Cajun sausage ball — savory, slightly spicy, and fried crispy","A seafood fritter with shrimp and crab","A French pastry served with dipping sauce"],"correctIndex":1},
        {"question":"What is the Mallards Jambalaya now made with?","options":["Traditional long-grain white rice","Brown rice","Risotto — guests expecting traditional rice preparation should be informed","Quinoa"],"correctIndex":2},
        {"question":"The Seafood Guac is best described as:","options":["A standard guacamole with chips","Shrimp, crab, and avocado topped with pico de gallo — a Mallards signature starter","A queso dip with crab meat","Avocado hummus served with pita"],"correctIndex":1},
        {"question":"What does \"You own the experience\" mean for a Mallards bartender?","options":["Bartenders set their own drink prices","If something is wrong at your bar, fix it — do not wait to be asked","Bartenders choose their own music and TV channels","Bartenders manage their own tip-out policy"],"correctIndex":1},
        {"question":"Which statement best describes the Espresso Martini?","options":["A fruity, tropical cocktail popular at brunch","A dessert-forward chocolate and caramel martini","Vodka, espresso, and coffee liqueur — rich, smooth, great after dinner","A classic gin-based cocktail with coffee bitters"],"correctIndex":2},
        {"question":"The Hot Chicken & Waffles is described as:","options":["Fried walleye on a corn waffle with tartar sauce","Nashville-style hot chicken on a cornbread waffle with maple syrup and honey butter","Southern fried chicken on Belgian waffles with a cream sauce","Blackened chicken on a buttermilk waffle"],"correctIndex":1}
      ],"pass_threshold":80}',
      1
    );
    RAISE NOTICE 'Added quiz: Welcome to Mallards';
  ELSE
    RAISE NOTICE 'Skipped quiz (exists or module not found): Welcome to Mallards';
  END IF;

  -- ============================================================
  -- MODULE 2 QUIZ: Policies & Standards
  -- ============================================================
  SELECT id INTO v_module_id
    FROM modules WHERE track_id = v_track_id AND title = 'Policies & Standards' LIMIT 1;

  IF v_module_id IS NOT NULL AND NOT EXISTS (
    SELECT 1 FROM module_items WHERE module_id = v_module_id AND type = 'quiz'
  ) THEN
    INSERT INTO module_items (module_id, type, title, content, order_index) VALUES (
      v_module_id, 'quiz', 'Policies & Standards Quiz',
      '{"questions":[
        {"question":"How far in advance should time-off requests be submitted for weekends and holidays?","options":["24 hours","1 week","At least 2 weeks","The day before"],"correctIndex":2},
        {"question":"Automatic gratuity applies to parties of:","options":["4 or more","5 or more","6 or more","8 or more"],"correctIndex":2},
        {"question":"When should you inform a large party about the auto-gratuity policy?","options":["On the receipt at checkout","Before they order — not after","When you bring their food","Only if they ask"],"correctIndex":1},
        {"question":"What is the consequence of clocking in or out for another employee?","options":["A warning on the first offense","It is considered time fraud and grounds for termination","A one-day suspension","Nothing — it is common practice"],"correctIndex":1},
        {"question":"If a guest has a severe food allergy, you should:","options":["Remind them that our gluten-friendly items are safe","Guess based on the menu ingredients","Inform your manager immediately — never guess","Tell them to order something simple"],"correctIndex":2},
        {"question":"How early should you arrive before your scheduled shift?","options":["Right on time","5 minutes early","10 minutes early to review the menu and set up","30 minutes early"],"correctIndex":2}
      ],"pass_threshold":80}',
      1
    );
    RAISE NOTICE 'Added quiz: Policies & Standards';
  ELSE
    RAISE NOTICE 'Skipped quiz (exists or module not found): Policies & Standards';
  END IF;

  -- ============================================================
  -- MODULE 3 QUIZ: Food Safety & Sanitation
  -- ============================================================
  SELECT id INTO v_module_id
    FROM modules WHERE track_id = v_track_id AND title = 'Food Safety & Sanitation' LIMIT 1;

  IF v_module_id IS NOT NULL AND NOT EXISTS (
    SELECT 1 FROM module_items WHERE module_id = v_module_id AND type = 'quiz'
  ) THEN
    INSERT INTO module_items (module_id, type, title, content, order_index) VALUES (
      v_module_id, 'quiz', 'Food Safety & Sanitation Quiz',
      '{"questions":[
        {"question":"What is the food temperature danger zone?","options":["32°F – 100°F","41°F – 135°F","50°F – 140°F","35°F – 125°F"],"correctIndex":1},
        {"question":"How should you get ice from the ice bin?","options":["Use your hands — they are clean","Use any available glass","Always use an ice scoop — never hands or a glass","Ask the barback to do it"],"correctIndex":2},
        {"question":"What happens if a glass breaks in the ice bin?","options":["Fish out the pieces and keep using the ice","Cover it and use from the other side","The entire ice bin must be emptied and sanitized immediately — no exceptions","Report it to the manager and wait for instructions"],"correctIndex":2},
        {"question":"How long should bar garnishes (cut citrus, fresh herbs) be kept before discarding?","options":["One week","3 days","Replace at end of each shift — cut daily, discard nightly","Keep until they look visibly bad"],"correctIndex":2},
        {"question":"Sanitizer buckets behind the bar should be changed every:","options":["30 minutes","1 hour","2 hours","4 hours"],"correctIndex":2},
        {"question":"Why is shellfish allergy awareness especially important at Mallards?","options":["Shellfish is not on the menu, so guests get confused","Shellfish allergies can be severe and life-threatening — we serve high volumes of shrimp, crab, and lobster","Shellfish is only dangerous when raw","Shellfish reactions are mild and manageable"],"correctIndex":1},
        {"question":"How long must you wash your hands with soap and warm water?","options":["5 seconds","10 seconds","At least 20 seconds","30 seconds"],"correctIndex":2}
      ],"pass_threshold":80}',
      1
    );
    RAISE NOTICE 'Added quiz: Food Safety & Sanitation';
  ELSE
    RAISE NOTICE 'Skipped quiz (exists or module not found): Food Safety & Sanitation';
  END IF;

  -- ============================================================
  -- MODULE 4 QUIZ: Bar Setup & Spirits Knowledge
  -- ============================================================
  SELECT id INTO v_module_id
    FROM modules WHERE track_id = v_track_id AND title = 'Bar Setup & Spirits Knowledge' LIMIT 1;

  IF v_module_id IS NOT NULL AND NOT EXISTS (
    SELECT 1 FROM module_items WHERE module_id = v_module_id AND type = 'quiz'
  ) THEN
    INSERT INTO module_items (module_id, type, title, content, order_index) VALUES (
      v_module_id, 'quiz', 'Bar Setup & Spirits Knowledge Quiz',
      '{"questions":[
        {"question":"What is the key difference between Blanco and Añejo tequila?","options":["Blanco is aged longer and sipped like whiskey; Añejo is for margaritas","Blanco is bright and clean (great for margaritas); Añejo is aged and sipped like fine whiskey","Blanco is made from agave nectar; Añejo is made from corn","They are the same — just different marketing terms"],"correctIndex":1},
        {"question":"Bourbon must be made from at least what percentage of corn?","options":["25%","51%","75%","100%"],"correctIndex":1},
        {"question":"Which cocktail is described as \"dessert in a glass\" with chocolate and caramel notes?","options":["Espresso Martini","Bloody Mary","Dubai Chocolate Martini","Bottomless Mimosa"],"correctIndex":2},
        {"question":"What food pairing works best with the Captain''s Ribeye or Steak Alfredo?","options":["A fruity rosé","A bold red wine like Cabernet Sauvignon or Malbec","A light lager","A sweet cocktail like a margarita"],"correctIndex":1},
        {"question":"Before service starts, juices and mixes should be:","options":["Poured into speed pourers and left out","Smelled and tasted to confirm freshness — expired juice ruins a cocktail","Checked only at closing","Replaced only if a guest complains"],"correctIndex":1},
        {"question":"What is the Cajun Cream Sauce best described as?","options":["Light, herbal, and citrusy","Rich, creamy, and moderately spicy — a Mallards classic","Smoky and sweet with mild heat","A sweet BBQ-style sauce"],"correctIndex":1},
        {"question":"Which sauce option would you recommend to a guest who wants bold flavor but no cream?","options":["Cajun Cream Sauce","Hollandaise","Cajun Dry Rub","Sweet Chipotle"],"correctIndex":2},
        {"question":"What is the Nashville Hot sauce known for?","options":["Mild smoky sweetness","Sweet tanginess with a hint of spice","Serious heat — always warn guests who are not accustomed to it","A buttery, rich flavor with moderate heat"],"correctIndex":2}
      ],"pass_threshold":80}',
      1
    );
    RAISE NOTICE 'Added quiz: Bar Setup & Spirits Knowledge';
  ELSE
    RAISE NOTICE 'Skipped quiz (exists or module not found): Bar Setup & Spirits Knowledge';
  END IF;

  -- ============================================================
  -- MODULE 5 QUIZ: Responsible Alcohol Service
  -- ============================================================
  SELECT id INTO v_module_id
    FROM modules WHERE track_id = v_track_id AND title = 'Responsible Alcohol Service' LIMIT 1;

  IF v_module_id IS NOT NULL AND NOT EXISTS (
    SELECT 1 FROM module_items WHERE module_id = v_module_id AND type = 'quiz'
  ) THEN
    INSERT INTO module_items (module_id, type, title, content, order_index) VALUES (
      v_module_id, 'quiz', 'Responsible Alcohol Service Quiz',
      '{"questions":[
        {"question":"What is last call time in Minnesota?","options":["1:30 AM","2:00 AM — all alcohol must be off tables by 2:30 AM","12:00 AM on weekdays","1:00 AM"],"correctIndex":1},
        {"question":"Which forms of ID are valid at Mallards? (Best answer)","options":["Any government-issued ID, even expired","State driver''s license or ID, U.S. passport, military ID, or tribal ID — must be current/unexpired","Student IDs are acceptable if they have a photo","Any ID with a photo is fine"],"correctIndex":1},
        {"question":"What are the three things to check on every ID?","options":["Name, address, and expiration date","Photo matches the person, DOB confirms they are 21+, and ID is not expired","Photo, signature, and home state","Hair color, eye color, and height"],"correctIndex":1},
        {"question":"Under Minnesota Dram Shop law, who can be held personally liable for over-serving?","options":["Only the restaurant owner","Only the manager on duty","The individual server or bartender who over-served","No one — liability ends at the establishment"],"correctIndex":2},
        {"question":"Which of these is a sign of intoxication to watch for?","options":["Ordering a second drink","Asking for the dessert menu","Slurred speech, loss of coordination, or sudden mood change","Sitting at the bar for more than 2 hours"],"correctIndex":2},
        {"question":"When cutting someone off, you should:","options":["Announce it loudly so other staff are aware","Be calm and private — step closer and use \"I\" statements, then alert your manager","Send a text to the manager and let them handle it","Cut off the entire group to be safe"],"correctIndex":1},
        {"question":"What should you do immediately after cutting a guest off, even if it went smoothly?","options":["Nothing — the situation is resolved","Tell the guest to leave immediately","Alert your manager","Call a rideshare for them"],"correctIndex":2},
        {"question":"When is it ever acceptable to not check an ID?","options":["When you are very busy and the guest looks obviously over 30","When the guest gets offended","When you have served them before","Never — when in doubt, card"],"correctIndex":3}
      ],"pass_threshold":80}',
      1
    );
    RAISE NOTICE 'Added quiz: Responsible Alcohol Service';
  ELSE
    RAISE NOTICE 'Skipped quiz (exists or module not found): Responsible Alcohol Service';
  END IF;

  -- ============================================================
  -- MODULE 6 QUIZ: Final Sign-Off
  -- ============================================================
  SELECT id INTO v_module_id
    FROM modules WHERE track_id = v_track_id AND title = 'Final Sign-Off' LIMIT 1;

  IF v_module_id IS NOT NULL AND NOT EXISTS (
    SELECT 1 FROM module_items WHERE module_id = v_module_id AND type = 'quiz'
  ) THEN
    INSERT INTO module_items (module_id, type, title, content, order_index) VALUES (
      v_module_id, 'quiz', 'Bar Certification Final Quiz',
      '{"questions":[
        {"question":"What are the three requirements to complete Bar certification at Mallards?","options":["Written quiz, a menu tasting, and a manager interview","Bar knowledge quiz, an observed shift, and Employee Handbook acknowledgment","A knowledge quiz only — the rest is on-the-job learning","Online training, a written quiz, and a final exam with the GM"],"correctIndex":1},
        {"question":"A guest passes on dessert. What can you suggest as an alternative upsell?","options":["A second entrée","The Espresso Martini — \"It''s basically dessert in a glass\"","A complimentary coffee","The Dubai Chocolate Martini","The Espresso Martini or Dubai Chocolate Martini — both are dessert-forward cocktails"],"correctIndex":4},
        {"question":"What is the correct way to serve a bottle of wine tableside?","options":["Open and pour immediately","Present the bottle, then pour a small taste for the ordering guest to approve","Pour a full glass for everyone first","Ask the guest if they want to taste before presenting"],"correctIndex":1},
        {"question":"Which Mallards item is described as \"almost a meal\" when sold as a brunch drink?","options":["Bottomless Mimosas","Dubai Chocolate Martini","Bloody Mary — bold, savory, and garnished generously","Espresso Martini"],"correctIndex":2},
        {"question":"After your certification, menu knowledge becomes:","options":["No longer your responsibility — you passed","Fixed — the menu never changes","An ongoing responsibility — seasonal specials and rollouts require constant learning","Optional — guests do not expect bartenders to know food"],"correctIndex":2},
        {"question":"What should happen during your observed certification shift?","options":["Work perfectly with no questions — show you know everything","Ask no questions to appear confident","Demonstrate your knowledge, handle the shift professionally, and ask questions when needed","Work a slow shift so there is less pressure"],"correctIndex":2}
      ],"pass_threshold":80}',
      1
    );
    RAISE NOTICE 'Added quiz: Final Sign-Off';
  ELSE
    RAISE NOTICE 'Skipped quiz (exists or module not found): Final Sign-Off';
  END IF;

  RAISE NOTICE 'Bar quizzes and menu corrections applied successfully.';
END $$;
