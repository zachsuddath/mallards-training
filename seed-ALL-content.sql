-- ============================================================
-- MALLARDS TRAINING APP — COMPLETE CONTENT SEED
-- Run this ONE file in Supabase > SQL Editor > New Query
-- Includes: Bar, FOH Server, Kitchen/BOH, Host tracks
-- Safe to re-run — uses WHERE NOT EXISTS throughout
-- ============================================================

-- ============================================================
-- STEP 0: ADD 'quiz' TO module_items TYPE CONSTRAINT
-- (original schema only allows video/checklist/info)
-- ============================================================
ALTER TABLE module_items DROP CONSTRAINT IF EXISTS module_items_type_check;
ALTER TABLE module_items ADD CONSTRAINT module_items_type_check
  CHECK (type IN ('video', 'checklist', 'info', 'quiz'));

-- SECTION 1: BAR TRACK
-- ============================================================
-- MALLARDS BAR TRACK — TRAINING CONTENT SEED (v2 — Menu Edition)
-- Paste this entire file into Supabase > SQL Editor > New Query
-- and click Run. Adds info blocks to all 6 Bar modules.
-- Safe to run multiple times — skips modules already seeded.
-- ============================================================

DO $$
DECLARE
  v_track_id uuid;
  v_module_id uuid;
BEGIN

  SELECT id INTO v_track_id FROM tracks WHERE name = 'Bar' LIMIT 1;
  IF v_track_id IS NULL THEN
    RAISE EXCEPTION 'Bar track not found';
  END IF;

  -- ──────────────────────────────────────────────
  -- MODULE 1: Welcome to Mallards
  -- ──────────────────────────────────────────────
  SELECT id INTO v_module_id
    FROM modules WHERE track_id = v_track_id AND title = 'Welcome to Mallards' LIMIT 1;

  IF v_module_id IS NOT NULL AND NOT EXISTS (
    SELECT 1 FROM module_items WHERE module_id = v_module_id AND type = 'info'
  ) THEN
    INSERT INTO module_items (module_id, type, title, content, order_index) VALUES (
      v_module_id, 'info', 'About Mallards',
      '<h2>Who We Are</h2>
<p>Mallards is a family-owned Cajun, seafood, and Southern kitchen with 5 locations across Minnesota and Wisconsin — Bloomington, Forest Lake, Glendale (Bayshore Mall), Inver Grove Heights, and Shakopee. We are not a chain. Every location is run by people who genuinely care about the food, the guests, and each other.</p>

<h2>What We Are Known For</h2>
<p>Our menu is rooted in bold Cajun and Southern flavors with fresh Gulf-style seafood at the center. A few things guests come back for again and again:</p>
<ul>
<li><strong>Boudin Balls</strong> — crispy fried boudin with Cajun spice and a dipping sauce. One of our most ordered starters. If a guest has never had boudin, tell them it''s a savory Cajun sausage ball — rich, slightly spicy, and impossible to stop eating.</li>
<li><strong>Seafood "Guac"</strong> — shrimp, crab, and avocado topped with pico de gallo, served with tortilla chips. A Mallards signature starter.</li>
<li><strong>Elote Corn Fritters</strong> — crispy corn fritters topped with avocado lime crema. Vegetarian and a great upsell for tables looking for something lighter.</li>
<li><strong>Jambalaya</strong> — classic New Orleans-style with chicken, andouille sausage, shrimp, peppers, tomato, and brown rice. Rich, smoky, and deeply Cajun.</li>
<li><strong>Shrimp & Grits</strong> — blackened Gulf shrimp over stone-ground grits with Cajun cream sauce. One of the most iconic Southern dishes on the menu.</li>
<li><strong>Hot Chicken & Waffles</strong> — Nashville-style hot chicken on a cornbread waffle with maple syrup and honey butter. A guest favorite, especially at brunch.</li>
<li><strong>Shrimp Boil</strong> — half or full pound of Gulf shrimp served corn-on-the-cob and andouille sausage, with your choice of sauce.</li>
<li><strong>Fish House</strong> — our Thursday night special: Crab Legs at 29.99/39.99. One of the biggest traffic drivers of the week.</li>
</ul>

<h2>The Mallards Way</h2>
<p>Southern hospitality is not a buzzword here — it is the standard. It means:</p>
<ul>
<li><strong>Guests feel seen.</strong> Acknowledge everyone within 30 seconds of sitting down, even if you are busy.</li>
<li><strong>You own the experience.</strong> If something is wrong at your bar, fix it. Do not wait to be asked.</li>
<li><strong>Every shift matters.</strong> A guest''s first visit determines whether they come back. Every seat could be someone''s first time.</li>
<li><strong>Family runs deep.</strong> Your teammates are your team. Look out for each other.</li>
</ul>

<h2>Your Role Behind the Bar</h2>
<p>As a Mallards bartender, you run full food and beverage service for every guest at your bar. You need to know the menu as well as any server — guests ask questions, and the answer "I''m just the bartender" is not one we give here.</p>',
      0
    );
    RAISE NOTICE 'Added content: Welcome to Mallards';
  ELSE
    RAISE NOTICE 'Skipped: Welcome to Mallards';
  END IF;


  -- ──────────────────────────────────────────────
  -- MODULE 2: Policies & Standards
  -- ──────────────────────────────────────────────
  SELECT id INTO v_module_id
    FROM modules WHERE track_id = v_track_id AND title = 'Policies & Standards' LIMIT 1;

  IF v_module_id IS NOT NULL AND NOT EXISTS (
    SELECT 1 FROM module_items WHERE module_id = v_module_id AND type = 'info'
  ) THEN
    INSERT INTO module_items (module_id, type, title, content, order_index) VALUES (
      v_module_id, 'info', 'Policies & Standards Overview',
      '<h2>Uniform Standards</h2>
<p>Your uniform is a direct reflection of Mallards. Come to every shift in a clean, wrinkle-free uniform. Your name tag must be visible. Hair should be neat and pulled back behind the bar. Closed-toe, non-slip shoes are required — spills happen.</p>
<ul>
<li>No strong perfume or cologne — guests are eating</li>
<li>No visible undergarments</li>
<li>Nails must be clean and kept short behind the bar</li>
</ul>

<h2>Clocking In and Out</h2>
<p>You must clock in <strong>before</strong> you start any work and clock out <strong>immediately</strong> after your shift ends. Do not clock in early without manager approval. Do not clock out for another employee — this is considered time fraud and is grounds for termination.</p>

<h2>Requesting Time Off</h2>
<p>Submit time-off requests to your manager at least <strong>two weeks in advance</strong> for weekends and holidays. Last-minute requests during peak periods (holidays, events, Lobster Mania, State Fair season) will not be guaranteed. It is your responsibility to find coverage if a time-off request is denied due to scheduling needs.</p>

<h2>Attendance and Punctuality</h2>
<p>Arrive <strong>10 minutes before your scheduled shift</strong> to review the menu, any specials, and get your bar set up. Three unexcused absences or late arrivals in a 90-day period is grounds for disciplinary action. If you cannot make your shift, call your manager directly — do not just send a text.</p>

<h2>Automatic Gratuity Policy</h2>
<p>An <strong>automatic gratuity is added for parties of 6 or more</strong>. It is your responsibility to inform large parties of this policy before they order. Do not wait until the check — that conversation is much harder after the meal.</p>

<h2>Gluten-Friendly & Dietary Awareness</h2>
<p>Many items on our menu are marked Gluten-Friendly (GF) or Vegetarian (V). These items may be served undercooked. Always remind guests that gluten-friendly items do not guarantee the absence of cross-contamination. If a guest has a severe allergy, inform your manager immediately — do not guess.</p>

<h2>Harassment and Respect</h2>
<p>Mallards maintains a zero-tolerance policy for harassment of any kind — from staff to staff, or guest to staff. This includes verbal, physical, and sexual harassment. If you experience or witness harassment, report it to your manager or to ownership immediately.</p>',
      0
    );
    RAISE NOTICE 'Added content: Policies & Standards';
  ELSE
    RAISE NOTICE 'Skipped: Policies & Standards';
  END IF;


  -- ──────────────────────────────────────────────
  -- MODULE 3: Food Safety & Sanitation
  -- ──────────────────────────────────────────────
  SELECT id INTO v_module_id
    FROM modules WHERE track_id = v_track_id AND title = 'Food Safety & Sanitation' LIMIT 1;

  IF v_module_id IS NOT NULL AND NOT EXISTS (
    SELECT 1 FROM module_items WHERE module_id = v_module_id AND type = 'info'
  ) THEN
    INSERT INTO module_items (module_id, type, title, content, order_index) VALUES (
      v_module_id, 'info', 'Food Safety & Sanitation Guide',
      '<h2>Handwashing — The Non-Negotiable</h2>
<p>Wash your hands for at least <strong>20 seconds</strong> with soap and warm water — about as long as it takes to sing Happy Birthday twice. You must wash your hands:</p>
<ul>
<li>When you arrive for your shift</li>
<li>After touching your face, hair, or phone</li>
<li>After handling cash</li>
<li>After taking out trash or touching any waste</li>
<li>After handling raw food, seafood, or garnishes</li>
<li>After using the restroom</li>
<li>After handling chemicals or cleaning products</li>
<li>Any time you switch tasks</li>
</ul>

<h2>The Temperature Danger Zone</h2>
<p>Bacteria multiply rapidly between <strong>41°F and 135°F</strong>. Any perishable item left in this range for more than <strong>4 hours total</strong> must be discarded. Behind the bar, this applies to:</p>
<ul>
<li>Fresh citrus (lemons, limes, oranges) — cut daily, discard after 24 hours</li>
<li>Fresh herbs (mint, basil) — keep refrigerated, replace daily</li>
<li>Berries and fruit garnishes — replace every shift</li>
<li>House-made syrups and mixes — check dates, store cold</li>
<li>Lobster quiche, shrimp, or any protein served at the bar — follow kitchen dates strictly</li>
</ul>

<h2>Bar-Specific Sanitation Rules</h2>
<ul>
<li><strong>Ice:</strong> Always use an ice scoop — never your hands or a glass. A broken glass in the ice bin means the entire bin must be emptied and sanitized immediately. No exceptions.</li>
<li><strong>Garnishes:</strong> Cut fresh each shift. Date-label everything. Discard at end of night.</li>
<li><strong>Sanitizer buckets:</strong> Mix correctly per your manager''s instruction and change every 2 hours. Use clean bar towels from the bucket — never dry wipe a surface.</li>
<li><strong>Cutting boards:</strong> Color-coded for a reason. The fruit board is for fruit only — never use it for anything else.</li>
<li><strong>Glassware:</strong> Inspect every glass before you pour. Crack, chip, or lipstick means it goes in the dish pit immediately — not back on the shelf.</li>
</ul>

<h2>Seafood Awareness</h2>
<p>We serve a significant volume of shellfish — shrimp, crab, lobster, crawfish. Shellfish allergies can be severe and life-threatening. If a guest mentions a seafood allergy, alert your manager and the kitchen before ordering anything. Never assume a dish is safe — confirm with the kitchen.</p>

<h2>When to Tell a Manager Immediately</h2>
<p>If you feel sick — especially with vomiting, diarrhea, or fever — you cannot work with food. Tell your manager before your shift, not during it. This protects your guests and your coworkers.</p>',
      0
    );
    RAISE NOTICE 'Added content: Food Safety & Sanitation';
  ELSE
    RAISE NOTICE 'Skipped: Food Safety & Sanitation';
  END IF;


  -- ──────────────────────────────────────────────
  -- MODULE 4: Bar Setup & Spirits Knowledge
  -- ──────────────────────────────────────────────
  SELECT id INTO v_module_id
    FROM modules WHERE track_id = v_track_id AND title = 'Bar Setup & Spirits Knowledge' LIMIT 1;

  IF v_module_id IS NOT NULL AND NOT EXISTS (
    SELECT 1 FROM module_items WHERE module_id = v_module_id AND type = 'info'
  ) THEN
    INSERT INTO module_items (module_id, type, title, content, order_index) VALUES (
      v_module_id, 'info', 'Bar Setup & Spirits Knowledge Guide',
      '<h2>Opening the Bar</h2>
<p>A well-set bar runs itself. Before a single guest sits down:</p>
<ul>
<li>Ice wells filled</li>
<li>Garnish trays cut and refrigerated — citrus wheels, lemon/lime wedges, fresh herbs, olives</li>
<li>Speed rail stocked and organized</li>
<li>Draft lines purged and tested</li>
<li>Juices and mixes checked for freshness — smell and taste them. Expired juice ruins a cocktail and wastes a pour.</li>
<li>Back bar bottles faced forward and dusted</li>
<li>Glassware polished and staged by type</li>
<li>POS tested</li>
<li>Sanitizer buckets mixed</li>
</ul>

<h2>Mallards Signature Cocktails</h2>
<p>Know these inside and out — what is in them, how to build them, and how to describe them to a guest:</p>
<ul>
<li><strong>Bloody Mary (8.99)</strong> — Our Bloody Mary is bold and savory with a Cajun kick. House-made mix, garnished generously. A brunch staple. When guests ask, describe it as "spicy, savory, and substantial — almost a meal."</li>
<li><strong>Bottomless Mimosa (14.99)</strong> — Available at brunch. Sparkling wine and fresh OJ, unlimited refills. Know your brunch hours and always confirm with your manager before offering bottomless.</li>
<li><strong>Espresso Martini (11)</strong> — Vodka, espresso, coffee liqueur. Rich, smooth, slightly sweet. Popular after dinner or as a dessert cocktail. Great upsell when a guest passes on dessert: "Can I make you an Espresso Martini instead?"</li>
<li><strong>Dubai Chocolate Martini (13)</strong> — Decadent and dessert-forward. Chocolate and caramel notes. One of our most Instagrammable drinks — if it looks good coming out of your shaker, make it look even better in the glass.</li>
</ul>

<h2>The Core Spirits — How to Talk About Them</h2>
<ul>
<li><strong>Vodka:</strong> Neutral and clean — the base of most well drinks. The more times it''s filtered, the smoother it is. Pairs with almost everything.</li>
<li><strong>Whiskey:</strong> Bourbon is American, sweet with vanilla and caramel notes — made from at least 51% corn, aged in new charred oak. Scotch is smoky. Tennessee whiskey is charcoal-filtered. Irish is smooth and easy-drinking.</li>
<li><strong>Tequila:</strong> Made from blue agave. Blanco is bright and clean — great for margaritas. Reposado is aged and more complex. Añejo is sipped like a fine whiskey. Always look for "100% agave."</li>
<li><strong>Rum:</strong> White rum is light — base for daiquiris and mojitos. Dark rum has molasses and caramel depth. Spiced rum has added vanilla and cinnamon.</li>
<li><strong>Gin:</strong> Neutral spirit flavored with botanicals — juniper is the signature. Crisp, herbal, aromatic. Great in G&amp;Ts and martinis.</li>
</ul>

<h2>Food & Drink Pairing at the Bar</h2>
<p>When a bar guest is deciding what to drink with their food, you can guide them:</p>
<ul>
<li><strong>Jambalaya or Shrimp & Grits:</strong> A cold lager, crisp white wine (Pinot Grigio), or a light cocktail. Avoid anything too sweet — it fights the Cajun spice.</li>
<li><strong>Hot Chicken & Waffles:</strong> A refreshing cocktail with citrus — like a mule or a sour — cuts through the heat and sweetness perfectly.</li>
<li><strong>Boudin Balls or Seafood "Guac":</strong> Great with a margarita, a Bloody Mary, or a cold draft beer.</li>
<li><strong>Shrimp Boil:</strong> Cold beer is the classic call. A crisp Sauvignon Blanc also works well.</li>
<li><strong>Steak Alfredo or Captain''s Ribeye:</strong> A bold red — Cabernet Sauvignon or Malbec.</li>
<li><strong>Fish & Chips or Fried Walleye:</strong> Crisp lager, pale ale, or a dry white wine.</li>
</ul>

<h2>Sauce Knowledge — Know What You Are Selling</h2>
<p>Many dishes involve a sauce choice. Know what each one tastes like so you can help guests decide:</p>
<ul>
<li><strong>Cajun Cream Sauce</strong> — Rich, creamy, moderately spicy. A Mallards classic.</li>
<li><strong>Spicy Nola</strong> — Bolder heat, New Orleans-inspired. For guests who want more kick.</li>
<li><strong>Korean BBQ</strong> — Sweet, savory, slightly tangy with soy and sesame notes.</li>
<li><strong>Cajun Dry Rub</strong> — No sauce, just bold seasoning — for guests who want the flavor without the cream.</li>
<li><strong>Buffalo</strong> — Classic, vinegary heat. Familiar to most guests.</li>
<li><strong>Sweet Chipotle</strong> — Smoky and sweet with mild heat. Great for guests who are spice-shy.</li>
<li><strong>Nashville Hot</strong> — Serious heat. Warn guests who are not accustomed to it.</li>
<li><strong>Cajun Dry Rub / Soy-Sesame Ginger / Lemon Butter / Pineapple Mango Salsa / Hollandaise</strong> — Shrimp boil sauce options. Hollandaise is rich and buttery; Pineapple Mango is sweet and tropical — good for guests who want something lighter.</li>
</ul>',
      0
    );
    RAISE NOTICE 'Added content: Bar Setup & Spirits Knowledge';
  ELSE
    RAISE NOTICE 'Skipped: Bar Setup & Spirits Knowledge';
  END IF;


  -- ──────────────────────────────────────────────
  -- MODULE 5: Responsible Alcohol Service
  -- ──────────────────────────────────────────────
  SELECT id INTO v_module_id
    FROM modules WHERE track_id = v_track_id AND title = 'Responsible Alcohol Service' LIMIT 1;

  IF v_module_id IS NOT NULL AND NOT EXISTS (
    SELECT 1 FROM module_items WHERE module_id = v_module_id AND type = 'info'
  ) THEN
    INSERT INTO module_items (module_id, type, title, content, order_index) VALUES (
      v_module_id, 'info', 'Responsible Alcohol Service Guide',
      '<h2>Minnesota Law — What You Must Know</h2>
<ul>
<li>The legal drinking age is <strong>21</strong>. No exceptions, no judgment calls.</li>
<li>Last call in Minnesota is <strong>2:00 AM</strong>. Alcohol service must stop at 2:00 AM and all drinks must be off tables by 2:30 AM.</li>
<li>It is illegal to serve alcohol to a person who is <strong>visibly intoxicated</strong>. This applies even if they were served elsewhere first.</li>
<li>Under Minnesota Dram Shop law, you — the individual server — can be held <strong>personally liable</strong> if you serve someone who then injures themselves or another person.</li>
</ul>

<h2>Checking IDs</h2>
<p>Card anyone who looks under 35. No exceptions. Valid forms of ID:</p>
<ul>
<li>State-issued driver''s license or ID card</li>
<li>U.S. Passport or Passport Card</li>
<li>Military ID</li>
<li>Tribal ID</li>
</ul>
<p>Check three things every time: <strong>(1) the photo matches the person in front of you, (2) the date of birth confirms they are 21 or older, and (3) the ID is not expired.</strong> An expired ID is not a valid ID — do not serve. If anything feels off, ask a manager immediately.</p>

<h2>Recognizing Intoxication</h2>
<p>Watch for these signs — you do not need to be certain to slow down service:</p>
<ul>
<li>Slurred or slow speech</li>
<li>Loss of coordination — stumbling, swaying, knocking things over</li>
<li>Glassy or bloodshot eyes</li>
<li>Sudden mood change — becoming loud, aggressive, or overly emotional</li>
<li>Difficulty following a conversation or placing an order</li>
<li>Ordering rounds of shots or doubles in quick succession</li>
</ul>
<p>Trust your instincts. If something feels off, it probably is.</p>

<h2>How to Cut Someone Off — The Right Way</h2>
<p>Cutting someone off does not have to be confrontational. Here''s how to handle it:</p>
<ul>
<li>Be calm, direct, and private. Step closer — do not announce it across the bar.</li>
<li>Use "I" statements: <em>"I''m not going to be able to serve you any more alcohol tonight."</em></li>
<li>Offer alternatives: water, coffee, food. Our food is substantial — something like the Jambalaya or Smash Burger can slow things down significantly.</li>
<li>If they push back, involve your manager. That''s what managers are there for.</li>
<li>If a guest is driving, ask if there is someone you can call. You are allowed to offer to call a rideshare on their behalf.</li>
<li><strong>Always tell your manager</strong> after cutting someone off — even if it went smoothly.</li>
</ul>

<h2>Mallards Policy</h2>
<p>When in doubt, do not serve. No tip is worth your liquor license, your job, or someone''s life. Management will always back you up on a responsible cut-off call. What management will not back you up on is serving someone who should not have been served.</p>',
      0
    );
    RAISE NOTICE 'Added content: Responsible Alcohol Service';
  ELSE
    RAISE NOTICE 'Skipped: Responsible Alcohol Service';
  END IF;


  -- ──────────────────────────────────────────────
  -- MODULE 6: Final Sign-Off
  -- ──────────────────────────────────────────────
  SELECT id INTO v_module_id
    FROM modules WHERE track_id = v_track_id AND title = 'Final Sign-Off' LIMIT 1;

  IF v_module_id IS NOT NULL AND NOT EXISTS (
    SELECT 1 FROM module_items WHERE module_id = v_module_id AND type = 'info'
  ) THEN
    INSERT INTO module_items (module_id, type, title, content, order_index) VALUES (
      v_module_id, 'info', 'Final Sign-Off — What to Expect',
      '<h2>You Are Almost There</h2>
<p>This final module is about demonstrating everything you have learned — not just knowing it, but being able to do it in a real environment. There are three requirements to complete your Bar certification:</p>

<h2>1. The Bar Knowledge Quiz</h2>
<p>You will take a quiz with a manager covering:</p>
<ul>
<li>Core spirits — categories, descriptions, and how to talk about them with guests</li>
<li>Mallards signature cocktails — Bloody Mary, Espresso Martini, Dubai Chocolate Martini, Bottomless Mimosa</li>
<li>Sauce knowledge — all sauce options and how to describe them</li>
<li>Menu highlights — signature dishes, what''s in them, how to describe and sell them</li>
<li>Responsible alcohol service — MN law, ID checking, signs of intoxication, how to cut off a guest</li>
<li>Food safety — handwashing, temperature danger zone, bar garnish and seafood handling</li>
<li>Policies — uniform, attendance, auto-gratuity, allergy communication</li>
</ul>
<p>Review all previous modules before your quiz. A passing score is required. If you do not pass, your manager will review the material with you and schedule a retake within one week.</p>

<h2>2. Observed Shift</h2>
<p>A manager will observe you working a real shift behind the bar. They are watching for:</p>
<ul>
<li>Proper bar setup and opening procedures</li>
<li>Speed and accuracy on cocktail builds</li>
<li>Guest interaction and hospitality — especially how you describe food and drinks</li>
<li>Safe alcohol service practices in real time</li>
<li>Sanitation habits throughout the shift</li>
<li>Teamwork with FOH staff</li>
</ul>
<p>This is not a test designed to trip you up — it is a chance to show what you know. Ask questions during the shift if you need to.</p>

<h2>3. Employee Handbook Acknowledgment</h2>
<p>You will sign a form confirming you have read and understood the Mallards Employee Handbook. Keep a copy. Know what is in it.</p>

<h2>Once You Are Certified</h2>
<p>You are a fully certified Mallards bartender. Stay curious, keep learning the menu as it changes with seasonal rollouts and rotating specials, and take ownership of every shift you work. The bar is yours — run it like it.</p>',
      0
    );
    RAISE NOTICE 'Added content: Final Sign-Off';
  ELSE
    RAISE NOTICE 'Skipped: Final Sign-Off';
  END IF;

