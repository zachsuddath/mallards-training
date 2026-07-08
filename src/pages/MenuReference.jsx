import { useState } from 'react'

const MENU = {
  Starters: [
    {
      name: 'Walleye Bites',
      desc: 'Can be pan seared. Served with tartar sauce and lemon.',
      allergens: ['Fish', 'Gluten'],
      tags: [],
    },
    {
      name: 'Crab Cakes',
      desc: '2 cakes formed and seared to order. Served with mango salsa, tartar sauce and remoulade.',
      allergens: ['Shellfish', 'Gluten'],
      tags: [],
    },
    {
      name: 'Jerk Chicken Nachos',
      desc: 'House-made tortilla chips piled high with jerk chicken, pineapple mango salsa, melted cheese blend and avocado sour cream. Sauces can be on the side.',
      allergens: ['Dairy'],
      tags: [],
    },
    {
      name: 'Seafood "Guac"',
      desc: 'Chopped cooked shrimp, lump crab, pico, lime juice, salt and pepper. Served with house fried tortilla chips.',
      allergens: ['Shellfish'],
      tags: [],
    },
    {
      name: 'Lump Crab Queso',
      desc: 'Dill cream cheese mixed with capers, hot banana sauce, alfredo sauce and lump crab meat. Served with tortilla chips.',
      allergens: ['Shellfish', 'Dairy', 'Gluten'],
      tags: [],
    },
    {
      name: 'Elote Corn Fritters',
      desc: '3 corn fritters breaded to order. Served with 2 limes, bang bang sauce and avo crema. Sauces can be on the side.',
      allergens: ['Gluten'],
      tags: ['Vegetarian'],
    },
    {
      name: 'Smoked Salmon Plate',
      desc: 'Honey smoked salmon, lemon dill cream cheese, capers and cucumber. Served with toasted baguette.',
      allergens: ['Fish', 'Dairy', 'Gluten'],
      tags: [],
    },
    {
      name: 'Chicken Wings',
      desc: '1 pound (8–10 wings) flash fried. Sauce choices: Buffalo, Cajun Dry Rub, Nashville Hot, Korean BBQ, Sweet Chipotle, Spicy NOLA. Served with ranch or blue cheese and celery.',
      allergens: ['Gluten Friendly'],
      tags: [],
    },
    {
      name: 'Cheeseburger Sliders',
      desc: '4 smash patties on Hawaiian rolls with American cheese and house pickles.',
      allergens: ['Gluten', 'Dairy'],
      tags: [],
    },
    {
      name: 'Jalapeño Corn Bread',
      desc: 'Homemade corn bread topped with candied jalapeños. Served with honey butter. Jalapeños cannot be removed before serving but can be taken off once served.',
      allergens: ['Gluten', 'Dairy'],
      tags: [],
    },
    {
      name: 'Boudin Balls',
      desc: 'Cajun pork and rice sausage balls fried crispy.',
      allergens: ['Gluten', 'Pork'],
      tags: [],
    },
  ],

  'Soups & Salads': [
    {
      name: 'Bread Bowl Soup',
      desc: 'Choice of soup in a freshly baked sourdough bread bowl. Also available as a cup or bowl.',
      allergens: ['Gluten', 'Dairy', 'Shellfish (varies)'],
      tags: [],
    },
    {
      name: 'Beef Chili',
      desc: 'House-made beef and bean chili, slow simmered. Can add sour cream, cheese and green onions.',
      allergens: [],
      tags: [],
    },
    {
      name: 'Garden Salad',
      desc: 'Mixed greens, carrots, croutons, cheese, cucumber and tomato. Can add protein, remove croutons.',
      allergens: ['Gluten (croutons)', 'Dairy'],
      tags: [],
    },
    {
      name: 'Caesar Salad',
      desc: 'Classic Caesar. Can add protein, remove croutons.',
      allergens: ['Gluten (croutons)', 'Dairy', 'Fish (anchovy in dressing)'],
      tags: [],
    },
    {
      name: 'Mediterranean Power Bowl',
      desc: 'Dressing is a mix of Caesar and citrus vinaigrette — can be on the side. Can remove farro for gluten-free. Can add protein.',
      allergens: ['Gluten (farro)', 'Dairy'],
      tags: ['Vegetarian'],
    },
    {
      name: 'Southwest Shrimp Cobb',
      desc: 'Gluten free. Southwest ranch dressing comes on the side. Can sub chicken for grilled shrimp.',
      allergens: ['Shellfish'],
      tags: ['Gluten Free'],
    },
    {
      name: 'Thai Peanut Chicken Chip',
      desc: 'Chopped cabbage, mixed greens, chopped chicken, pickled onion, cilantro, lime — tossed in citrus vinaigrette, topped with homemade peanut sauce and sriracha aioli.',
      allergens: ['⚠️ PEANUTS'],
      tags: [],
      warning: true,
    },
  ],

  'Fish House': [
    {
      name: 'Mediterranean Shrimp Pasta',
      desc: 'Linguini with shrimp in a white wine herb butter, finished with stewed tomatoes, feta cheese, olive and caper tapenade and crushed red pepper.',
      allergens: ['Shellfish', 'Gluten'],
      tags: [],
    },
    {
      name: 'Salmon New Orleans',
      desc: 'Blackened salmon topped with lump crab, fresh tomatoes and white wine butter sauce. Served on mashed potatoes.',
      allergens: ['⚠️ Shellfish (lump crab on top)', 'Gluten', 'Dairy'],
      tags: [],
      warning: true,
    },
    {
      name: 'Shrimp and Grits',
      desc: 'Cheesy grits, 8 blackened shrimp, sautéed green peppers and onion, Cajun cream sauce and tomato bacon jam and cilantro.',
      allergens: ['Shellfish'],
      tags: [],
    },
    {
      name: 'Shrimp Boil for 2',
      desc: 'Potatoes, corn, andouille and shrimp boiled in a bag — spicy or mild. Comes with lemon, cocktail sauce and drawn butter. Can add 1 lb snow crab for $20.',
      allergens: ['Shellfish'],
      tags: ['⏱️ 25–30 min'],
    },
    {
      name: 'Fried Shrimp',
      desc: '8 breaded jumbo shrimp served with fries, slaw, cocktail sauce, lemon and ketchup.',
      allergens: ['Shellfish', 'Gluten'],
      tags: [],
    },
    {
      name: 'Fish and Chips',
      desc: '3 pieces of breaded cod served with fries, slaw, tartar, lemon and ketchup.',
      allergens: ['Fish', 'Gluten'],
      tags: [],
    },
    {
      name: 'Shrimp and Sausage Gumbo',
      desc: 'Rich Louisiana stew of shrimp and smoked sausage. Served with cream risotto and a slice of cornbread.',
      allergens: ['Shellfish', 'Dairy', 'Gluten'],
      tags: [],
    },
    {
      name: 'Barramundi Rodrigo',
      desc: 'Asian seabass pan seared served with coconut risotto, jalapeño-lime pesto and garnished with a lime.',
      allergens: ['Fish'],
      tags: [],
    },
    {
      name: 'Pistachio Crusted Salmon',
      desc: 'Pistachio crusted Atlantic salmon served with creamy risotto and red pepper beurre blanc. Can be made without the crust.',
      allergens: ['Fish', '⚠️ Tree Nuts (pistachio)', 'Gluten', 'Dairy'],
      tags: [],
      warning: true,
    },
    {
      name: 'Simply Prepared',
      desc: 'Choice of Barramundi, Atlantic Cod, Ahi Tuna, Atlantic Salmon, or Canadian Walleye. Served with quinoa and rice medley and seasonal vegetables. Sauce: Cajun Cream, Hollandaise, Lemon Butter, Pineapple Mango Salsa, or Sesame Soy Ginger.',
      allergens: ['Varies by fish and sauce'],
      tags: [],
    },
  ],

  Specialties: [
    {
      name: 'Wild Mushroom Pappardelle',
      desc: 'Fresh herbs, white wine and cream tossed with pappardelle pasta. Can add chicken or shrimp.',
      allergens: ['Gluten', 'Dairy'],
      tags: ['Vegetarian'],
    },
    {
      name: 'Steak Alfredo',
      desc: 'Linguine, 4 oz filet cooked to order, house alfredo sauce, topped with onion straws.',
      allergens: ['Gluten', 'Dairy'],
      tags: [],
    },
    {
      name: 'Jambalaya',
      desc: 'Risotto topped with sautéed chicken, shrimp, andouille, green pepper, onion and tomato. Note: risotto-based, not traditional rice.',
      allergens: ['Shellfish'],
      tags: ['⚠️ Risotto, not rice'],
    },
    {
      name: 'Crispy Lemon Chicken',
      desc: 'Fried chicken breast topped with lemon butter and capers served over mashed potatoes.',
      allergens: ['Gluten', 'Dairy'],
      tags: [],
    },
    {
      name: 'Chicken Littles',
      desc: 'Hand battered chicken fingers, fries, garlic toast, house pickles, coleslaw and comeback sauce. Available Tennessee Hot or Southern Fried.',
      allergens: ['Gluten', 'Dairy'],
      tags: [],
    },
    {
      name: 'Hot Chicken and Waffles',
      desc: '4 house breaded chicken tenders in Nashville hot sauce stacked between 3 waffles with syrup and honey butter. Spicy.',
      allergens: ['Gluten'],
      tags: ['🌶️ Spicy'],
    },
    {
      name: "Grammy's Meatloaf",
      desc: 'House-made meatloaf topped with sweet tomato glaze. Served with mashed potatoes and green beans, topped with fried onions.',
      allergens: ['Gluten', 'Dairy'],
      tags: [],
    },
    {
      name: 'Surf and Turf',
      desc: '4 oz filet cooked to order, 8 jumbo shrimp fried NOLA or scampi style, served with garlic mashed potatoes.',
      allergens: ['Shellfish'],
      tags: ['Gluten Free'],
    },
    {
      name: "Captain's Ribeye",
      desc: '14 oz ribeye cooked to order, served with sautéed garlic green beans and garlic mashed potatoes. Topped with Cajun butter. Always ask temperature.',
      allergens: ['Dairy'],
      tags: [],
    },
  ],

  Handhelds: [
    {
      name: 'Mallards Melt',
      desc: 'Smash patty layered with creamy pimento cheese, served with bacon jam and Nashville aioli on garlic toast.',
      allergens: ['Gluten', 'Dairy'],
      tags: [],
    },
    {
      name: 'Tennessee Hot Chicken Sandwich',
      desc: 'Breaded chicken breast in house Nashville hot sauce, served on a bun with comeback sauce and slaw.',
      allergens: ['Gluten'],
      tags: ['🌶️ Spicy'],
    },
    {
      name: 'Blackened Fish Tacos',
      desc: '3 pan seared blackened walleye tacos on corn tortillas, topped with pico, avo cream, sriracha and cilantro.',
      allergens: ['Fish'],
      tags: ['Gluten Free'],
    },
    {
      name: 'Ahi Tuna Tacos',
      desc: 'Sesame crusted ahi tuna, sesame soy, spicy slaw, bang bang sauce and fresh green onions.',
      allergens: ['Fish'],
      tags: ['Gluten Free'],
    },
    {
      name: 'Lobster Roll',
      desc: 'Toasted New England bun, lobster salad (celery, greens, mayo), melted butter and fries.',
      allergens: ['Shellfish', 'Gluten'],
      tags: [],
    },
    {
      name: 'Turkey Club',
      desc: 'Sliced deli turkey on cranberry wild rice bread with greens, tomato and cranberry aioli.',
      allergens: ['Gluten'],
      tags: [],
    },
    {
      name: 'Fried Walleye Sandwich',
      desc: 'Hand breaded walleye on a bun with lettuce, tomato, onion and tartar. Served with chips.',
      allergens: ['Fish', 'Gluten', 'Dairy'],
      tags: [],
    },
    {
      name: 'Meatloaf Sandwich',
      desc: 'Garlic toast topped with seared mashed potatoes, meatloaf and fried onions drizzled with spicy BBQ sauce.',
      allergens: ['Gluten', 'Dairy'],
      tags: [],
    },
    {
      name: 'Fried Cod Sandwich',
      desc: 'Hand breaded cod, melted American cheese on a bun with lettuce, onion and tartar. Served with chips.',
      allergens: ['Fish', 'Gluten', 'Dairy'],
      tags: [],
    },
    {
      name: 'Seafood Roll',
      desc: 'Chilled lobster and Cajun shrimp on a warm New England bun, mayo, melted butter, celery and green onion. Served with fries.',
      allergens: ['Shellfish', 'Gluten'],
      tags: [],
    },
    {
      name: 'Smash Burger',
      desc: 'Toasted bun, smash patty, lettuce, tomato, red onion and American cheese. Garlic aioli on the side.',
      allergens: ['Gluten', 'Dairy'],
      tags: [],
    },
  ],

  'Sides & Desserts': [
    {
      name: 'Mac and Cheese',
      desc: 'Cavatappi noodles tossed with creamy American cheese sauce. Can add lobster for $9.99.',
      allergens: ['Gluten', 'Dairy'],
      tags: [],
    },
    {
      name: 'Daily Bread',
      desc: 'Half a French loaf warmed to order with house berry jam, honey butter and pimento cheese.',
      allergens: ['Gluten'],
      tags: [],
    },
    {
      name: 'Veggie Fries',
      desc: 'Green beans and carrots flash fried, tossed with salt and pepper, served with ranch.',
      allergens: [],
      tags: ['Gluten Friendly'],
    },
    {
      name: 'Cajun Fries',
      desc: 'Fries tossed in Cajun seasoning with spicy remoulade.',
      allergens: ['Gluten'],
      tags: [],
    },
    {
      name: 'Fresh Steamed Broccoli',
      desc: 'Broccoli sautéed in butter and garlic.',
      allergens: ['Dairy'],
      tags: [],
    },
    {
      name: 'Green Beans',
      desc: 'Sautéed garlicky green beans.',
      allergens: [],
      tags: [],
    },
    {
      name: 'Key Lime Pie',
      desc: 'House made, topped with whipped cream and lime zest.',
      allergens: ['Gluten', 'Dairy'],
      tags: ['Dessert'],
    },
    {
      name: 'Flourless Chocolate Cake',
      desc: 'Rich chocolate cake topped with whipped cream and triple berry jam.',
      allergens: ['Dairy'],
      tags: ['Dessert', 'Gluten Free'],
    },
    {
      name: 'Hot Apple Pie',
      desc: 'Apple pie served on a hot skillet, topped with vanilla bean ice cream and house made Jack Daniels caramel topping.',
      allergens: ['Gluten', 'Dairy'],
      tags: ['Dessert'],
    },
    {
      name: 'Cheesecake',
      desc: 'Topped with sour cream topping, garnished with whipped cream and a fresh strawberry. Graham cracker crust.',
      allergens: ['Gluten', 'Dairy'],
      tags: ['Dessert'],
    },
  ],
}

