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
