# Mallards Training App — Setup Guide

## What You're Getting
- Employee training portal with role-specific tracks
- Checklist + video modules with progress tracking
- Manager dashboard to see all employee progress
- Admin panel to update content, videos, and employee accounts — no coding needed

---

## Step 1: Create Your Supabase Project

1. Go to [supabase.com](https://supabase.com) and sign in (free account is fine)
2. Click **New Project** → name it "Mallards Training"
3. Choose a region (US East is fine) and set a database password → save it
4. Wait ~2 minutes for the project to spin up

---

## Step 2: Run the Database Schema

1. In your Supabase project, go to **SQL Editor** (left sidebar)
2. Click **New Query**
3. Open the file `supabase-schema.sql` from this folder
4. Paste the entire contents into the editor
5. Click **Run** — this creates all tables and loads all training content

---

## Step 3: Get Your API Keys

1. In Supabase, go to **Settings → API**
2. Copy:
   - **Project URL** (looks like `https://xxxxx.supabase.co`)
   - **anon public** key (long string starting with `eyJ...`)

---

## Step 4: Configure the App

1. In the `training-app` folder, copy `.env.example` and rename it `.env`
2. Open `.env` and fill in your values:

```
VITE_SUPABASE_URL=https://your-project.supabase.co
VITE_SUPABASE_ANON_KEY=your-anon-key-here
```

---

## Step 5: Install & Run Locally

Make sure you have [Node.js](https://nodejs.org) installed (v18+), then:

```bash
cd training-app
npm install
npm run dev
```

Open your browser to `http://localhost:5173`

---

## Step 6: Create Your First Admin Account

1. In Supabase, go to **Authentication → Users → Add User**
2. Enter your email and a password
3. After creating, go to **Table Editor → profiles**
4. Find your record and set `role` to `admin`
5. Sign in at your local app — you'll have full access

---

## Step 7: Add Employees

**Option A — You create accounts:**
1. Go to Supabase → Authentication → Users → Add User
2. Create their account with a temporary password
3. In the Admin Panel → Employees tab, assign them a training track and set their role

**Option B — Self-signup (optional):**
- Enable email signups in Supabase → Authentication → Providers
- New employees sign up, then you assign their track in the Admin Panel

---

## Step 8: Add Your Training Videos

When you record training videos:
1. Upload them to **YouTube** (unlisted is fine)
2. Click **Share → Embed** on the video → copy the `src` URL (e.g. `https://www.youtube.com/embed/VIDEO_ID`)
3. In the app, go to **Admin → Training Content**
4. Select the track, then the module, then click **Edit** on any video item
5. Paste the embed URL and save — it updates instantly for everyone

---

## Step 9: Deploy to Netlify

1. Push this folder to a GitHub repo
2. Go to [netlify.com](https://netlify.com) → **Add New Site → Import from Git**
3. Connect your repo, set:
   - Build command: `npm run build`
   - Publish directory: `dist`
4. Add your environment variables under **Site Settings → Environment Variables**:
   - `VITE_SUPABASE_URL`
   - `VITE_SUPABASE_ANON_KEY`
5. Deploy — your app is live!

---

## Training Tracks Included

| Track | Positions |
|---|---|
| FOH Server | Servers |
| FOH Support Staff | Hosts, Takeout, Food Runners |
| Bar | Bartenders |
| Kitchen | Line cooks, prep cooks |
| Management | Managers |

Each track has pre-built modules pulled from your Employee Handbook, with placeholder video slots ready for your recordings.

---

## Updating Content (No Code Needed)

- **Add/edit modules or checklist items:** Admin Panel → Training Content
- **Swap a video:** Edit the video item, paste new YouTube embed URL
- **Assign an employee to a different track:** Admin Panel → Employees → Edit
- **Promote someone to manager or admin:** Same place, change their Role

---

## Questions?

Ask Claude in Cowork mode — it has full context on this project and can help you add features, troubleshoot, or customize anything.