const ALLERGEN_COLORS = {
  'Shellfish': '#E67E22',
  '⚠️ Shellfish (lump crab on top)': '#C0392B',
  'Fish': '#2980B9',
  '⚠️ PEANUTS': '#C0392B',
  '⚠️ Tree Nuts (pistachio)': '#C0392B',
  'Gluten': '#8E44AD',
  'Gluten Free': '#27AE60',
  'Gluten Friendly': '#27AE60',
  'Dairy': '#16A085',
}

const TAG_COLORS = {
  'Gluten Free': '#27AE60',
  'Gluten Friendly': '#2E86AB',
  'Vegetarian': '#27AE60',
  '⏱️ 25–30 min': '#E67E22',
  '⚠️ Risotto, not rice': '#E67E22',
  '🌶️ Spicy': '#C0392B',
  'Dessert': '#8E44AD',
}

function AllergenBadge({ label }) {
  const isWarning = label.startsWith('⚠️')
  const bg = isWarning ? 'rgba(192,57,43,0.1)' : 'rgba(142,68,173,0.08)'
  const color = isWarning ? '#C0392B' : '#5B2D8E'
  if (label === 'Fish') { return <span style={{ background: 'rgba(41,128,185,0.1)', color: '#1A5276', ...badgeStyle }}>{label}</span> }
  if (label.includes('Shellfish')) { return <span style={{ background: 'rgba(230,126,34,0.1)', color: '#784212', ...badgeStyle }}>{label}</span> }
  if (label.includes('Dairy')) { return <span style={{ background: 'rgba(22,160,133,0.1)', color: '#0E6655', ...badgeStyle }}>{label}</span> }
  if (label.includes('Gluten Friendly') || label.includes('Gluten Free')) { return <span style={{ background: 'rgba(39,174,96,0.1)', color: '#1A6B3C', ...badgeStyle }}>{label}</span> }
  return <span style={{ background: bg, color, ...badgeStyle }}>{label}</span>
}

