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