END $$;

-- SECTION 2: BAR QUIZZES & FIXES
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

-- SECTION 3: FOH SERVER TRACK
-- ============================================================
-- MALLARDS TRAINING APP — FOH SERVER TRACK CONTENT
-- Study Guides + Quizzes — based on Food Class Training 2026
-- Run in Supabase > SQL Editor > New Query
-- ============================================================

DO $$
DECLARE
  v_track_id   uuid;
  v_mod1_id    uuid;
  v_mod2_id    uuid;
  v_mod3_id    uuid;
  v_mod4_id    uuid;
  v_mod5_id    uuid;
  v_mod6_id    uuid;
  v_mod7_id    uuid;
  v_mod8_id    uuid;
BEGIN

  SELECT id INTO v_track_id FROM tracks WHERE name = 'FOH Server' LIMIT 1;
  IF v_track_id IS NULL THEN
    RAISE EXCEPTION 'Track "FOH Server" not found.';
  END IF;

  INSERT INTO modules (track_id, title, description, order_index)
  SELECT v_track_id, 'Welcome & Orientation', 'Tour, team introductions, and your role at Mallards', 1
  WHERE NOT EXISTS (SELECT 1 FROM modules WHERE track_id = v_track_id AND title = 'Welcome & Orientation');
  SELECT id INTO v_mod1_id FROM modules WHERE track_id = v_track_id AND title = 'Welcome & Orientation';

  INSERT INTO modules (track_id, title, description, order_index)
  SELECT v_track_id, 'Mallards Standards & Service Philosophy', 'Our core values, steps of service, and what sets Mallards apart', 2
  WHERE NOT EXISTS (SELECT 1 FROM modules WHERE track_id = v_track_id AND title = 'Mallards Standards & Service Philosophy');
  SELECT id INTO v_mod2_id FROM modules WHERE track_id = v_track_id AND title = 'Mallards Standards & Service Philosophy';

  INSERT INTO modules (track_id, title, description, order_index)
  SELECT v_track_id, 'Starters, Soups & Salads', 'Full knowledge of all starter, soup, and salad menu items', 3
  WHERE NOT EXISTS (SELECT 1 FROM modules WHERE track_id = v_track_id AND title = 'Starters, Soups & Salads');
  SELECT id INTO v_mod3_id FROM modules WHERE track_id = v_track_id AND title = 'Starters, Soups & Salads';

  INSERT INTO modules (track_id, title, description, order_index)
  SELECT v_track_id, 'Fish House & Specialties', 'Fish House entrees, specialty dishes, and kitchen timing', 4
  WHERE NOT EXISTS (SELECT 1 FROM modules WHERE track_id = v_track_id AND title = 'Fish House & Specialties');
  SELECT id INTO v_mod4_id FROM modules WHERE track_id = v_track_id AND title = 'Fish House & Specialties';

  INSERT INTO modules (track_id, title, description, order_index)
  SELECT v_track_id, 'Handhelds, Sides & Desserts', 'Sandwiches, tacos, sides, and dessert menu knowledge', 5
  WHERE NOT EXISTS (SELECT 1 FROM modules WHERE track_id = v_track_id AND title = 'Handhelds, Sides & Desserts');
  SELECT id INTO v_mod5_id FROM modules WHERE track_id = v_track_id AND title = 'Handhelds, Sides & Desserts';

  INSERT INTO modules (track_id, title, description, order_index)
  SELECT v_track_id, 'Beverage Knowledge', 'Cocktails, wine, beer, brunch drinks, and responsible service', 6
  WHERE NOT EXISTS (SELECT 1 FROM modules WHERE track_id = v_track_id AND title = 'Beverage Knowledge');
  SELECT id INTO v_mod6_id FROM modules WHERE track_id = v_track_id AND title = 'Beverage Knowledge';

  INSERT INTO modules (track_id, title, description, order_index)
  SELECT v_track_id, 'Lunch & Brunch', 'Lunch combos, brunch items, and happy hour specials', 7
  WHERE NOT EXISTS (SELECT 1 FROM modules WHERE track_id = v_track_id AND title = 'Lunch & Brunch');
  SELECT id INTO v_mod7_id FROM modules WHERE track_id = v_track_id AND title = 'Lunch & Brunch';

  INSERT INTO modules (track_id, title, description, order_index)
  SELECT v_track_id, 'Server Certification', 'Policies, side work, responsible service, and final sign-off', 8
  WHERE NOT EXISTS (SELECT 1 FROM modules WHERE track_id = v_track_id AND title = 'Server Certification');
  SELECT id INTO v_mod8_id FROM modules WHERE track_id = v_track_id AND title = 'Server Certification';

  -- ============================================================
  -- MODULE 1: WELCOME & ORIENTATION
  -- ============================================================
  IF NOT EXISTS (SELECT 1 FROM module_items WHERE module_id = v_mod1_id AND title = 'Welcome to Mallards' AND type = 'info') THEN
    INSERT INTO module_items (module_id, title, type, content, order_index) VALUES (
      v_mod1_id, 'Welcome to Mallards', 'info',
      '<h2>Welcome to the Mallards Family</h2>
<p>Mallards is a Cajun, seafood, and Southern-inspired restaurant group with multiple locations across MN and WI. We are not a chain. Every location is run by people who genuinely care about the food, the guests, and each other.</p>

<h3>Our Philosophy: "This Is Our Home"</h3>
<p>We treat every guest like they are coming to our home. That means greeting them warmly, anticipating their needs, and making sure every visit feels personal and genuine.</p>

<h3>Your First Day: Round Robin</h3>
<p>Day 1 is a Round Robin day — you shadow each department to understand how the whole team operates.</p>
<ul>
  <li>Tour: coolers, expo line, restrooms, office, back dock</li>
  <li>Learn the POS system — ring as many orders as possible with your trainer</li>
  <li>Complete a blank table number test</li>
  <li>Learn basic payment processing and end-of-shift checkout</li>
  <li>Order one item from Starters / Soups & Salads / Combos and eat it</li>
</ul>

<h3>The Mallards Standards</h3>
<ul>
  <li><strong>Full hands in, full hands out</strong> — never walk to or from a table empty-handed</li>
  <li><strong>Anticipate needs</strong> — refill drinks before they are empty; bring napkins proactively</li>
  <li><strong>Clean as you go</strong> — pre-bus throughout the meal; keep your section spotless</li>
  <li><strong>Always card</strong> — card anyone who appears under 40. No exceptions.</li>
  <li><strong>One Dream, One Team</strong> — run food, help teammates, show up ready to work</li>
</ul>',
      1
    );
  END IF;

  IF NOT EXISTS (SELECT 1 FROM module_items WHERE module_id = v_mod1_id AND title = 'Orientation Quiz' AND type = 'quiz') THEN
    INSERT INTO module_items (module_id, title, type, content, order_index) VALUES (
      v_mod1_id, 'Orientation Quiz', 'quiz',
      '{"questions":[
        {"question":"What is the Mallards philosophy regarding how we treat guests?","options":["Guests are always right no matter what","Treat every guest like they are coming to your home","Guests should order quickly and leave","Focus on high-spending guests first"],"correctIndex":1},
        {"question":"What is \"Full hands in, full hands out\"?","options":["Carry drinks in one hand and food in the other","Never walk to or from a table empty-handed","Always carry two menus when greeting","Bring full silverware rolls to every table"],"correctIndex":1},
        {"question":"What age threshold requires carding a guest?","options":["Under 21","Under 30","Under 40","Under 35"],"correctIndex":2},
        {"question":"What happens on Round Robin Day?","options":["Trainees work only the server section","Trainees shadow each department to understand how the whole team operates","Trainees spend the full day with the kitchen","Trainees take a written exam"],"correctIndex":1},
        {"question":"What does \"One Dream, One Team\" mean at Mallards?","options":["Only managers make decisions","The kitchen and bar work independently","Everyone helps — run food, assist teammates, work together","Only senior servers get help from others"],"correctIndex":2},
        {"question":"When should you greet a newly seated table?","options":["When you finish your current task","Within 30 seconds of being seated","After the host brings water","When they make eye contact and wave"],"correctIndex":1}
      ],"pass_threshold":80}',
      2
    );
  END IF;

  -- ============================================================
  -- MODULE 2: STANDARDS & SERVICE PHILOSOPHY
  -- ============================================================
  IF NOT EXISTS (SELECT 1 FROM module_items WHERE module_id = v_mod2_id AND title = 'Steps of Service Study Guide' AND type = 'info') THEN
    INSERT INTO module_items (module_id, title, type, content, order_index) VALUES (
      v_mod2_id, 'Steps of Service Study Guide', 'info',
      '<h2>The 8 Steps of Mallards Service</h2>

<h3>Step 1 — Greet Within 30 Seconds</h3>
<p>Acknowledge every table immediately. Introduce yourself by name.</p>

<h3>Step 2 — Take Drink Orders & Offer Starters</h3>
<p>Take the full drink order. Suggest a starter: <em>"Can I start you off with our Walleye Bites or Jerk Chicken Nachos tonight?"</em></p>

<h3>Step 3 — Deliver Drinks & Take Starter Order</h3>
<p>Deliver all drinks at once. Take the starter order and place it immediately.</p>

<h3>Step 4 — Deliver Starters & Take Entrée Order</h3>
<p>Deliver starters with proper garnish. Take entrée orders. Remind guests that the Shrimp Boil for 2 takes 25–30 minutes.</p>

<h3>Step 5 — Check Back Within 2 Minutes of Food Delivery</h3>
<p><em>"How is everything tasting?"</em> Address any issues immediately and alert a manager if needed.</p>

<h3>Step 6 — Maintain the Table</h3>
<p>Refill drinks proactively. Pre-bus plates throughout the meal. Full hands in, full hands out every pass.</p>

<h3>Step 7 — Suggest Dessert & Offer Carry-Out</h3>
<p><em>"Can I interest anyone in our Key Lime Pie or Flourless Chocolate Cake?"</em> (The Flourless Chocolate Cake is gluten-free — great to mention.) Offer to box leftovers without being asked.</p>

<h3>Step 8 — Thank & Invite Back</h3>
<p>Thank guests sincerely as they leave. Invite them back: <em>"We hope to see you again soon!"</em></p>

<h2>Responsible Alcohol Service</h2>
<ul>
  <li>Card anyone who appears under 40 — no exceptions</li>
  <li>Under MN law, you are personally liable if you over-serve a guest who then injures themselves or others</li>
  <li>Signs of intoxication: slurred speech, loss of coordination, glassy eyes, sudden mood change</li>
  <li>If you need to cut off a guest, alert a manager immediately — never do it alone</li>
</ul>',
      1
    );
  END IF;

  IF NOT EXISTS (SELECT 1 FROM module_items WHERE module_id = v_mod2_id AND title = 'Service Standards Quiz' AND type = 'quiz') THEN
    INSERT INTO module_items (module_id, title, type, content, order_index) VALUES (
      v_mod2_id, 'Service Standards Quiz', 'quiz',
      '{"questions":[
        {"question":"How many steps are in Mallards Steps of Service?","options":["5","6","8","10"],"correctIndex":2},
        {"question":"When should you check back after delivering food?","options":["After 10 minutes","When the guest signals you","Within 2 minutes of food delivery","Only if the guest looks unhappy"],"correctIndex":2},
        {"question":"How long does the Shrimp Boil for 2 take?","options":["10–15 minutes","15–20 minutes","25–30 minutes","It varies"],"correctIndex":2},
        {"question":"What dessert should you specifically mention for guests with gluten sensitivity?","options":["Key Lime Pie","Cheesecake","Hot Apple Pie","Flourless Chocolate Cake — it is gluten-free"],"correctIndex":3},
        {"question":"What should you do when a guest needs to be cut off from alcohol?","options":["Keep serving but slow down","Cut them off and alert a manager immediately — never do it alone","Ask them to leave on your own","Ignore it unless they cause a scene"],"correctIndex":1},
        {"question":"Under MN law, who is liable if a server over-serves a guest who then causes harm?","options":["Only the restaurant owner","Only the manager on duty","The server is personally liable","The liquor distributor"],"correctIndex":2},
        {"question":"What does \"anticipate needs\" mean in practice?","options":["Ask guests every 5 minutes if they need anything","Refill drinks before empty, bring napkins proactively, clear plates before being asked","Stand near the table at all times","Read guests minds about their food preferences"],"correctIndex":1}
      ],"pass_threshold":80}',
      2
    );
  END IF;

  -- ============================================================
  -- MODULE 3: STARTERS, SOUPS & SALADS
  -- ============================================================
  IF NOT EXISTS (SELECT 1 FROM module_items WHERE module_id = v_mod3_id AND title = 'Starters, Soups & Salads Study Guide' AND type = 'info') THEN
    INSERT INTO module_items (module_id, title, type, content, order_index) VALUES (
      v_mod3_id, 'Starters, Soups & Salads Study Guide', 'info',
      '<h2>Starters</h2>

<h3>Walleye Bites</h3>
<p>Can be pan seared. Served with tartar sauce and lemon. <strong>Allergens: Gluten/Celiac when battered.</strong></p>

<h3>Crab Cakes</h3>
<p>2 cakes formed and seared to order, served with mango salsa and topped with tartar sauce and remoulade. <strong>Allergens: Shellfish, Gluten.</strong></p>

<h3>Jerk Chicken Nachos</h3>
<p>House-made tortilla chips piled high with jerk chicken, pineapple mango salsa, melted cheese blend and avocado sour cream. Sauces can be served on the side. <strong>Allergens: Dairy.</strong></p>

<h3>Seafood "Guac"</h3>
<p>Chopped cooked shrimp, lump crab, pico, lime juice, salt and pepper. Served with house fried tortilla chips. <strong>Allergens: Shellfish.</strong></p>

<h3>Lump Crab Queso</h3>
<p>Dill cream cheese mixed with capers, hot banana sauce, alfredo sauce and lump crab meat. Served with tortilla chips. <strong>Allergens: Shellfish, Dairy, Gluten.</strong></p>

<h3>Elote Corn Fritters</h3>
<p>3 corn fritters breaded to order, served with 2 limes, bang bang sauce, and avo crema. Sauces can be served on the side. <strong>Allergens: Gluten.</strong></p>

<h3>Smoked Salmon Plate</h3>
<p>Honey smoked salmon, lemon dill cream cheese, capers and cucumber. Served with toasted baguette. <strong>Allergens: Gluten, Dairy, Fish.</strong></p>

<h3>Chicken Wings</h3>
<p>1 pound (8–10 wings) flash fried, served with sauce of choice and ranch or blue cheese for dipping, served with celery sticks. Sauces can be served on the side. <strong>Allergens: Gluten Friendly.</strong></p>

<h3>Cheeseburger Sliders</h3>
<p>4 smash patties, Hawaiian rolls, American cheese served with house pickles. Served with ketchup. <strong>Allergens: Gluten, Dairy.</strong></p>

<h3>Jalapeño Corn Bread</h3>
<p>Homemade corn bread topped with candied jalapeños and served with a cup of honey butter. Cannot be made without the jalapeños but they can be taken off once served. <strong>Allergens: Gluten, Dairy.</strong></p>

<h2>Soups & Salads</h2>

<h3>Bread Bowl Soup</h3>
<p>Freshly baked sourdough bread bowl filled with your choice of soup. Can also order just a cup or bowl. <strong>Allergens: Gluten, Dairy, Shellfish (varies by soup).</strong></p>

<h3>Beef Chili</h3>
<p>House-made beef and bean chili, slow simmered and hearty. Can add sour cream, cheese and green onions.</p>

<h3>Garden Salad</h3>
<p>Mixed greens, carrots, croutons, cheese, cucumber and tomato. Can add protein, remove croutons, dressing of choice. <strong>Allergens: Croutons-Celiac, Cheese-Dairy.</strong></p>

<h3>Caesar Salad</h3>
<p>Can add protein, remove croutons. <strong>Allergens: Croutons-Celiac, Cheese-Dairy.</strong></p>

<h3>Mediterranean Power Bowl</h3>
<p>Dressing is a mix of Caesar and citrus vinaigrette — can do dressing on side. Can remove farro for gluten-free. Can add protein. <strong>Allergens: Farro-Celiac, Cheese-Dairy.</strong></p>

<h3>Southwest Shrimp Cobb</h3>
<p>Gluten free. Can sub chicken for grilled shrimp. Southwest ranch dressing comes on side. Can have salsas on side or remove tortilla strips. <strong>Allergens: Shellfish.</strong></p>

<h3>Thai Peanut Chicken Chip</h3>
<p>Chopped cabbage, mixed greens, chopped chicken, pickled onion, cilantro, lime all tossed in the citrus vinaigrette and topped with homemade peanut sauce and sriracha aioli. Can have sauces on side. <strong>Allergens: PEANUT.</strong> ⚠️ Always disclose to guests.</p>',
      1
    );
  END IF;

  IF NOT EXISTS (SELECT 1 FROM module_items WHERE module_id = v_mod3_id AND title = 'Starters, Soups & Salads Quiz' AND type = 'quiz') THEN
    INSERT INTO module_items (module_id, title, type, content, order_index) VALUES (
      v_mod3_id, 'Starters, Soups & Salads Quiz', 'quiz',
      '{"questions":[
        {"question":"The Crab Cakes are served with what sauces?","options":["Hollandaise and remoulade","Mango salsa, tartar sauce, and remoulade","Cajun cream sauce and tartar","AS IS with no sauce"],"correctIndex":1},
        {"question":"What is in the Lump Crab Queso?","options":["Standard nacho cheese dip with crab","Dill cream cheese, capers, hot banana sauce, alfredo sauce, and lump crab meat","Warm velveeta with lump crab","Cream cheese with jalapeños and crab"],"correctIndex":1},
        {"question":"The Elote Corn Fritters are served with what sauces?","options":["Ranch and honey butter","Tartar sauce and lemon","Bang bang sauce and avo crema","Remoulade and sriracha"],"correctIndex":2},
        {"question":"Which salad is GLUTEN FREE and has southwest ranch dressing that comes on the side?","options":["Mediterranean Power Bowl","Garden Salad","Thai Peanut Chicken Chip","Southwest Shrimp Cobb"],"correctIndex":3},
        {"question":"What critical allergen is in the Thai Peanut Chicken Chip?","options":["Tree nuts","Shellfish","Peanuts","Soy"],"correctIndex":2},
        {"question":"How many wings are in a Chicken Wings order?","options":["6–8","8–10 (1 pound)","12","Half dozen"],"correctIndex":1},
        {"question":"What makes the Smoked Salmon Plate different from a standard smoked salmon?","options":["It is served cold with crackers","Honey smoked salmon with lemon dill cream cheese, capers and cucumber on toasted baguette","It is served warm with a butter sauce","It comes with a side salad"],"correctIndex":1},
        {"question":"The Mediterranean Power Bowl dressing is a mix of:","options":["Ranch and citrus vinaigrette","Balsamic and olive oil","Caesar and citrus vinaigrette","Honey mustard and citrus"],"correctIndex":2},
        {"question":"Can the farro in the Mediterranean Power Bowl be removed for guests with celiac?","options":["No — farro is the base and cannot be removed","Yes — removing farro makes it gluten-free","The bowl already comes without farro","Only if ordered on the side"],"correctIndex":1},
        {"question":"Jalapeño Corn Bread cannot be made without the candied jalapeños, but what can be done?","options":["The kitchen can substitute a different topping","They can be removed once the bread is served","It cannot be modified at all","The bread can be ordered plain with nothing on it"],"correctIndex":1}
      ],"pass_threshold":80}',
      2
    );
  END IF;

  -- ============================================================
  -- MODULE 4: FISH HOUSE & SPECIALTIES
  -- ============================================================
  IF NOT EXISTS (SELECT 1 FROM module_items WHERE module_id = v_mod4_id AND title = 'Fish House & Specialties Study Guide' AND type = 'info') THEN
    INSERT INTO module_items (module_id, title, type, content, order_index) VALUES (
      v_mod4_id, 'Fish House & Specialties Study Guide', 'info',
      '<h2>Fish House</h2>

<h3>Mediterranean Shrimp Pasta</h3>
<p>Linguini with shrimp in a white wine herb butter, finished with stewed tomatoes, feta cheese, olive and caper tapenade and crushed red pepper. Can be made without any components. <strong>Allergens: Shellfish, Gluten.</strong></p>

<h3>Salmon New Orleans</h3>
<p>Blackened salmon topped with lump crab, fresh tomatoes and white wine butter sauce. Served on mashed potatoes. Can be served without the sauce. <strong>Allergens: Shellfish, Gluten, Dairy.</strong> ⚠️ Contains shellfish (lump crab on top).</p>

<h3>Shrimp and Grits</h3>
<p>Cheesy grits, 8 blackened shrimp, sautéed green peppers and onion, Cajun cream sauce and tomato bacon jam and cilantro. Can remove peppers, onions and tomato jam. <strong>Allergens: Shellfish.</strong></p>

<h3>Shrimp Boil for 2</h3>
<p>Potatoes, corn, andouille and shrimp boiled in a bag (spicy or mild), comes with a cup of lemon, cocktail sauce and drawn butter. Can add on 1 pound of snow crab for $20. <strong>Takes 25–30 minutes — always set expectations.</strong> <strong>Allergens: Shellfish.</strong></p>

<h3>Fried Shrimp</h3>
<p>8 breaded jumbo shrimp served with fries, slaw, cocktail sauce, lemon and ketchup. <strong>Allergens: Shellfish, Gluten.</strong></p>

<h3>Fish and Chips</h3>
<p>3 pieces of breaded cod served with fries, slaw, tartar, lemon and ketchup. <strong>Allergens: Gluten.</strong></p>

<h3>Shrimp and Sausage Gumbo</h3>
<p>A rich savory Louisiana stew of shrimp and smoked sausage, served with cream risotto and a slice of cornbread. Can be made without one of the proteins. <strong>Allergens: Shellfish, Dairy, Gluten.</strong></p>

<h3>Barramundi Rodrigo</h3>
<p>Asian seabass pan seared served with coconut risotto, jalapeño-lime pesto and garnished with a lime. <em>(Barramundi = Asian seabass — mild and buttery.)</em></p>

<h3>Pistachio Crusted Salmon</h3>
<p>Pistachio crusted Atlantic salmon served with creamy risotto and red pepper beurre blanc. Can be made without the crust. <strong>Allergens: Fish, Gluten, Dairy.</strong> ⚠️ Tree nut allergen (pistachio).</p>

<h3>Simply Prepared</h3>
<p>Choice of Barramundi / Atlantic Cod / Ahi Tuna / Atlantic Salmon / Canadian Walleye. Served with Quinoa and Rice Medley and seasonal vegetables. Sauce choices: Cajun Cream / Hollandaise / Lemon Butter / Pineapple Mango Salsa / Sesame Soy Ginger. Fish is blackened or pan seared; Ahi Tuna, Salmon and Barramundi can be grilled. Sauce can be on the side. <strong>Allergens: Depends on fish and sauce selected.</strong></p>

<h2>Specialties</h2>

<h3>Wild Mushroom Pappardelle</h3>
<p>Fresh herbs, white wine and cream tossed with pappardelle pasta. Can add chicken or shrimp. <strong>Allergens: Gluten, Dairy.</strong></p>

<h3>Steak Alfredo</h3>
<p>Linguine, 4 oz filet cooked to order, house alfredo sauce and topped with onion straws. Can leave off the onion straws. <strong>Allergens: Gluten, Dairy.</strong></p>

<h3>Jambalaya</h3>
<p>Risotto topped with sautéed chicken, shrimp, andouille, green pepper, onion and tomato — garnished with Cajun seasoning. Can be made without shrimp/clam stock. <strong>⚠️ Risotto-based — communicate to guests expecting traditional rice.</strong> <strong>Allergens: Shellfish.</strong></p>

<h3>Crispy Lemon Chicken</h3>
<p>Fried chicken breast topped with lemon butter and capers served over mashed potatoes. <strong>Allergens: Gluten, Dairy.</strong></p>

<h3>Chicken Littles</h3>
<p>Hand battered chicken fingers, French fries, garlic toast, house made pickles, coleslaw and comeback sauce. Available Tennessee Hot or Southern Fried. <strong>Allergens: Gluten, Dairy.</strong></p>

<h3>Hot Chicken and Waffles</h3>
<p>4 house breaded chicken tenders tossed in house Nashville hot sauce, stacked between 3 waffles, served with syrup and honey butter. Spicy. <strong>Allergens: Gluten.</strong></p>

<h3>Grammy''s Meatloaf</h3>
<p>House-made meatloaf topped with a sweet tomato glaze. Served with mashed potatoes and green beans. Topped with fried onions. <strong>Allergens: Gluten, Dairy.</strong></p>

<h3>Surf and Turf</h3>
<p>4 oz filet cooked to order, 8 jumbo shrimp fried NOLA or scampi style, served with garlic mashed potatoes. <strong>Gluten free.</strong></p>

<h3>Captain''s Ribeye</h3>
<p>14 oz ribeye cooked to order, served with sautéed garlic green beans and garlic mashed potatoes. Topped with Cajun butter. Always ask: Rare / Med-Rare / Medium / Med-Well / Well.</p>',
      1
    );
  END IF;

  IF NOT EXISTS (SELECT 1 FROM module_items WHERE module_id = v_mod4_id AND title = 'Fish House & Specialties Quiz' AND type = 'quiz') THEN
    INSERT INTO module_items (module_id, title, type, content, order_index) VALUES (
      v_mod4_id, 'Fish House & Specialties Quiz', 'quiz',
      '{"questions":[
        {"question":"Salmon New Orleans is topped with what, making it a shellfish allergen dish?","options":["Cajun cream sauce","Lump crab, fresh tomatoes and white wine butter sauce","Shrimp and andouille","Remoulade and mango salsa"],"correctIndex":1},
        {"question":"What is Barramundi Rodrigo served with?","options":["Garlic mashed potatoes and Cajun butter","Lemon butter and capers","Coconut risotto and jalapeño-lime pesto","Creamy risotto and red pepper beurre blanc"],"correctIndex":2},
        {"question":"Shrimp and Grits includes which unique ingredient alongside the Cajun cream sauce?","options":["Pineapple mango salsa","Tomato bacon jam and cilantro","Sweet tomato glaze","Hollandaise sauce"],"correctIndex":1},
        {"question":"The Shrimp Boil for 2 is boiled in a bag and can be ordered:","options":["Only mild","Only spicy","Spicy or mild, and you can add 1 lb snow crab for $20","Only with andouille removed"],"correctIndex":2},
        {"question":"What is Grammy''s Meatloaf topped with?","options":["House gravy and fried onions","Sweet tomato glaze and fried onions, served with mashed potatoes and green beans","Brown gravy, served with mashed potatoes only","Spicy BBQ sauce and coleslaw"],"correctIndex":1},
        {"question":"Surf and Turf is:","options":["Shellfish allergen with butter sauce","A steak knife required dish with lobster tail","4 oz filet with 8 jumbo shrimp NOLA or scampi style — GLUTEN FREE","A full pound of shrimp with an 8 oz ribeye"],"correctIndex":2},
        {"question":"Jambalaya at Mallards is important to describe to guests because:","options":["It takes 45 minutes to make","It is risotto-based, not traditional rice — and can be made without shrimp/clam stock","It contains peanuts","It is served cold"],"correctIndex":1},
        {"question":"Shrimp and Sausage Gumbo is served with what (not rice)?","options":["Jasmine rice","Brown rice pilaf","Cream risotto and a slice of cornbread","Quinoa and rice medley"],"correctIndex":2},
        {"question":"What are the sauce options for Simply Prepared fish?","options":["Tartar, remoulade, and ketchup","Cajun Cream, Hollandaise, Lemon Butter, Pineapple Mango Salsa, Sesame Soy Ginger","Buffalo, Korean BBQ, or Nashville Hot","Ranch, garlic aioli, or cocktail sauce"],"correctIndex":1},
        {"question":"What can be added to Wild Mushroom Pappardelle for guests who want protein?","options":["Steak or shrimp","Chicken or shrimp","Salmon or chicken","Nothing — it is a vegetarian dish only"],"correctIndex":1}
      ],"pass_threshold":80}',
      2
    );
  END IF;

  -- ============================================================
  -- MODULE 5: HANDHELDS, SIDES & DESSERTS
  -- ============================================================
  IF NOT EXISTS (SELECT 1 FROM module_items WHERE module_id = v_mod5_id AND title = 'Handhelds, Sides & Desserts Study Guide' AND type = 'info') THEN
    INSERT INTO module_items (module_id, title, type, content, order_index) VALUES (
      v_mod5_id, 'Handhelds, Sides & Desserts Study Guide', 'info',
      '<h2>Handhelds</h2>

<h3>Mallards Melt</h3>
<p>Smash patty layered with creamy pimento cheese, served with bacon jam and Nashville aioli on garlic toast. Can be made with no sauce. <strong>Allergens: Gluten, Dairy.</strong></p>

<h3>Tennessee Hot Chicken Sandwich</h3>
<p>Breaded to order chicken breast tossed in house made Nashville hot sauce, served on a bun with comeback sauce and slaw. Can remove slaw/comeback. <strong>Allergens: Gluten.</strong></p>

<h3>Blackened Fish Tacos</h3>
<p>3 pan seared blackened walleye tacos served on corn tortillas, topped with pico, avo cream and sriracha, topped with cilantro. Can remove sriracha, cilantro and avo cream. <strong>GLUTEN FREE.</strong></p>

<h3>Ahi Tuna Tacos</h3>
<p>Sesame crusted ahi tuna, sesame soy, spicy slaw, bang bang sauce and fresh green onions. Can be made with no sauce or seeds. <strong>GLUTEN FREE.</strong></p>

<h3>Lobster Roll</h3>
<p>Toasted New England style bun stuffed with lobster salad — celery, greens, mayo — served with melted butter and French fries. Can be served warm or no celery. <strong>Allergens: Shellfish, Gluten.</strong></p>

<h3>Turkey Club</h3>
<p>Sliced deli turkey on cranberry wild rice bread with greens, tomato and cranberry aioli. Can be toasted. <strong>Allergens: Gluten.</strong></p>

<h3>Fried Walleye Sandwich</h3>
<p>Hand breaded walleye served on a bun with lettuce, tomato, onion and a side of tartar. Served with chips. <strong>Allergens: Gluten, Dairy, Fish.</strong></p>

<h3>Meatloaf Sandwich</h3>
<p>Garlic toast topped with seared mashed potatoes, meatloaf and crispy fried onions drizzled with spicy BBQ sauce. <strong>Allergens: Gluten, Dairy.</strong></p>

<h3>Fried Cod Sandwich</h3>
<p>Hand breaded cod, topped with melted American cheese, served on a bun with lettuce, onion and a side of tartar. Served with chips. <strong>Allergens: Gluten, Dairy, Fish.</strong></p>

<h3>Seafood Roll</h3>
<p>Chilled lobster and Cajun shrimp on a warm New England style bun, mayo, melted butter, celery and green onion. Served with fries. Can be served warm or no celery. <strong>Allergens: Shellfish, Gluten.</strong></p>

<h3>Smash Burger</h3>
<p>Toasted bun with smash burger, lettuce, tomato, red onion and American cheese with garlic aioli on the side. Can modify toppings or get a double patty. <strong>Allergens: Gluten, Dairy.</strong></p>

<h2>Sides</h2>
<ul>
  <li><strong>Mac and Cheese</strong> — Cavatappi noodles tossed with creamy American cheese sauce. Kids version does not have pepper. Can add lobster for $9.99 (half portion). <em>Allergens: Gluten, Dairy (possible Shellfish if lobster added).</em></li>
  <li><strong>Daily Bread</strong> — Half a French loaf warmed to order, served with house made berry jam, honey butter and pimento cheese. Topped with salt and butter. <em>Allergens: Gluten.</em></li>
  <li><strong>Veggie Fries</strong> — Green beans and carrots flash fried and tossed with salt and pepper, served with ranch dressing. <em>Gluten Friendly.</em></li>
  <li><strong>Cajun Fries</strong> — Fries tossed in Cajun seasoning served with spicy remoulade. <em>Allergens: Gluten.</em></li>
  <li><strong>Fresh Steamed Broccoli</strong> — Broccoli sautéed in butter and garlic. <em>Allergens: Dairy.</em></li>
  <li><strong>Green Beans</strong> — Sautéed garlicky green beans.</li>
</ul>
<p><strong>Note:</strong> Any time you add a protein to a dish, it should be served with a steak knife.</p>

<h2>Desserts</h2>
<p>All desserts: small round plates with a spoon or fork per guest.</p>
<ul>
  <li><strong>Key Lime Pie</strong> — House made, topped with whip cream and lime zest. <em>Allergens: Gluten, Dairy.</em></li>
  <li><strong>Flourless Chocolate Cake</strong> — Gluten free chocolate cake topped with whip cream and triple berry jam. <strong>GLUTEN FREE.</strong></li>
  <li><strong>Hot Apple Pie</strong> — Apple pie served on a hot skillet, topped with vanilla bean ice cream and house made Jack Daniels caramel topping. <em>Allergens: Gluten, Dairy.</em></li>
  <li><strong>Cheesecake</strong> — Topped with sour cream topping, garnished with whip cream and a fresh strawberry. Has graham cracker crust. <em>Allergens: Gluten, Dairy.</em></li>
</ul>',
      1
    );
  END IF;

  IF NOT EXISTS (SELECT 1 FROM module_items WHERE module_id = v_mod5_id AND title = 'Handhelds, Sides & Desserts Quiz' AND type = 'quiz') THEN
    INSERT INTO module_items (module_id, title, type, content, order_index) VALUES (
      v_mod5_id, 'Handhelds, Sides & Desserts Quiz', 'quiz',
      '{"questions":[
        {"question":"The Mallards Melt is built on what bread?","options":["Brioche bun","Toasted sourdough","Garlic toast","Hawaiian roll"],"correctIndex":2},
        {"question":"What makes the Blackened Fish Tacos and Ahi Tuna Tacos stand out for guests with gluten sensitivity?","options":["They are made with lettuce wraps","They are both GLUTEN FREE","They can be modified to be gluten-free on request","They use flour tortillas that are gluten-friendly"],"correctIndex":1},
        {"question":"What are Veggie Fries?","options":["A mix of potato and zucchini fries","Sweet potato fries with seasoning","Green beans and carrots flash fried, tossed with salt and pepper","Battered vegetable medley"],"correctIndex":2},
        {"question":"The Turkey Club is served on what bread?","options":["White toast","Brioche bun","Cranberry wild rice bread with cranberry aioli","Sourdough"],"correctIndex":2},
        {"question":"The Hot Apple Pie is served how?","options":["Cold, topped with whipped cream","Room temperature in a pastry shell","On a hot skillet with vanilla bean ice cream and Jack Daniels caramel topping","Warm in a ramekin with whipped cream"],"correctIndex":2},
        {"question":"What is unique about the Meatloaf Sandwich compared to Grammy''s Meatloaf entrée?","options":["It uses a different type of meatloaf","Garlic toast topped with seared mashed potatoes, meatloaf and fried onions drizzled with spicy BBQ sauce","It comes with a side salad instead of vegetables","It is served open-faced with brown gravy"],"correctIndex":1},
        {"question":"Mac and Cheese is made with which type of pasta?","options":["Elbow macaroni","Penne","Cavatappi noodles","Rigatoni"],"correctIndex":2},
        {"question":"Which dessert is GLUTEN FREE?","options":["Key Lime Pie","Cheesecake","Hot Apple Pie","Flourless Chocolate Cake — topped with whip cream and triple berry jam"],"correctIndex":3}
      ],"pass_threshold":80}',
      2
    );
  END IF;

  -- ============================================================
  -- MODULE 6: BEVERAGE KNOWLEDGE
  -- ============================================================
  IF NOT EXISTS (SELECT 1 FROM module_items WHERE module_id = v_mod6_id AND title = 'Beverage Knowledge Study Guide' AND type = 'info') THEN
    INSERT INTO module_items (module_id, title, type, content, order_index) VALUES (
      v_mod6_id, 'Beverage Knowledge Study Guide', 'info',
      '<h2>Signature Cocktails</h2>
<ul>
  <li><strong>Bloody Mary</strong> — Bold, savory, Cajun kick. Spirit options: vodka, tequila (makes it a Bloody Maria), or gin. A brunch staple. "Spicy, savory, and substantial — almost a meal."</li>
  <li><strong>Bottomless Mimosas</strong> — Sparkling wine and juice. Table purchase during brunch. Always confirm hours with manager before offering.</li>
  <li><strong>Espresso Martini</strong> — Vodka, espresso, coffee liqueur. Rich, smooth, slightly sweet. Great after-dinner upsell: "Can I make you an Espresso Martini instead of dessert?"</li>
  <li><strong>Dubai Chocolate Martini</strong> — Dessert-forward chocolate and caramel notes. Make it look as good as it tastes.</li>
</ul>

<h2>Wine Service</h2>
<ul>
  <li>Always present the bottle before opening; pour a small taste for the ordering guest to approve</li>
  <li>Hold wine glasses by the stem — never the bowl</li>
  <li>Red wine: room temp, fill 1/3 full</li>
  <li>White/rosé: serve chilled, fill 1/2 full</li>
</ul>

<h2>Responsible Alcohol Service</h2>
<ul>
  <li>Card anyone who appears under 40 — no exceptions</li>
  <li>You are personally liable under MN Dram Shop law if you over-serve</li>
  <li>Signs to watch: slurred speech, unsteady, glassy eyes, sudden mood change</li>
  <li>If cutting off a guest: be calm, private, alert a manager — never do it alone</li>
</ul>

<h2>Happy Hour</h2>
<ul>
  <li>Typically weekdays — confirm current hours with your manager</li>
  <li>Food specials include Chips & Dip and Cheeseburger Sliders</li>
  <li>Always mention Happy Hour to guests seated during the window</li>
</ul>',
      1
    );
  END IF;

  IF NOT EXISTS (SELECT 1 FROM module_items WHERE module_id = v_mod6_id AND title = 'Beverage Knowledge Quiz' AND type = 'quiz') THEN
    INSERT INTO module_items (module_id, title, type, content, order_index) VALUES (
      v_mod6_id, 'Beverage Knowledge Quiz', 'quiz',
      '{"questions":[
        {"question":"A Bloody Mary made with tequila instead of vodka is called:","options":["A Bloody Caesar","A Bloody Maria","A Spicy Mary","A Tequila Sunrise"],"correctIndex":1},
        {"question":"Bottomless Mimosas are:","options":["An individual purchase any time","A table purchase available during brunch service","Available all day every day","Only available on Sundays"],"correctIndex":1},
        {"question":"The Espresso Martini is best upsold as:","options":["A brunch cocktail with eggs","An after-dinner option — \"it is basically dessert in a glass\"","A daytime refresher","A pre-dinner aperitif"],"correctIndex":1},
        {"question":"When serving wine by the bottle, what do you do before pouring for the table?","options":["Pour immediately","Present the bottle and pour a small taste for the ordering guest to approve","Pour a full glass for the ordering guest","Chill it first regardless of type"],"correctIndex":1},
        {"question":"How full should a glass of red wine be poured?","options":["Completely full","3/4 full","1/3 full","1/2 full"],"correctIndex":2},
        {"question":"What are the two Happy Hour food specials?","options":["Wings and Walleye Bites","Chips & Dip and Cheeseburger Sliders","Jerk Nachos and Elote Fritters","Crab Queso and Smoked Salmon Plate"],"correctIndex":1},
        {"question":"If you need to cut off a guest from alcohol, you should:","options":["Handle it yourself confidently","Alert a manager immediately — never handle a cut-off alone","Ask the bartender to handle it","Send a manager a text and keep serving"],"correctIndex":1}
      ],"pass_threshold":80}',
      2
    );
  END IF;

  -- ============================================================
  -- MODULE 7: LUNCH & BRUNCH
  -- ============================================================
  IF NOT EXISTS (SELECT 1 FROM module_items WHERE module_id = v_mod7_id AND title = 'Lunch & Brunch Study Guide' AND type = 'info') THEN
    INSERT INTO module_items (module_id, title, type, content, order_index) VALUES (
      v_mod7_id, 'Lunch & Brunch Study Guide', 'info',
      '<h2>Lunch Combos & Specials</h2>

<h3>Soup and Sandwich</h3>
<p>Soup or side Caesar or garden salad with half a sandwich. Sandwich options: Grilled Cheese, Turkey Club, Chicken Salad, 2 Cheeseburger Sliders, or Sweet Adelyn. <strong>Allergens: Gluten, Dairy, Shellfish.</strong></p>

<h3>Soup and Salad</h3>
<p>Soup or side Caesar or garden salad. <strong>Allergens: Gluten, Dairy, Shellfish.</strong></p>

<h3>Blackened Salmon Sandwich</h3>
<p>Blackened salmon, shredded lettuce, red onion, served on a toasted bun with remoulade. <strong>Allergens: Gluten.</strong></p>

<h3>Fresh Grilled Salmon</h3>
<p>Blackened salmon served with veggie fries and a side of ranch dressing. Lunch menu item.</p>

<h3>Lobster Quiche</h3>
<p>House made lobster quiche topped with hollandaise and served with a Mallards salad topped with a fried goat cheese ball. Salad topped with fig balsamic dressing and toasted pistachios. <strong>Allergens: Gluten, Nut, Shellfish.</strong> ⚠️ Contains tree nuts (pistachios).</p>

<h2>Brunch Highlights</h2>
<ul>
  <li><strong>Hot Chicken and Waffles</strong> — Available at brunch. 4 house breaded chicken tenders in Nashville hot sauce between 3 waffles with syrup and honey butter. Spicy.</li>
  <li><strong>Bottomless Mimosas</strong> — Table purchase. Sparkling wine with juice. Confirm current brunch hours and pricing with your manager.</li>
  <li><strong>Bloody Mary Bar</strong> — Signature brunch drink. Spirit options: vodka, tequila (Maria), or gin.</li>
</ul>',
      1
    );
  END IF;

  IF NOT EXISTS (SELECT 1 FROM module_items WHERE module_id = v_mod7_id AND title = 'Lunch & Brunch Quiz' AND type = 'quiz') THEN
    INSERT INTO module_items (module_id, title, type, content, order_index) VALUES (
      v_mod7_id, 'Lunch & Brunch Quiz', 'quiz',
      '{"questions":[
        {"question":"What sandwich options come with the Soup and Sandwich combo?","options":["BLT, turkey club, or grilled cheese","Grilled Cheese, Turkey Club, Chicken Salad, 2 Cheeseburger Sliders, or Sweet Adelyn","Any sandwich from the regular menu","Only the Turkey Club or Grilled Cheese"],"correctIndex":1},
        {"question":"The Lobster Quiche contains which allergen that requires a warning to guests with nut allergies?","options":["Peanuts","Tree nuts — toasted pistachios in the salad","Almonds in the hollandaise","Walnuts in the crust"],"correctIndex":1},
        {"question":"Bottomless Mimosas are sold as:","options":["An individual purchase per guest","A table purchase — the whole table participates","Available any time for single diners","Only available for parties of 6 or more"],"correctIndex":1},
        {"question":"The Fresh Grilled Salmon lunch item is described as:","options":["Pan seared salmon on a bun with tartar sauce","Blackened salmon served with veggie fries and a side of ranch dressing","Grilled salmon with garlic mashed potatoes","Salmon with hollandaise and a side salad"],"correctIndex":1},
        {"question":"What spirit makes a Bloody Mary into a Bloody Maria?","options":["Rum","Gin","Tequila","Whiskey"],"correctIndex":2}
      ],"pass_threshold":80}',
      2
    );
  END IF;

  -- ============================================================
  -- MODULE 8: SERVER CERTIFICATION
  -- ============================================================
  IF NOT EXISTS (SELECT 1 FROM module_items WHERE module_id = v_mod8_id AND title = 'Server Certification Study Guide' AND type = 'info') THEN
    INSERT INTO module_items (module_id, title, type, content, order_index) VALUES (
      v_mod8_id, 'Server Certification Study Guide', 'info',
      '<h2>Allergy Protocol</h2>
<ul>
  <li>Repeat the allergy back to the guest: <em>"So I have a nut allergy at this table — I will make sure the kitchen knows."</em></li>
  <li>Communicate allergens verbally to expo and kitchen when placing the order</li>
  <li><strong>Critical allergies to know:</strong> Shellfish (many dishes including Salmon New Orleans), Fish, Peanuts (Thai Peanut Chicken Chip), Tree Nuts (pistachio — Pistachio Crusted Salmon, Lobster Quiche salad), Gluten, Dairy, Egg, Soy</li>
</ul>

<h2>POS & Checkout</h2>
<ul>
  <li>Know how to ring modifiers — no onion, extra sauce, protein add-ons</li>
  <li>Know how to split checks — ask your trainer if unsure</li>
  <li>Void and comp requests go through a manager — never comp without approval</li>
  <li>Know how to process gift cards and credit cards</li>
</ul>

<h2>Side Work</h2>
<ul>
  <li>Rolling silverware: fork + knife + spoon in a napkin roll, folded tight</li>
  <li>Stocking condiments, to-go supplies, and service stations</li>
  <li>Wiping down menus, highchairs, and booster seats</li>
</ul>

<h2>Guest Recovery</h2>
<ul>
  <li>If a guest is unhappy, listen and apologize sincerely first — then find a solution</li>
  <li>Never argue with a guest</li>
  <li>Get a manager for any comp or significant complaint</li>
</ul>

<h2>Teamwork</h2>
<ul>
  <li>Always run food when you see it sitting in the window — even if it is not your table</li>
  <li>Help teammates bus tables, roll silverware, and stock during slow moments</li>
  <li>Mallards runs on teamwork — be someone your team can count on</li>
</ul>',
      1
    );
  END IF;

  IF NOT EXISTS (SELECT 1 FROM module_items WHERE module_id = v_mod8_id AND title = 'Server Certification Quiz' AND type = 'quiz') THEN
    INSERT INTO module_items (module_id, title, type, content, order_index) VALUES (
      v_mod8_id, 'Server Certification Quiz', 'quiz',
      '{"questions":[
        {"question":"Salmon New Orleans contains shellfish — why is this important to communicate to guests with shellfish allergies?","options":["It is cooked in the same pan as shrimp","It is topped with lump crab — guests may not expect shellfish in a salmon dish","It uses a shellfish-based Cajun cream sauce","The mashed potatoes contain shellfish stock"],"correctIndex":1},
        {"question":"Which two dishes have tree nut allergens (pistachio)?","options":["Wild Mushroom Pappardelle and Steak Alfredo","Pistachio Crusted Salmon and the Lobster Quiche salad","Captain''s Ribeye and Surf and Turf","Thai Peanut Chicken Chip and Elote Corn Fritters"],"correctIndex":1},
        {"question":"When can a server issue a comp without manager approval?","options":["Any time a guest complains","When the comp is under $10","Never — all comps require manager approval","When the guest has been waiting more than 15 minutes"],"correctIndex":2},
        {"question":"What should you do when you see food sitting in the window that is not your table?","options":["Leave it — it is not your responsibility","Run it out — always help get food to guests quickly","Tell the expo person to find the right server","Notify a manager and wait"],"correctIndex":1},
        {"question":"The Thai Peanut Chicken Chip has what critical allergen?","options":["Tree nuts","Shellfish","Soy","Peanuts — from homemade peanut sauce"],"correctIndex":3},
        {"question":"A guest is upset about their food. What should you do first?","options":["Immediately offer a comp","Argue your case — the kitchen made it right","Listen and apologize sincerely, then find a solution","Tell them the kitchen is backed up tonight"],"correctIndex":2}
      ],"pass_threshold":80}',
      2
    );
  END IF;

  RAISE NOTICE 'FOH Server content seeded successfully (corrected Food Class 2026 version).';
