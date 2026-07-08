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