const badgeStyle = {
  display: 'inline-flex', alignItems: 'center',
  padding: '2px 8px', borderRadius: 999, fontSize: 11,
  fontWeight: 600, whiteSpace: 'nowrap',
}

function TagBadge({ label }) {
  const color = TAG_COLORS[label] || '#6B7280'
  return (
    <span style={{ background: `${color}18`, color, border: `1px solid ${color}40`, ...badgeStyle }}>
      {label}
    </span>
  )
}

function MenuItem({ item }) {
  return (
    <div style={{
      background: 'white',
      border: item.warning ? '1.5px solid rgba(192,57,43,0.3)' : '1px solid #E5E7EB',
      borderRadius: 10,
      padding: '14px 16px',
      display: 'flex',
      flexDirection: 'column',
      gap: 6,
    }}>
      <div style={{ display: 'flex', alignItems: 'flex-start', justifyContent: 'space-between', gap: 8 }}>
        <div style={{ fontWeight: 700, fontSize: 14, color: '#1A1A2E' }}>{item.name}</div>
        {item.tags.length > 0 && (
          <div style={{ display: 'flex', gap: 4, flexWrap: 'wrap', justifyContent: 'flex-end' }}>
            {item.tags.map(t => <TagBadge key={t} label={t} />)}
          </div>
        )}
      </div>
      <div style={{ fontSize: 13, color: '#6B7280', lineHeight: 1.5 }}>{item.desc}</div>
      {item.allergens.length > 0 && (
        <div style={{ display: 'flex', gap: 4, flexWrap: 'wrap', marginTop: 2 }}>
          {item.allergens.map(a => <AllergenBadge key={a} label={a} />)}
        </div>
      )}
    </div>
  )
}