END $$;

-- SECTION 4: KITCHEN / BOH TRACK
-- ============================================================
-- MALLARDS TRAINING APP — KITCHEN / BOH TRACK CONTENT
-- Study Guides + Quizzes for all Kitchen modules
-- Based on Food Class Training 2026 (authoritative menu reference)
-- Run in Supabase > SQL Editor > New Query
-- ============================================================

DO $$
DECLARE
  v_track_id   uuid;
  v_mod1_id    uuid;
  v_mod2_id    uuid;
  v_mod3_id    uuid;
  v_mod4_id    uuid;
  v_mod5_id    uuid;
  v_mod6_id    uuid;
BEGIN

  -- ── GET TRACK ──────────────────────────────────────────────
  SELECT id INTO v_track_id FROM tracks WHERE name = 'Kitchen' LIMIT 1;
  IF v_track_id IS NULL THEN
    RAISE EXCEPTION 'Track "Kitchen" not found. Please create it in the admin panel first.';
  END IF;

  -- ── CREATE / FIND MODULES ──────────────────────────────────
  INSERT INTO modules (track_id, title, description, order_index)
  SELECT v_track_id, 'BOH Welcome & Orientation', 'Kitchen tour, team structure, and your role in the BOH', 1
  WHERE NOT EXISTS (SELECT 1 FROM modules WHERE track_id = v_track_id AND title = 'BOH Welcome & Orientation');
  SELECT id INTO v_mod1_id FROM modules WHERE track_id = v_track_id AND title = 'BOH Welcome & Orientation';

  INSERT INTO modules (track_id, title, description, order_index)
  SELECT v_track_id, 'Food Safety & Sanitation', 'Temps, FIFO, cross-contamination, and health standards', 2
  WHERE NOT EXISTS (SELECT 1 FROM modules WHERE track_id = v_track_id AND title = 'Food Safety & Sanitation');
  SELECT id INTO v_mod2_id FROM modules WHERE track_id = v_track_id AND title = 'Food Safety & Sanitation';

  INSERT INTO modules (track_id, title, description, order_index)
  SELECT v_track_id, 'Menu Knowledge: Starters & Salads', 'Ingredients, allergens, and talking points for starters and salads', 3
  WHERE NOT EXISTS (SELECT 1 FROM modules WHERE track_id = v_track_id AND title = 'Menu Knowledge: Starters & Salads');
  SELECT id INTO v_mod3_id FROM modules WHERE track_id = v_track_id AND title = 'Menu Knowledge: Starters & Salads';

  INSERT INTO modules (track_id, title, description, order_index)
  SELECT v_track_id, 'Menu Knowledge: Mains & Fish House', 'Fish House entrees, specialties, and handhelds — ingredients and allergens', 4
  WHERE NOT EXISTS (SELECT 1 FROM modules WHERE track_id = v_track_id AND title = 'Menu Knowledge: Mains & Fish House');
  SELECT id INTO v_mod4_id FROM modules WHERE track_id = v_track_id AND title = 'Menu Knowledge: Mains & Fish House';

  INSERT INTO modules (track_id, title, description, order_index)
  SELECT v_track_id, 'Allergen Management', 'Critical allergen protocols, cross-contact prevention, and guest safety', 5
  WHERE NOT EXISTS (SELECT 1 FROM modules WHERE track_id = v_track_id AND title = 'Allergen Management');
  SELECT id INTO v_mod5_id FROM modules WHERE track_id = v_track_id AND title = 'Allergen Management';

  INSERT INTO modules (track_id, title, description, order_index)
  SELECT v_track_id, 'Kitchen Operations & Certification', 'Station responsibilities, opening/closing, and kitchen standards', 6
  WHERE NOT EXISTS (SELECT 1 FROM modules WHERE track_id = v_track_id AND title = 'Kitchen Operations & Certification');
  SELECT id INTO v_mod6_id FROM modules WHERE track_id = v_track_id AND title = 'Kitchen Operations & Certification';

  -- ============================================================
  -- MODULE 1: BOH WELCOME & ORIENTATION
  -- ============================================================
  IF NOT EXISTS (SELECT 1 FROM module_items WHERE module_id = v_mod1_id AND title = 'BOH Welcome Study Guide' AND type = 'info') THEN
    INSERT INTO module_items (module_id, title, type, content, order_index) VALUES (
      v_mod1_id,
      'BOH Welcome Study Guide',
      'info',
      '<h2>Welcome to the Mallards Kitchen</h2>
<p>The kitchen is where the Mallards promise gets delivered. Everything we serve — from the Shrimp Boil for 2 to the Flourless Chocolate Cake — reflects who we are. Your role in the BOH is critical to every guest''s experience, even if they never see you.</p>

<h3>BOH Orientation Checklist</h3>
<p>On your first days, you will complete:</p>
<ul>
  <li>Kitchen tour: walk-in coolers, freezers, prep areas, line stations, dish pit, dry storage</li>
  <li>Introduction to each BOH role: prep cook, line cook, dishwasher, expo</li>
  <li>Review of kitchen hygiene and uniform standards</li>
  <li>Food handler certification requirements for your location</li>
  <li>Review of the current menu with your trainer using the Food Class Training guide</li>
  <li>Shadow each station before being assigned a primary position</li>
</ul>

<h3>BOH Roles</h3>
<ul>
  <li><strong>Prep Cook:</strong> Morning/afternoon prep — stocks the line, cuts vegetables, makes sauces, portion proteins</li>
  <li><strong>Line Cook:</strong> Works a station during service — responsible for quality, speed, and cleanliness</li>
  <li><strong>Dishwasher:</strong> The backbone of the kitchen. Clean plates, pots, and utensils keep the line running.</li>
  <li><strong>Expo:</strong> Quality-checks every plate before it leaves the kitchen. Must know every dish and every garnish.</li>
</ul>

<h3>BOH Standards</h3>
<ul>
  <li><strong>Clean as you go:</strong> Wipe your station constantly. A clean station is a safe station.</li>
  <li><strong>Communicate:</strong> Call out "Behind!", "Hot!", "Corner!" — always. Kitchen communication prevents injuries.</li>
  <li><strong>Knife safety:</strong> Carry knives point-down, blade away from body. Never leave a knife in a sink.</li>
  <li><strong>Uniform:</strong> Non-slip shoes, clean apron, hair restrained. No jewelry in food prep areas.</li>
  <li><strong>Respect the recipe:</strong> Do not modify dishes unless a manager approves. Consistency is our standard.</li>
</ul>

<h3>Kitchen Communication Callouts</h3>
<ul>
  <li><strong>"Behind!"</strong> — Say this any time you are walking behind someone in a tight space</li>
  <li><strong>"Hot!"</strong> — Carrying a hot pan, pot, or dish. Clear the path.</li>
  <li><strong>"Corner!"</strong> — Turning a blind corner. Prevents collisions.</li>
  <li><strong>"86!"</strong> — An item is out of stock. Communicate immediately to expo and FOH.</li>
</ul>',
      1
    );
  END IF;

  IF NOT EXISTS (SELECT 1 FROM module_items WHERE module_id = v_mod1_id AND title = 'BOH Orientation Quiz' AND type = 'quiz') THEN
    INSERT INTO module_items (module_id, title, type, content, order_index) VALUES (
      v_mod1_id,
      'BOH Orientation Quiz',
      'quiz',
      '{"questions":[
        {"question":"What does \"86\" mean in kitchen communication?","options":["Table 86 has a problem","An item is out of stock","The dish is ready to go out","The dishwasher needs help"],"correctIndex":1},
        {"question":"What should you call out when walking behind another team member in the kitchen?","options":["\"Excuse me\"","\"Behind!\"","\"Corner!\"","\"Move!\""],"correctIndex":1},
        {"question":"What is the expo person''s main responsibility?","options":["Washing dishes during service","Quality-checking every plate before it leaves the kitchen","Running food to tables","Taking orders from servers"],"correctIndex":1},
        {"question":"Which BOH role is responsible for prepping the line and making sauces before service?","options":["Line Cook","Dishwasher","Prep Cook","Expo"],"correctIndex":2},
        {"question":"What is the correct way to carry a knife in the kitchen?","options":["Point up, blade toward your body","Point down, blade away from body","In your apron pocket","Only carry knives in a knife roll"],"correctIndex":1},
        {"question":"What does \"clean as you go\" mean for a line cook?","options":["Clean your station only at the end of your shift","Wipe your station constantly throughout service — a clean station is a safe station","Ask the dishwasher to clean during service","Clean whenever a manager walks by"],"correctIndex":1}
      ],"pass_threshold":80}',
      2
    );
  END IF;

  -- ============================================================
  -- MODULE 2: FOOD SAFETY & SANITATION
  -- ============================================================
  IF NOT EXISTS (SELECT 1 FROM module_items WHERE module_id = v_mod2_id AND title = 'Food Safety & Sanitation Study Guide' AND type = 'info') THEN
    INSERT INTO module_items (module_id, title, type, content, order_index) VALUES (
      v_mod2_id,
      'Food Safety & Sanitation Study Guide',
      'info',
      '<h2>Food Safety Fundamentals</h2>
<p>Food safety is non-negotiable. One failure can harm a guest and shut down our restaurant. Know these standards and follow them every shift without exception.</p>

<h3>Temperature Control (The Danger Zone)</h3>
<ul>
  <li><strong>Danger Zone:</strong> 41°F – 135°F. Bacteria grow rapidly in this range.</li>
  <li><strong>Cold holding:</strong> Keep all cold foods at 41°F or below</li>
  <li><strong>Hot holding:</strong> Keep all hot foods at 135°F or above</li>
  <li><strong>Cooking temps:</strong>
    <ul>
      <li>Poultry (chicken): 165°F internal</li>
      <li>Ground beef: 155°F internal</li>
      <li>Fish and seafood: 145°F internal</li>
      <li>Pork: 145°F internal</li>
      <li>Steaks (whole muscle): can be cooked to guest preference — confirm temp</li>
    </ul>
  </li>
  <li>Check temperatures with a calibrated thermometer — probe the thickest part of the protein</li>
</ul>

<h3>FIFO — First In, First Out</h3>
<ul>
  <li>Always use the oldest product first. Rotate stock every time you put away an order.</li>
  <li>New product goes to the back; older product comes to the front</li>
  <li>Check and label all products with prep date and use-by date</li>
  <li>If something is past its date or looks/smells off, do not use it — alert a manager</li>
</ul>

<h3>Cross-Contamination Prevention</h3>
<ul>
  <li>Use separate cutting boards for different protein types (fish, chicken, beef)</li>
  <li>Color-coded boards: follow your location''s color system</li>
  <li>Never use the same knife on raw protein and ready-to-eat food without washing/sanitizing</li>
  <li>Store raw proteins below ready-to-eat foods in the cooler (bottom shelf = raw meats)</li>
  <li>Wash hands thoroughly after handling raw protein before touching anything else</li>
</ul>

<h3>Handwashing Protocol</h3>
<ul>
  <li>Wash hands for at least 20 seconds with soap and warm water</li>
  <li><strong>Always wash hands after:</strong> handling raw protein, using the restroom, taking out trash, touching your face/hair, sneezing/coughing, handling money, returning from break</li>
  <li>Gloves do not replace handwashing. Change gloves when switching tasks.</li>
</ul>

<h3>Sanitation Standards</h3>
<ul>
  <li>Sanitizer buckets must be properly diluted — too weak doesn''t sanitize, too strong is dangerous</li>
  <li>Wipe down surfaces with a sanitizer cloth before and after every use</li>
  <li>Dishwasher temp and chemical levels must be checked at the start of every shift</li>
  <li>Three-sink method: wash → rinse → sanitize for items not going through the dishwasher</li>
</ul>

<h3>Personal Hygiene</h3>
<ul>
  <li>No jewelry in food prep areas — rings, bracelets, and watches can harbor bacteria and fall in food</li>
  <li>Hair must be restrained with a hat or net</li>
  <li>Do not work if you have vomiting, diarrhea, jaundice, or an open wound on hands</li>
  <li>Report illness immediately to your manager — do not come in sick</li>
</ul>',
      1
    );
  END IF;

  IF NOT EXISTS (SELECT 1 FROM module_items WHERE module_id = v_mod2_id AND title = 'Food Safety & Sanitation Quiz' AND type = 'quiz') THEN
    INSERT INTO module_items (module_id, title, type, content, order_index) VALUES (
      v_mod2_id,
      'Food Safety & Sanitation Quiz',
      'quiz',
      '{"questions":[
        {"question":"What is the temperature danger zone where bacteria grow rapidly?","options":["32°F – 100°F","41°F – 135°F","50°F – 150°F","35°F – 145°F"],"correctIndex":1},
        {"question":"What is the minimum internal cooking temperature for chicken?","options":["145°F","155°F","165°F","175°F"],"correctIndex":2},
        {"question":"What does FIFO stand for?","options":["First In, First Out","Fresh Ingredients, Fresh Output","Food Inspection For Operations","First Item, Full Order"],"correctIndex":0},
        {"question":"Where should raw meats be stored in the cooler?","options":["On the top shelf for easy access","On the middle shelf","On the bottom shelf, below ready-to-eat foods","In the door for quick retrieval"],"correctIndex":3},
        {"question":"How long should you wash your hands with soap and warm water?","options":["5 seconds","10 seconds","At least 20 seconds","30 seconds minimum"],"correctIndex":2},
        {"question":"What should you do if a food product is past its use-by date?","options":["Use it immediately since it was just labeled","Do not use it — alert a manager","Freeze it to extend the date","Use it only for staff meals"],"correctIndex":1},
        {"question":"What is the correct three-sink method order?","options":["Rinse → wash → sanitize","Sanitize → wash → rinse","Wash → rinse → sanitize","Wash → sanitize → rinse"],"correctIndex":2},
        {"question":"You should NOT come to work if you have which symptoms?","options":["A mild headache or back pain","Vomiting, diarrhea, or jaundice","Seasonal allergies or a runny nose","Tiredness or fatigue"],"correctIndex":1}
      ],"pass_threshold":80}',
      2
    );
  END IF;

  -- ============================================================
  -- MODULE 3: MENU KNOWLEDGE — STARTERS & SALADS
  -- ============================================================
  IF NOT EXISTS (SELECT 1 FROM module_items WHERE module_id = v_mod3_id AND title = 'Starters & Salads — Ingredients & Allergens' AND type = 'info') THEN
    INSERT INTO module_items (module_id, title, type, content, order_index) VALUES (
      v_mod3_id,
      'Starters & Salads — Ingredients & Allergens',
      'info',
      '<h2>Starters — Ingredients & Allergens</h2>
<p>Know every item cold. Guests rely on us to be accurate about what is in their food.</p>

<h3>Walleye Bites</h3>
<p><strong>Ingredients:</strong> Breaded Minnesota walleye, fried golden. <strong>Allergens: FISH, GLUTEN, EGG.</strong> Served with tartar sauce (egg).</p>

<h3>Crab Cakes</h3>
<p><strong>Ingredients:</strong> Lump crab, herbs, spices, binding agents, pan-seared. <strong>Allergens: SHELLFISH, EGG, GLUTEN.</strong></p>

<h3>Jerk Chicken Nachos</h3>
<p><strong>Ingredients:</strong> House-made tortilla chips, jerk chicken, pineapple mango salsa, melted cheese blend, avocado sour cream. Sauces can be served on the side. <strong>Allergens: DAIRY.</strong></p>

<h3>Seafood "Guac"</h3>
<p><strong>Ingredients:</strong> Fresh avocado, shrimp, crab, pico de gallo, citrus. <strong>Allergens: SHELLFISH.</strong></p>

<h3>Lump Crab Queso</h3>
<p><strong>Ingredients:</strong> Queso dip base, lump crab meat, served with tortilla chips. <strong>Allergens: SHELLFISH, DAIRY, GLUTEN.</strong></p>

<h3>Elote Corn Fritters</h3>
<p><strong>Ingredients:</strong> 3 corn fritters breaded to order, served with 2 limes, bang bang sauce, and avo crema. Sauces can be on the side. <strong>Allergens: GLUTEN.</strong> Vegetarian.</p>

<h3>Smoked Salmon Plate</h3>
<p><strong>Ingredients:</strong> House-smoked salmon, cream cheese, capers, red onion, crackers. <strong>Allergens: FISH, DAIRY, GLUTEN.</strong></p>

<h3>Chicken Wings</h3>
<p><strong>Ingredients:</strong> 1 pound (8–10 wings) flash fried. Sauce options: Buffalo, Cajun Dry Rub, Nashville Hot, Korean BBQ, Sweet Chipotle, Spicy NOLA. Sauces can be on the side. <strong>Allergens: GLUTEN FRIENDLY.</strong> Served with Ranch or Blue Cheese and celery.</p>

<h3>Cheeseburger Sliders</h3>
<p><strong>Ingredients:</strong> Mini beef patties, American cheese, pickles, house sauce, toasted buns. <strong>Allergens: GLUTEN, DAIRY, EGG.</strong></p>

<h3>Jalapeño Corn Bread</h3>
<p><strong>Ingredients:</strong> Jalapeño corn bread, served with honey butter. <strong>Allergens: GLUTEN, DAIRY, EGG.</strong></p>

<h3>Boudin Balls</h3>
<p><strong>Ingredients:</strong> Cajun boudin sausage, fried crispy. <strong>Allergens: GLUTEN, PORK.</strong></p>

<h2>Soups</h2>
<h3>Bread Bowl Soup / Beef Chili</h3>
<p><strong>Bread Bowl:</strong> Allergens: GLUTEN, DAIRY (soup may vary — always check). <strong>Beef Chili:</strong> Allergens: GLUTEN (crackers). Ask the chef for today''s soup allergens.</p>

<h2>Salads</h2>
<h3>Garden / Caesar Salad</h3>
<p><strong>Caesar allergens: EGG, DAIRY, FISH (anchovies in dressing).</strong></p>

<h3>Mediterranean Power Bowl</h3>
<p><strong>Ingredients:</strong> Farro or greens, roasted vegetables, feta, olives, cucumber, tomato, citrus vinaigrette. <strong>Allergens: DAIRY.</strong> Vegetarian.</p>

<h3>Southwest Shrimp Cobb</h3>
<p><strong>Ingredients:</strong> Romaine, shrimp, corn, black beans, avocado, bacon, hard-boiled egg, chipotle ranch. <strong>Allergens: SHELLFISH, EGG, DAIRY.</strong></p>

<h3>Thai Peanut Chicken Chip</h3>
<p><strong>Ingredients:</strong> Chopped romaine and cabbage, grilled chicken, edamame, carrots, crispy noodles, Thai peanut dressing. <strong>Allergens: PEANUTS, GLUTEN, SOY.</strong> ⚠️ Critical allergen — always confirm with guests who have nut allergies.</p>',
      1
    );
  END IF;

  IF NOT EXISTS (SELECT 1 FROM module_items WHERE module_id = v_mod3_id AND title = 'Starters & Salads Allergen Quiz' AND type = 'quiz') THEN
    INSERT INTO module_items (module_id, title, type, content, order_index) VALUES (
      v_mod3_id,
      'Starters & Salads Allergen Quiz',
      'quiz',
      '{"questions":[
        {"question":"Which starter contains a CRITICAL peanut allergen?","options":["Jerk Chicken Nachos","Southwest Shrimp Cobb","Thai Peanut Chicken Chip","Elote Corn Fritters"],"correctIndex":2},
        {"question":"What allergens are in the Seafood Guac?","options":["Gluten and dairy","Shellfish only","Fish and egg","Peanuts and soy"],"correctIndex":1},
        {"question":"Which salad contains anchovies (fish allergen) in the dressing?","options":["Garden Salad","Mediterranean Power Bowl","Caesar Salad","Thai Peanut Chicken Chip"],"correctIndex":2},
        {"question":"The Elote Corn Fritters are Gluten only — which ingredients are NOT in them?","options":["Corn fritters and bang bang sauce","Dairy and egg","Avo crema","A lime garnish"],"correctIndex":1},
        {"question":"What allergens are in Crab Cakes?","options":["Fish, gluten, dairy","Shellfish, egg, gluten","Peanuts, soy, shellfish","Dairy, egg, fish"],"correctIndex":1},
        {"question":"Which starter is the only one that contains PORK?","options":["Jerk Chicken Nachos","Cheeseburger Sliders","Boudin Balls","Chicken Wings"],"correctIndex":2},
        {"question":"The Mediterranean Power Bowl is suitable for:","options":["Guests with shellfish allergies only","Vegetarians — it contains no meat","Guests who are gluten-free","Vegans — it contains no animal products"],"correctIndex":1},
        {"question":"Chicken Wings at Mallards are listed as which allergen designation?","options":["Gluten only","Dairy and egg","Gluten Friendly","Shellfish and gluten"],"correctIndex":2}
      ],"pass_threshold":80}',
      2
    );
  END IF;

  -- ============================================================
  -- MODULE 4: MENU KNOWLEDGE — MAINS & FISH HOUSE
  -- ============================================================
  IF NOT EXISTS (SELECT 1 FROM module_items WHERE module_id = v_mod4_id AND title = 'Fish House & Specialties — Ingredients & Allergens' AND type = 'info') THEN
    INSERT INTO module_items (module_id, title, type, content, order_index) VALUES (
      v_mod4_id,
      'Fish House & Specialties — Ingredients & Allergens',
      'info',
      '<h2>Fish House — Ingredients & Allergens</h2>

<h3>Mediterranean Shrimp Pasta</h3>
<p><strong>Ingredients:</strong> Gulf shrimp, pasta, olive oil, white wine, cherry tomatoes, kalamata olives, spinach, feta. <strong>Allergens: SHELLFISH, GLUTEN, DAIRY.</strong></p>

<h3>Salmon New Orleans</h3>
<p><strong>Ingredients:</strong> Blackened salmon topped with LUMP CRAB, fresh tomatoes and white wine butter sauce. Served on mashed potatoes. <strong>Allergens: SHELLFISH (lump crab on top), GLUTEN, DAIRY.</strong> ⚠️ Critical: guests with shellfish allergy may not expect crab on a salmon dish — always flag this.</p>

<h3>Shrimp and Grits</h3>
<p><strong>Ingredients:</strong> Gulf shrimp, stone-ground grits, andouille sausage, Cajun cream sauce, green onions. <strong>Allergens: SHELLFISH, DAIRY, GLUTEN (sausage).</strong></p>

<h3>Shrimp Boil for 2</h3>
<p><strong>Ingredients:</strong> Gulf shrimp, andouille sausage, corn on the cob, red potatoes, Cajun seasoning. <strong>Cook time: 25–30 minutes.</strong> <strong>Allergens: SHELLFISH, GLUTEN (sausage).</strong></p>

<h3>Fried Shrimp</h3>
<p><strong>Ingredients:</strong> Hand-breaded Gulf shrimp, coleslaw. <strong>Allergens: SHELLFISH, GLUTEN, EGG.</strong></p>

<h3>Fish and Chips</h3>
<p><strong>Ingredients:</strong> Beer-battered cod, steak fries, coleslaw. <strong>Allergens: FISH, GLUTEN, EGG.</strong></p>

<h3>Shrimp and Sausage Gumbo</h3>
<p><strong>Ingredients:</strong> Rich Louisiana stew of shrimp and smoked sausage, served with CREAM RISOTTO and a slice of cornbread. <strong>Allergens: SHELLFISH, DAIRY, GLUTEN.</strong></p>

<h3>Barramundi Rodrigo</h3>
<p><strong>Ingredients:</strong> Pan-seared barramundi (Australian white fish), Rodrigo sauce (butter, capers, white wine, lemon). <strong>Allergens: FISH, DAIRY.</strong></p>

<h3>Pistachio Crusted Salmon</h3>
<p><strong>Ingredients:</strong> Atlantic salmon, pistachio crust, seasonal accompaniments. <strong>Allergens: FISH, TREE NUTS (pistachio), DAIRY.</strong> ⚠️ Critical nut allergen.</p>

<h3>Simply Prepared</h3>
<p><strong>Fish options:</strong> Barramundi, Cod, Ahi Tuna, Salmon, or Walleye. Grilled, blackened, or pan-seared. <strong>Allergens: FISH.</strong> Ask the guest to confirm preparation and sides.</p>

<h2>Specialties — Ingredients & Allergens</h2>

<h3>Wild Mushroom Pappardelle</h3>
<p><strong>Ingredients:</strong> Pappardelle pasta, wild mushrooms, shallots, herbs, truffle oil, Parmesan. <strong>Allergens: GLUTEN, DAIRY.</strong> Vegetarian.</p>

<h3>Steak Alfredo</h3>
<p><strong>Ingredients:</strong> Fettuccine, Alfredo sauce, sliced steak. <strong>Allergens: GLUTEN, DAIRY, EGG.</strong></p>

<h3>Jambalaya (Risotto-Based)</h3>
<p><strong>Ingredients:</strong> Risotto (NOT traditional rice), shrimp, andouille sausage, chicken, Cajun spices. <strong>⚠️ NOTE: Risotto-based — communicate this to FOH for any guests expecting traditional rice preparation.</strong> <strong>Allergens: SHELLFISH, GLUTEN (sausage), DAIRY.</strong></p>

<h3>Crispy Lemon Chicken</h3>
<p><strong>Ingredients:</strong> Pan-fried chicken breast, lemon butter sauce, seasonal vegetables. <strong>Allergens: GLUTEN, DAIRY, EGG.</strong></p>

<h3>Chicken Littles</h3>
<p><strong>Ingredients:</strong> Fried chicken tenders, available Tennessee Hot or Southern Fried, served with coleslaw. <strong>Allergens: GLUTEN, EGG.</strong></p>

<h3>Hot Chicken and Waffles</h3>
<p><strong>Ingredients:</strong> Nashville hot chicken, Belgian waffle, syrup, honey butter. <strong>Allergens: GLUTEN, EGG, DAIRY.</strong></p>

<h3>Grammy''s Meatloaf</h3>
<p><strong>Ingredients:</strong> House-made beef meatloaf, mashed potatoes, house gravy. <strong>Allergens: GLUTEN, EGG, DAIRY.</strong></p>

<h3>Surf and Turf</h3>
<p><strong>Ingredients:</strong> 4 oz filet cooked to order, 8 jumbo shrimp fried NOLA or scampi style, served with garlic mashed potatoes. <strong>Allergens: SHELLFISH. GLUTEN FREE.</strong></p>

<h3>Captain''s Ribeye</h3>
<p><strong>Ingredients:</strong> 14 oz. center-cut ribeye, butter-basted. Temperature options: Rare, Med-Rare, Medium, Med-Well, Well. <strong>Allergens: DAIRY (butter baste).</strong></p>

<h2>Handhelds</h2>
<ul>
  <li><strong>Lobster Roll / Seafood Roll</strong> — Allergens: SHELLFISH, GLUTEN</li>
  <li><strong>Tennessee Hot Chicken Sandwich</strong> — Allergens: GLUTEN</li>
  <li><strong>Blackened Fish Tacos</strong> — ✅ GLUTEN FREE (corn tortillas)</li>
  <li><strong>Ahi Tuna Tacos</strong> — ✅ GLUTEN FREE</li>
  <li><strong>Fried Walleye Sandwich / Fried Cod Sandwich</strong> — Allergens: FISH, GLUTEN, DAIRY</li>
  <li><strong>Smash Burger</strong> — Allergens: GLUTEN, DAIRY</li>
  <li><strong>Turkey Club</strong> — Allergens: GLUTEN (cranberry wild rice bread)</li>
  <li><strong>Mallards Melt</strong> — Allergens: GLUTEN, DAIRY (pimento cheese, garlic toast)</li>
</ul>',
      1
    );
  END IF;

  IF NOT EXISTS (SELECT 1 FROM module_items WHERE module_id = v_mod4_id AND title = 'Fish House & Mains Allergen Quiz' AND type = 'quiz') THEN
    INSERT INTO module_items (module_id, title, type, content, order_index) VALUES (
      v_mod4_id,
      'Fish House & Mains Allergen Quiz',
      'quiz',
      '{"questions":[
        {"question":"Which Fish House item contains tree nuts as a critical allergen?","options":["Salmon New Orleans","Barramundi Rodrigo","Pistachio Crusted Salmon","Shrimp and Grits"],"correctIndex":2},
        {"question":"What is unique about Mallards Jambalaya that BOH must know?","options":["It contains no shrimp","It is made with risotto, not traditional rice","It takes 45 minutes to cook","It is prepared without Cajun seasoning"],"correctIndex":1},
        {"question":"What are the allergens in Shrimp and Grits?","options":["Fish and dairy only","Shellfish, dairy, and gluten","Peanuts, shellfish, and egg","Gluten and egg only"],"correctIndex":1},
        {"question":"The Simply Prepared dish can be prepared with which fish options?","options":["Walleye and salmon only","Salmon, cod, or tuna only","Barramundi, cod, ahi tuna, salmon, or walleye","Only what is freshest that day"],"correctIndex":2},
        {"question":"What is the cook time for the Shrimp Boil for 2?","options":["10–15 minutes","15–20 minutes","25–30 minutes","Under 10 minutes"],"correctIndex":2},
        {"question":"Which specialty entree is VEGETARIAN?","options":["Crispy Lemon Chicken","Hot Chicken and Waffles","Wild Mushroom Pappardelle","Surf and Turf"],"correctIndex":2},
        {"question":"What allergens are in Fish and Chips?","options":["Fish and gluten","Shellfish and gluten only","Fish, dairy, and soy","Shellfish, egg, and dairy"],"correctIndex":0},
        {"question":"Which two handhelds are GLUTEN FREE?","options":["Lobster Roll and Turkey Club","Blackened Fish Tacos and Ahi Tuna Tacos","Smash Burger and Mallards Melt","Tennessee Hot Chicken Sandwich and Seafood Roll"],"correctIndex":1}
      ],"pass_threshold":80}',
      2
    );
  END IF;

  -- ============================================================
  -- MODULE 5: ALLERGEN MANAGEMENT
  -- ============================================================
  IF NOT EXISTS (SELECT 1 FROM module_items WHERE module_id = v_mod5_id AND title = 'Allergen Management Study Guide' AND type = 'info') THEN
    INSERT INTO module_items (module_id, title, type, content, order_index) VALUES (
      v_mod5_id,
      'Allergen Management Study Guide',
      'info',
      '<h2>Allergen Management at Mallards</h2>
<p>Allergic reactions can be life-threatening. Every allergy request must be treated as an emergency — not an inconvenience.</p>

<h3>The Big 9 Allergens (FDA)</h3>
<ul>
  <li>🦐 <strong>Shellfish</strong> — crab, shrimp, lobster (in many of our seafood items)</li>
  <li>🐟 <strong>Fish</strong> — walleye, salmon, cod, tuna, barramundi</li>
  <li>🥜 <strong>Peanuts</strong> — Thai Peanut Chicken Chip dressing</li>
  <li>🌲 <strong>Tree Nuts</strong> — pistachios in Pistachio Crusted Salmon</li>
  <li>🌾 <strong>Wheat/Gluten</strong> — breading, pasta, buns, sauces</li>
  <li>🥛 <strong>Dairy/Milk</strong> — cream sauces, cheese, butter</li>
  <li>🥚 <strong>Eggs</strong> — breading, aioli, mayo</li>
  <li>🫘 <strong>Soy</strong> — soy-sesame dressings, some marinades</li>
  <li>🌾 <strong>Wheat</strong> (already covered under gluten)</li>
</ul>

<h3>When a Server Alerts You to an Allergy</h3>
<ol>
  <li>Stop what you are doing and acknowledge the allergy verbally to the server</li>
  <li>Confirm with the chef or manager before proceeding</li>
  <li>Use clean equipment — fresh gloves, clean cutting board, clean utensils</li>
  <li>Do not cook an allergen-free dish next to or in the same pan as the allergen</li>
  <li>Plate separately — do not use the same tongs or spoons that touched the allergen</li>
  <li>Communicate clearly when the dish leaves the kitchen — "This is the allergy plate for Table X"</li>
</ol>

<h3>Cross-Contact vs. Cross-Contamination</h3>
<ul>
  <li><strong>Cross-contamination:</strong> Bacteria from raw proteins transferring to ready-to-eat food</li>
  <li><strong>Cross-contact:</strong> An allergen (like peanut residue) transferring to an allergen-free dish</li>
  <li>Both are dangerous. Both require the same vigilance: clean equipment, clean hands, separate preparation.</li>
</ul>

<h3>High-Risk Items at Mallards — Allergen Quick Reference</h3>
<ul>
  <li><strong>Peanut alert:</strong> Thai Peanut Chicken Chip — peanut dressing</li>
  <li><strong>Tree nut alert:</strong> Pistachio Crusted Salmon — pistachio crust</li>
  <li><strong>Shellfish everywhere:</strong> Seafood Guac, Crab Queso, Crab Cakes, Shrimp items, Lobster Roll, Surf & Turf, Jambalaya</li>
  <li><strong>Fish items:</strong> Walleye, Salmon, Cod, Ahi Tuna, Barramundi — all fish allergen</li>
  <li><strong>Gluten:</strong> Nearly all breaded items, all pasta, all buns</li>
  <li><strong>Gluten-free option:</strong> Flourless Chocolate Cake (dessert)</li>
</ul>

<h3>If You Are Unsure</h3>
<p><strong>Stop and ask a manager or chef. It is always better to delay a dish than to send out something that could harm a guest.</strong> No dish is worth a guest ending up in the hospital.</p>',
      1
    );
  END IF;

  IF NOT EXISTS (SELECT 1 FROM module_items WHERE module_id = v_mod5_id AND title = 'Allergen Management Quiz' AND type = 'quiz') THEN
    INSERT INTO module_items (module_id, title, type, content, order_index) VALUES (
      v_mod5_id,
      'Allergen Management Quiz',
      'quiz',
      '{"questions":[
        {"question":"How many major allergens are recognized by the FDA (the Big 9)?","options":["5","7","9","12"],"correctIndex":2},
        {"question":"A server alerts you to a peanut allergy at a table. Which Mallards dish contains peanuts?","options":["Southwest Shrimp Cobb","Thai Peanut Chicken Chip","Mediterranean Power Bowl","Jerk Chicken Nachos"],"correctIndex":1},
        {"question":"What is cross-contact?","options":["Bacteria from raw protein transferring to ready-to-eat food","An allergen residue transferring to an allergen-free dish","Two servers touching the same table","Touching a dirty surface and then food"],"correctIndex":1},
        {"question":"When preparing an allergen-free dish, you should:","options":["Use the same equipment if it looks clean","Use clean gloves, clean cutting board, and clean utensils — separate from allergen items","Move quickly — no special prep needed","Ask the guest if they are truly allergic before doing anything different"],"correctIndex":1},
        {"question":"Which Mallards dessert is gluten-free?","options":["Key Lime Pie","Hot Apple Pie","Cheesecake","Flourless Chocolate Cake"],"correctIndex":3},
        {"question":"The Pistachio Crusted Salmon contains which critical allergen that must always be communicated?","options":["Peanuts","Shellfish","Tree nuts (pistachio)","Soy"],"correctIndex":2},
        {"question":"If you are unsure whether a dish is safe for a guest with an allergy, you should:","options":["Send it out and let the server explain","Guess based on what you think is in it","Stop and ask a manager or chef before plating","Tell the server there is no way to guarantee anything"],"correctIndex":2},
        {"question":"The Caesar salad dressing contains which unexpected allergen?","options":["Peanuts","Soy","Fish (anchovies)","Shellfish"],"correctIndex":2}
      ],"pass_threshold":80}',
      2
    );
  END IF;

  -- ============================================================
  -- MODULE 6: KITCHEN OPERATIONS & CERTIFICATION
  -- ============================================================
  IF NOT EXISTS (SELECT 1 FROM module_items WHERE module_id = v_mod6_id AND title = 'Kitchen Operations Study Guide' AND type = 'info') THEN
    INSERT INTO module_items (module_id, title, type, content, order_index) VALUES (
      v_mod6_id,
      'Kitchen Operations Study Guide',
      'info',
      '<h2>Kitchen Station Responsibilities</h2>

<h3>Grill / Saute Station</h3>
<ul>
  <li>Responsible for all proteins: fish, chicken, steak, shrimp</li>
  <li>Must know cooking temperatures for every protein</li>
  <li>Maintains a clean grill surface throughout service</li>
  <li>Communicates pickup times to expo</li>
</ul>

<h3>Fry Station</h3>
<ul>
  <li>Walleye Bites, Fried Shrimp, Fish & Chips, Chicken Littles, Fried Walleye/Cod Sandwiches</li>
  <li>Monitor oil temperature and cleanliness</li>
  <li>Do not fry allergen-free items in contaminated oil</li>
  <li>Change oil per schedule — do not let oil go dark or smoky</li>
</ul>

<h3>Sauté / Sauce Station</h3>
<ul>
  <li>Pasta dishes: Pappardelle, Steak Alfredo, Mediterranean Shrimp Pasta</li>
  <li>White wine butter sauce + lump crab for Salmon New Orleans; Cajun cream sauce for Shrimp & Grits</li>
  <li>Jambalaya (risotto-based — communicate to FOH)</li>
</ul>

<h3>Expo Station</h3>
<ul>
  <li>Quality-check every plate before it leaves: correct dish, correct garnish, correct presentation</li>
  <li>Must know the Garnish Expectations guide by heart</li>
  <li>Communicate 86s immediately to FOH managers</li>
  <li>Maintain order tickets and ticket times</li>
</ul>

<h3>Opening Procedures (BOH)</h3>
<ul>
  <li>Check cooler and freezer temperatures — log them per your location''s protocol</li>
  <li>Pull prep list and begin daily prep items</li>
  <li>Stock the line for service: proteins, sauces, vegetables, starch</li>
  <li>Check dishwasher chemical levels and temperature</li>
  <li>Set up your station: cutting boards, pans, mise en place</li>
</ul>

<h3>Closing Procedures (BOH)</h3>
<ul>
  <li>Break down and deep-clean your station</li>
  <li>Label and date all remaining product before storing</li>
  <li>Store product in appropriate coolers following FIFO</li>
  <li>Clean and sanitize all surfaces, equipment, and floors</li>
  <li>Drain fryer oil and clean fryer per schedule</li>
  <li>Complete closing checklist and have manager sign off</li>
</ul>

<h3>Communication in the Kitchen</h3>
<ul>
  <li>Ticket times matter — if you are falling behind, communicate early, not late</li>
  <li>Alert expo and manager of any 86 items immediately</li>
  <li>If a dish does not meet quality standards — redo it. Do not send subpar food.</li>
  <li>Respect the chain of command: line cook → chef de partie → sous chef → executive chef/manager</li>
</ul>',
      1
    );
  END IF;

  IF NOT EXISTS (SELECT 1 FROM module_items WHERE module_id = v_mod6_id AND title = 'Kitchen Certification Quiz' AND type = 'quiz') THEN
    INSERT INTO module_items (module_id, title, type, content, order_index) VALUES (
      v_mod6_id,
      'Kitchen Certification Quiz',
      'quiz',
      '{"questions":[
        {"question":"Who is responsible for quality-checking every plate before it leaves the kitchen?","options":["The line cook who made the dish","The head chef only","The expo person","The manager on duty"],"correctIndex":2},
        {"question":"What must you do immediately when an item runs out during service?","options":["Wait until the end of service to tell anyone","Alert expo and FOH managers with an 86 immediately","Try to substitute a similar dish without telling anyone","Ask a server if they can manage without it"],"correctIndex":1},
        {"question":"At the fry station, why should you NOT fry allergen-free items in contaminated oil?","options":["It slows down the fryer","Cross-contact can transfer allergens to the allergen-free dish","It does not matter — the heat kills allergens","The oil flavor will be off"],"correctIndex":1},
        {"question":"Jambalaya at Mallards is made with:","options":["Traditional long-grain rice","Basmati rice","Quinoa","Risotto"],"correctIndex":3},
        {"question":"When should you communicate that you are falling behind on tickets?","options":["When you have missed every ticket time","When a manager yells at you","Early — before you fall too far behind","Only after service is over"],"correctIndex":2},
        {"question":"What is the first thing to do when starting opening procedures in the BOH?","options":["Begin cooking immediately","Check cooler and freezer temperatures and log them","Set up your station equipment first","Call in the day''s protein order"],"correctIndex":1},
        {"question":"What must be done with all remaining product at the end of service?","options":["Leave it on the line for the morning crew","Label and date it before storing in the appropriate cooler","Discard everything that was not used","Freeze everything regardless of product type"],"correctIndex":1},
        {"question":"If a dish does not meet quality standards, what should a cook do?","options":["Send it out and hope the guest doesn''t notice","Redo it — never send subpar food","Ask the server if the guest will notice","Only redo it if a manager requests it"],"correctIndex":1}
      ],"pass_threshold":80}',
      2
    );
  END IF;

  RAISE NOTICE 'Kitchen/BOH content seeded successfully.';
