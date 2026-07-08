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