export default function MenuReference() {
  const categories = Object.keys(MENU)
  const [active, setActive] = useState(categories[0])
  const [search, setSearch] = useState('')

  const filtered = search.trim()
    ? categories.reduce((acc, cat) => {
        const items = MENU[cat].filter(
          i =>
            i.name.toLowerCase().includes(search.toLowerCase()) ||
            i.desc.toLowerCase().includes(search.toLowerCase()) ||
            i.allergens.some(a => a.toLowerCase().includes(search.toLowerCase()))
        )
        if (items.length) acc.push({ cat, items })
        return acc
      }, [])
    : [{ cat: active, items: MENU[active] }]

  return (
    <div>
      <div className="page-header">
        <div className="page-title">🍽️ Menu Reference</div>
        <div className="page-subtitle">Full 2026 menu with descriptions and allergen info</div>
      </div>

      {/* Search */}
      <div style={{ marginBottom: 16 }}>
        <input
          className="form-input"
          placeholder="Search by dish, ingredient, or allergen…"
          value={search}
          onChange={e => setSearch(e.target.value)}
          style={{ maxWidth: 420 }}
        />
      </div>

      {/* Allergen legend */}
      <div style={{ display: 'flex', flexWrap: 'wrap', gap: 6, marginBottom: 20 }}>
        {[
          ['⚠️ = Critical allergen warning', '#C0392B'],
          ['🟠 Shellfish', '#784212'],
          ['🔵 Fish', '#1A5276'],
          ['🟣 Gluten', '#5B2D8E'],
          ['🟢 Dairy', '#0E6655'],
          ['✅ Gluten Free', '#1A6B3C'],
        ].map(([label, color]) => (
          <span key={label} style={{ fontSize: 11, color, fontWeight: 600, background: `${color}12`, padding: '3px 8px', borderRadius: 6 }}>
            {label}
          </span>
        ))}
      </div>

      {/* Category tabs (hidden when searching) */}
      {!search.trim() && (
        <div style={{
          display: 'flex', gap: 6, flexWrap: 'wrap', marginBottom: 16,
        }}>
          {categories.map(cat => (
            <button
              key={cat}
              onClick={() => setActive(cat)}
              style={{
                padding: '7px 14px',
                borderRadius: 999,
                border: 'none',
                fontSize: 13,
                fontWeight: 600,
                cursor: 'pointer',
                background: active === cat ? '#1B3A6B' : '#F3F4F6',
                color: active === cat ? 'white' : '#374151',
                transition: 'all 0.15s',
              }}
            >
              {cat}
            </button>
          ))}
        </div>
      )}

      {/* Items */}
      {filtered.map(({ cat, items }) => (
        <div key={cat}>
          {search.trim() && (
            <div style={{ fontSize: 12, fontWeight: 700, color: '#9CA3AF', textTransform: 'uppercase', letterSpacing: '0.06em', marginBottom: 8, marginTop: 4 }}>
              {cat}
            </div>
          )}
          <div style={{
            display: 'grid',
            gridTemplateColumns: 'repeat(auto-fill, minmax(300px, 1fr))',
            gap: 10,
            marginBottom: 16,
          }}>
            {items.map(item => <MenuItem key={item.name} item={item} />)}
          </div>
        </div>
      ))}

      {filtered.every(g => g.items.length === 0) && (
        <div className="empty-state">
          <div className="empty-state-icon">🔍</div>
          <div className="empty-state-title">No results for "{search}"</div>
        </div>
      )}
    </div>
  )
}