END $$;

-- SECTION 5: HOST TRACK
-- ============================================================
-- MALLARDS TRAINING APP — FOH SUPPORT STAFF / HOST TRACK CONTENT
-- Study Guides + Quizzes for all Host modules
-- Based on Host Training D1 & D2 outlines
-- Run in Supabase > SQL Editor > New Query
-- ============================================================

DO $$
DECLARE
  v_track_id   uuid;
  v_mod1_id    uuid;
  v_mod2_id    uuid;
  v_mod3_id    uuid;
  v_mod4_id    uuid;
  v_mod5_id    uuid;
BEGIN

  -- ── GET TRACK ──────────────────────────────────────────────
  -- Try "FOH Support Staff" first, then "Host" as fallback
  SELECT id INTO v_track_id FROM tracks WHERE name = 'FOH Support Staff' LIMIT 1;
  IF v_track_id IS NULL THEN
    SELECT id INTO v_track_id FROM tracks WHERE name = 'Host' LIMIT 1;
  END IF;
  IF v_track_id IS NULL THEN
    RAISE EXCEPTION 'Track "FOH Support Staff" or "Host" not found. Please create it in the admin panel first.';
  END IF;

  -- ── CREATE / FIND MODULES ──────────────────────────────────
  INSERT INTO modules (track_id, title, description, order_index)
  SELECT v_track_id, 'Welcome & Host Orientation', 'Your role as the first impression of Mallards', 1
  WHERE NOT EXISTS (SELECT 1 FROM modules WHERE track_id = v_track_id AND title = 'Welcome & Host Orientation');
  SELECT id INTO v_mod1_id FROM modules WHERE track_id = v_track_id AND title = 'Welcome & Host Orientation';

  INSERT INTO modules (track_id, title, description, order_index)
  SELECT v_track_id, 'Seating, Rotation & Table Management', 'Seating rotation, table mapping, and managing wait lists', 2
  WHERE NOT EXISTS (SELECT 1 FROM modules WHERE track_id = v_track_id AND title = 'Seating, Rotation & Table Management');
  SELECT id INTO v_mod2_id FROM modules WHERE track_id = v_track_id AND title = 'Seating, Rotation & Table Management';

  INSERT INTO modules (track_id, title, description, order_index)
  SELECT v_track_id, 'Phone, Reservations & To-Go', 'Answering phones, taking reservations, and handling to-go orders', 3
  WHERE NOT EXISTS (SELECT 1 FROM modules WHERE track_id = v_track_id AND title = 'Phone, Reservations & To-Go');
  SELECT id INTO v_mod3_id FROM modules WHERE track_id = v_track_id AND title = 'Phone, Reservations & To-Go';

  INSERT INTO modules (track_id, title, description, order_index)
  SELECT v_track_id, 'Menu Knowledge for Hosts', 'Know the menu well enough to answer guest questions confidently', 4
  WHERE NOT EXISTS (SELECT 1 FROM modules WHERE track_id = v_track_id AND title = 'Menu Knowledge for Hosts');
  SELECT id INTO v_mod4_id FROM modules WHERE track_id = v_track_id AND title = 'Menu Knowledge for Hosts';

  INSERT INTO modules (track_id, title, description, order_index)
  SELECT v_track_id, 'Host Certification', 'Celebrations, hours, happy hour, brunch, and host sign-off', 5
  WHERE NOT EXISTS (SELECT 1 FROM modules WHERE track_id = v_track_id AND title = 'Host Certification');
  SELECT id INTO v_mod5_id FROM modules WHERE track_id = v_track_id AND title = 'Host Certification';

  -- ============================================================
  -- MODULE 1: WELCOME & HOST ORIENTATION
  -- ============================================================
  IF NOT EXISTS (SELECT 1 FROM module_items WHERE module_id = v_mod1_id AND title = 'The Host Role Study Guide' AND type = 'info') THEN
    INSERT INTO module_items (module_id, title, type, content, order_index) VALUES (
      v_mod1_id,
      'The Host Role Study Guide',
      'info',
      '<h2>Your Role as a Mallards Host</h2>
<p>You are the first person every guest sees and the last person they interact with as they leave. The host role sets the tone for the entire experience — and it is one of the most important positions in the restaurant.</p>

<h3>The Host Mission</h3>
<ul>
  <li>Make every guest feel welcomed and valued the moment they walk in</li>
  <li>Set accurate wait time expectations — never guess low to make someone happy</li>
  <li>Keep the floor moving efficiently so servers can do their best work</li>
  <li>Be the calm center of chaos during peak service</li>
</ul>

<h3>First Impressions</h3>
<ul>
  <li>Greet every guest within <strong>30 seconds</strong> of entering — even if you are on the phone or with another guest</li>
  <li>Make eye contact, smile, and say: <em>"Welcome to Mallards! How many are in your party today?"</em></li>
  <li>If there is a wait, communicate it clearly: <em>"We have about a 20-minute wait for a table for 4. Can I get a name for your party?"</em></li>
  <li>Offer guests a menu to look at while they wait — it sets expectations and builds anticipation</li>
</ul>

<h3>Mallards Host Standards</h3>
<ul>
  <li><strong>Always smile</strong> — a genuine smile changes the entire guest experience</li>
  <li><strong>Know the menu</strong> — guests will ask you about popular dishes, specials, and allergens</li>
  <li><strong>Never say "I don''t know"</strong> without following up with "Let me find out for you"</li>
  <li><strong>Communicate with servers</strong> — before you seat a table, make sure the server is ready</li>
  <li><strong>Help clean and reset tables</strong> — during busy periods, a host who helps turn tables keeps the whole team moving</li>
  <li><strong>Card for alcohol</strong> — if you notice a guest appears under 40, remind the server to card them</li>
</ul>

<h3>Day 1 Orientation Activities</h3>
<ul>
  <li>Tour of the restaurant: host stand, dining room, bar, patio (if applicable), restrooms, back-of-house</li>
  <li>Learn the table numbering system — complete the blank table number test</li>
  <li>Shadow the host stand during a full service</li>
  <li>Learn the reservation and waitlist system used at your location</li>
  <li>Review the current menu: starters, soups, salads, mains, handhelds, beverages</li>
  <li>Order and eat one menu item</li>
</ul>',
      1
    );
  END IF;

  IF NOT EXISTS (SELECT 1 FROM module_items WHERE module_id = v_mod1_id AND title = 'Host Orientation Quiz' AND type = 'quiz') THEN
    INSERT INTO module_items (module_id, title, type, content, order_index) VALUES (
      v_mod1_id,
      'Host Orientation Quiz',
      'quiz',
      '{"questions":[
        {"question":"How quickly should a host greet a guest when they walk in?","options":["When you finish what you are doing","Within 30 seconds","Within 2 minutes","Only when they approach the host stand"],"correctIndex":1},
        {"question":"If there is a wait, what should you never do?","options":["Offer menus while they wait","Quote a low wait time just to make the guest happy","Ask for the party name","Communicate the wait clearly"],"correctIndex":1},
        {"question":"Why is the host role one of the most important in the restaurant?","options":["Hosts make the most tips","Hosts set the tone for the entire guest experience as the first and last impression","Hosts are responsible for food quality","Hosts manage all servers directly"],"correctIndex":1},
        {"question":"Before seating a table, what must a host always do?","options":["Check that the table is exactly the right size","Make sure the server is ready to receive the table","Wait for the manager to approve","Confirm the guests have seen the menu"],"correctIndex":1},
        {"question":"A guest asks you about the most popular dish. You should:","options":["Tell them you are just the host and cannot help","Recommend a favorite and share a talking point from the menu","Say \"I don''t know\" and move on","Transfer them to a server immediately"],"correctIndex":1},
        {"question":"If you notice guests who may be under 21, what should you do?","options":["Card them yourself at the host stand","Alert the server to card them","Ignore it — that is the bartender''s job","Ask the manager to handle it"],"correctIndex":1}
      ],"pass_threshold":80}',
      2
    );
  END IF;

  -- ============================================================
  -- MODULE 2: SEATING, ROTATION & TABLE MANAGEMENT
  -- ============================================================
  IF NOT EXISTS (SELECT 1 FROM module_items WHERE module_id = v_mod2_id AND title = 'Seating & Rotation Study Guide' AND type = 'info') THEN
    INSERT INTO module_items (module_id, title, type, content, order_index) VALUES (
      v_mod2_id,
      'Seating & Rotation Study Guide',
      'info',
      '<h2>Seating Rotation</h2>
<p>Seating rotation is one of the most important systems a host manages. When done correctly, it keeps servers'' sections balanced, prevents overload, and ensures every guest gets great service.</p>

<h3>How Rotation Works</h3>
<ul>
  <li>Servers are seated in order, rotating through each section</li>
  <li>Each server should receive approximately the same number of tables per shift</li>
  <li>Never skip a server without a reason (they are in the weeds, just got a large party, etc.)</li>
  <li>If a server is cut, remove them from rotation — do not seat their section after they leave</li>
  <li>Communicate with the floor manager if rotation needs adjustment</li>
</ul>

<h3>Seating Large Parties</h3>
<ul>
  <li>Parties of 6 or more typically require a reservation or advance notice — check your location''s policy</li>
  <li>For large parties, always confirm with the manager and the assigned server before seating</li>
  <li>Make sure the table is fully set and clean before bringing the party back</li>
  <li>Push tables together for large parties — do not ask guests to wait while you scramble</li>
</ul>

<h3>Table Turns</h3>
<ul>
  <li>A "table turn" is when a new party replaces a party that just left</li>
  <li>Fast, clean table turns keep the wait list moving and reduce guest frustration</li>
  <li>When a table is done, help bus and reset it if you are able — every minute counts during a rush</li>
  <li>Communicate available tables to the server and manager immediately when they open</li>
</ul>

<h3>Reading the Floor</h3>
<ul>
  <li>Know which tables are on dessert, which are on entrees, and which are getting their check</li>
  <li>Communicate with servers: "Table 14 looks like they are finishing up — is that turning soon?"</li>
  <li>Keep the wait list updated in real time — guests who feel forgotten leave</li>
</ul>

<h3>Special Seating Needs</h3>
<ul>
  <li>Guests with mobility issues: seat at accessible tables, preferably near an entrance</li>
  <li>Guests with young children: offer high chairs or boosters; seat away from narrow aisles</li>
  <li>Guests celebrating a birthday or anniversary: alert the server immediately so they can plan accordingly</li>
  <li>Large windows or patio requests: accommodate when possible; communicate wait times for preferred seating honestly</li>
</ul>',
      1
    );
  END IF;

  IF NOT EXISTS (SELECT 1 FROM module_items WHERE module_id = v_mod2_id AND title = 'Seating & Rotation Quiz' AND type = 'quiz') THEN
    INSERT INTO module_items (module_id, title, type, content, order_index) VALUES (
      v_mod2_id,
      'Seating & Rotation Quiz',
      'quiz',
      '{"questions":[
        {"question":"What is the purpose of a seating rotation?","options":["To give the best tables to the most experienced servers","To keep server sections balanced and prevent overloading one server","To fill the restaurant as fast as possible","To give guests their preferred sections always"],"correctIndex":1},
        {"question":"What should you do before bringing a large party to their table?","options":["Have them wait while you push tables together","Confirm with the manager and server, ensure the table is fully set and clean","Seat them and let the server figure it out","Check if they have a reservation only — nothing else needed"],"correctIndex":1},
        {"question":"When a server is cut at the end of their shift, you should:","options":["Continue seating their section to keep it busy","Remove them from rotation and stop seating their section","Ask them to stay until their last table leaves","Seat one more table so they make more tips"],"correctIndex":1},
        {"question":"When a table opens up, what should you do immediately?","options":["Wait until you have three open tables before telling anyone","Communicate it to the server and manager right away","Start seating the next guests without checking with anyone","Reset it yourself before saying anything"],"correctIndex":1},
        {"question":"A family walks in with a baby. What seating consideration should a host make?","options":["Seat them in the bar area","Offer a high chair or booster and seat them away from narrow aisles","Seat them far from other guests so the baby does not disturb anyone","Ask if they have a reservation before offering accommodations"],"correctIndex":1},
        {"question":"If a couple mentions they are celebrating an anniversary, what should you do?","options":["Seat them and say nothing","Alert the server immediately so they can plan accordingly","Ask them to mention it to the server themselves","Offer them a free dessert from the host stand"],"correctIndex":1}
      ],"pass_threshold":80}',
      2
    );
  END IF;

  -- ============================================================
  -- MODULE 3: PHONE, RESERVATIONS & TO-GO
  -- ============================================================
  IF NOT EXISTS (SELECT 1 FROM module_items WHERE module_id = v_mod3_id AND title = 'Phone & Reservations Study Guide' AND type = 'info') THEN
    INSERT INTO module_items (module_id, title, type, content, order_index) VALUES (
      v_mod3_id,
      'Phone & Reservations Study Guide',
      'info',
      '<h2>Answering the Phone at Mallards</h2>
<p>Every phone call is a guest experience. How you answer the phone shapes their first impression before they even walk in the door.</p>

<h3>Phone Greeting Script</h3>
<p>Use this greeting every time:</p>
<p><em>"Thank you for calling Mallards [Location Name], this is [Your Name] — how can I help you today?"</em></p>
<ul>
  <li>Speak clearly and warmly — smile while you talk, it comes through in your voice</li>
  <li>Never rush or sound impatient</li>
  <li>If you need to put a caller on hold, ask: <em>"Can I place you on a brief hold?"</em> — and return within 2 minutes</li>
</ul>

<h3>Taking Reservations</h3>
<ul>
  <li>Get: name, party size, date, time, and contact phone number</li>
  <li>Confirm: <em>"I have you down for [party size] on [date] at [time]. We will see you then!"</em></li>
  <li>Note any special occasions: birthday, anniversary, dietary restrictions</li>
  <li>Know your reservation system (OpenTable, Yelp, or in-house) before your first solo shift</li>
  <li>Large party reservations (8+) may require manager approval — confirm with your location''s policy</li>
</ul>

<h3>Handling Common Calls</h3>
<ul>
  <li><strong>Hours question:</strong> Know your location''s current hours for lunch, dinner, and brunch. When in doubt, ask a manager before answering.</li>
  <li><strong>Wait time question:</strong> Be honest. A 30-minute wait is better than promising 15 and delivering 35.</li>
  <li><strong>Menu question:</strong> Know the highlights — top dishes, any specials. For detailed allergen questions, offer to have a manager call back.</li>
  <li><strong>Complaint call:</strong> Listen fully, apologize, and take down their name and contact info. Alert the manager immediately — never promise comps on your own.</li>
</ul>

<h3>To-Go Orders</h3>
<ul>
  <li>Take the full order, repeat it back to confirm</li>
  <li>Give an accurate time estimate — check with the kitchen if unsure</li>
  <li>Ensure to-go orders are packaged correctly: lids secure, sauces bagged separately, utensils included</li>
  <li>When the guest arrives, have their order ready and confirm the name</li>
  <li>Ring in to-go orders correctly in the POS — ask your trainer how your location handles this</li>
</ul>

<h3>Gift Cards & Event Inquiries</h3>
<ul>
  <li>For gift card questions, refer guests to your manager or the front desk</li>
  <li>For private events or large party inquiries, take a name and number and have the manager follow up</li>
</ul>',
      1
    );
  END IF;

  IF NOT EXISTS (SELECT 1 FROM module_items WHERE module_id = v_mod3_id AND title = 'Phone & Reservations Quiz' AND type = 'quiz') THEN
    INSERT INTO module_items (module_id, title, type, content, order_index) VALUES (
      v_mod3_id,
      'Phone & Reservations Quiz',
      'quiz',
      '{"questions":[
        {"question":"What information must you always get when taking a reservation?","options":["Name only — the rest is optional","Name, party size, date, time, and contact phone number","Just name and party size","Name, email, and credit card to hold the reservation"],"correctIndex":1},
        {"question":"A guest asks for a wait time estimate. You are not sure how long it will be. You should:","options":["Guess low — you want to make them happy","Be honest and give your best accurate estimate, even if it is longer","Tell them you have no idea","Say it depends and offer no estimate"],"correctIndex":1},
        {"question":"A caller has a detailed allergen question about the menu. You should:","options":["Answer it yourself with your best guess","Tell them everything is allergen-free","Offer to have a manager call them back with accurate information","Transfer them to the kitchen"],"correctIndex":2},
        {"question":"What is the correct Mallards phone greeting?","options":["\"Hello, what do you need?\"","\"Thank you for calling Mallards [location], this is [name] — how can I help you today?\"","\"Mallards, hold please\"","\"Hi, thanks for calling — what can I get you?\""],"correctIndex":1},
        {"question":"A caller complains about a bad experience. What should you do?","options":["Apologize, take their info, and alert the manager — never promise comps yourself","Offer them a free meal immediately to make it right","Tell them to come back and talk to a manager in person","Transfer them to hold and hope they hang up"],"correctIndex":0},
        {"question":"When should you put a caller on hold?","options":["Whenever you need a moment to think","Only when absolutely necessary — ask first and return within 2 minutes","Anytime you are busy with another guest","As soon as the phone rings to manage your workflow"],"correctIndex":1},
        {"question":"What should always be included when packaging a to-go order?","options":["Just the food — guests supply their own extras","Properly lidded containers, sauces bagged separately, and utensils included","Only utensils if the guest asks","Just confirm the name — packaging is the kitchen''s job"],"correctIndex":1}
      ],"pass_threshold":80}',
      2
    );
  END IF;

  -- ============================================================
  -- MODULE 4: MENU KNOWLEDGE FOR HOSTS
  -- ============================================================
  IF NOT EXISTS (SELECT 1 FROM module_items WHERE module_id = v_mod4_id AND title = 'Host Menu Knowledge Study Guide' AND type = 'info') THEN
    INSERT INTO module_items (module_id, title, type, content, order_index) VALUES (
      v_mod4_id,
      'Host Menu Knowledge Study Guide',
      'info',
      '<h2>Menu Knowledge for Hosts</h2>
<p>You do not need to know every ingredient, but you should know the highlights well enough to describe popular items, make recommendations, and handle common guest questions confidently.</p>

<h3>Top Starter Recommendations</h3>
<ul>
  <li><strong>Walleye Bites</strong> — Our signature Minnesota walleye, lightly breaded and fried. Great for first-timers.</li>
  <li><strong>Seafood "Guac"</strong> — Elevated avocado topped with shrimp and crab. A guest favorite.</li>
  <li><strong>Lump Crab Queso</strong> — Warm queso with real lump crab. Perfect for sharing.</li>
  <li><strong>Jalapeño Corn Bread</strong> — Warm, baked in-house, served with honey butter. Great add-on for any table.</li>
</ul>

<h3>Top Entrée Recommendations</h3>
<ul>
  <li><strong>Salmon New Orleans</strong> — Blackened salmon with Cajun cream sauce. A Mallards signature.</li>
  <li><strong>Shrimp and Grits</strong> — Southern comfort with Gulf shrimp, andouille sausage, and Cajun cream sauce.</li>
  <li><strong>Wild Mushroom Pappardelle</strong> — Wide ribbon pasta with wild mushrooms and truffle oil. Great for non-seafood guests.</li>
  <li><strong>Grammy''s Meatloaf</strong> — House-made meatloaf with mashed potatoes. Comfort classic.</li>
  <li><strong>Captain''s Ribeye</strong> — Our most premium entrée: 14 oz. center-cut ribeye.</li>
</ul>

<h3>Guest FAQs Hosts Should Know</h3>
<ul>
  <li><strong>"Do you have gluten-free options?"</strong> — The Flourless Chocolate Cake (dessert) is gluten-free. Tell them to ask their server for full allergen guidance.</li>
  <li><strong>"Is there something for non-seafood eaters?"</strong> — Grammy''s Meatloaf, Crispy Lemon Chicken, Hot Chicken & Waffles, Wild Mushroom Pappardelle, and Chicken Littles.</li>
  <li><strong>"What are your specials today?"</strong> — Ask the manager before your shift what the daily specials are.</li>
  <li><strong>"Is the Shrimp Boil big enough for 2?"</strong> — Yes, it is designed for 2 guests and takes 25–30 minutes.</li>
</ul>

<h3>Hours, Happy Hour & Brunch</h3>
<ul>
  <li>Know your location''s current lunch, dinner, and brunch hours — confirm with your manager</li>
  <li><strong>Happy Hour:</strong> Typically weekdays with discounted drinks and appetizers including Chips & Dip and Cheeseburger Sliders</li>
  <li><strong>Brunch:</strong> Typically weekends — features Bottomless Mimosas, Bloody Mary bar, and Hot Chicken & Waffles</li>
  <li>Always confirm current hours and specials with your manager before telling guests</li>
</ul>

<h3>Celebrations</h3>
<ul>
  <li>If a guest mentions a birthday or anniversary, note it when you seat them and alert the server</li>
  <li>The kitchen or server may be able to prepare a special dessert — check with your manager</li>
  <li>Let the server know immediately — they need time to plan a surprise</li>
</ul>',
      1
    );
  END IF;

  IF NOT EXISTS (SELECT 1 FROM module_items WHERE module_id = v_mod4_id AND title = 'Host Menu Knowledge Quiz' AND type = 'quiz') THEN
    INSERT INTO module_items (module_id, title, type, content, order_index) VALUES (
      v_mod4_id,
      'Host Menu Knowledge Quiz',
      'quiz',
      '{"questions":[
        {"question":"A guest asks if there is anything gluten-free. What should you tell them?","options":["Everything on the menu is gluten-free","The Flourless Chocolate Cake is gluten-free — tell them to ask their server for full allergen guidance","We do not have any gluten-free options","Only the salads are gluten-free"],"correctIndex":1},
        {"question":"A guest says they do not eat seafood. Which entrée would you NOT recommend?","options":["Grammy''s Meatloaf","Wild Mushroom Pappardelle","Salmon New Orleans","Crispy Lemon Chicken"],"correctIndex":2},
        {"question":"The Shrimp Boil for 2 is designed for how many guests and takes how long?","options":["1 guest, 15 minutes","4 guests, 20 minutes","2 guests, 25–30 minutes","2 guests, 10–15 minutes"],"correctIndex":2},
        {"question":"What are the two food options typically available during Happy Hour?","options":["Wings and Walleye Bites","Chips & Dip and Cheeseburger Sliders","Jerk Nachos and Crab Queso","Jalapeño Corn Bread and Smoked Salmon"],"correctIndex":1},
        {"question":"When a couple mentions they are celebrating a birthday as you seat them, you should:","options":["Congratulate them and seat them normally","Note it and immediately alert the server so they can plan accordingly","Ask if they want a special dessert yourself","Wait until they mention it to the server"],"correctIndex":1},
        {"question":"Brunch at Mallards typically features which signature drink offering?","options":["Free wine with any entree","Bottomless Mimosas and a Bloody Mary bar","Two-for-one cocktails","Happy Hour pricing all day"],"correctIndex":1},
        {"question":"A guest asks what the daily specials are. You should:","options":["Describe whatever sounds good","Say you are not sure and suggest they ask their server","Ask the manager before your shift and be ready to answer confidently","Tell them there are no specials today"],"correctIndex":2}
      ],"pass_threshold":80}',
      2
    );
  END IF;

  -- ============================================================
  -- MODULE 5: HOST CERTIFICATION
  -- ============================================================
  IF NOT EXISTS (SELECT 1 FROM module_items WHERE module_id = v_mod5_id AND title = 'Host Certification Study Guide' AND type = 'info') THEN
    INSERT INTO module_items (module_id, title, type, content, order_index) VALUES (
      v_mod5_id,
      'Host Certification Study Guide',
      'info',
      '<h2>Host Certification: Policies & Standards</h2>

<h3>Opening Host Procedures</h3>
<ul>
  <li>Arrive in full uniform: clean clothes, non-slip shoes, hair pulled back</li>
  <li>Review the reservation book for the day — flag large parties, celebrations, VIPs</li>
  <li>Confirm floor layout with manager: are all sections open? Any tables reserved?</li>
  <li>Ensure host stand is stocked: menus (clean, no damage), kids menus, to-go menus</li>
  <li>Check and stock take-out bags, to-go containers, and receipt materials</li>
  <li>Confirm hours for the shift: lunch cut-off, happy hour window, kitchen close</li>
</ul>

<h3>Closing Host Procedures</h3>
<ul>
  <li>Ensure all guests have been taken care of before leaving your post</li>
  <li>Clean and organize the host stand: menus wiped down, papers organized</li>
  <li>Return high chairs and booster seats to storage</li>
  <li>Complete any assigned side work: sweeping entryway, wiping down host podium</li>
  <li>Communicate any issues or notable guest feedback to the closing manager</li>
</ul>

<h3>Handling Difficult Situations</h3>
<ul>
  <li><strong>Unhappy guest on the wait list:</strong> Empathize, give an honest update, offer a menu while they wait</li>
  <li><strong>Guest who was quoted a wrong wait time:</strong> Apologize, alert the manager, do everything you can to seat them quickly</li>
  <li><strong>Large party without a reservation:</strong> Check with the manager on floor capacity before making any promises</li>
  <li><strong>Guest who cuts in line:</strong> Politely explain the wait list process — every guest was quoted a time and is waiting their turn</li>
</ul>

<h3>Dress Code & Professionalism</h3>
<ul>
  <li>Follow your location''s uniform policy — ask your manager for specifics</li>
  <li>No visible tattoos that are offensive or graphic (policy may vary by location)</li>
  <li>No strong perfume or cologne — guests and food do not mix well with heavy fragrance</li>
  <li>Maintain a positive, professional demeanor even when things are hectic</li>
</ul>

<h3>The Host Role and Teamwork</h3>
<ul>
  <li>A great host keeps the whole restaurant running smoothly</li>
  <li>Help servers: bus tables, bring water to guests, deliver menus to newly seated parties</li>
  <li>Communicate constantly: with servers, managers, and the bar about table availability and timing</li>
  <li>If you see something that needs to be done — do it. Do not wait to be asked.</li>
</ul>',
      1
    );
  END IF;

  IF NOT EXISTS (SELECT 1 FROM module_items WHERE module_id = v_mod5_id AND title = 'Host Certification Quiz' AND type = 'quiz') THEN
    INSERT INTO module_items (module_id, title, type, content, order_index) VALUES (
      v_mod5_id,
      'Host Certification Quiz',
      'quiz',
      '{"questions":[
        {"question":"What should a host do first when arriving for their shift?","options":["Start seating guests immediately","Review the reservation book for large parties, celebrations, and VIPs","Check their phone for messages","Ask the manager if there is anything to do"],"correctIndex":1},
        {"question":"A large party arrives without a reservation. You should:","options":["Seat them immediately — they are already here","Tell them there is no way to seat them","Check with the manager on floor capacity before making any promises","Tell them you are fully booked regardless of actual availability"],"correctIndex":2},
        {"question":"What should you do with menus at the start and end of every shift?","options":["Leave them on tables for guests","Ensure they are clean and undamaged at the host stand","Replace them only when a manager requests it","Stack them in the back for storage after service"],"correctIndex":1},
        {"question":"A guest is upset because they were quoted 15 minutes and have now waited 30. You should:","options":["Avoid them and hope they get seated soon","Blame the kitchen for the delay","Apologize sincerely, alert the manager, and do everything possible to seat them quickly","Tell them wait times are estimates and not guaranteed"],"correctIndex":2},
        {"question":"How can a host help the team during a busy service beyond just seating guests?","options":["By staying strictly at the host stand","By helping bus tables, bring water, deliver menus, and communicate table availability","By taking drink orders to help servers","By helping the kitchen with prep work"],"correctIndex":1},
        {"question":"What is the correct response to a guest who tries to cut ahead of others on the wait list?","options":["Let them jump the list to avoid a scene","Seat them quickly if they look important","Politely explain the wait list process — every guest was quoted a time and is waiting their turn","Ignore them and hope they go away"],"correctIndex":2},
        {"question":"What information should you confirm with the manager before each shift?","options":["What the servers'' last names are","Which sections are open, reserved tables, hours, and any special events","How many reservations were made last week","What the weather is like outside"],"correctIndex":1}
      ],"pass_threshold":80}',
      2
    );
  END IF;

  RAISE NOTICE 'FOH Support Staff / Host content seeded successfully.';
END $$;
