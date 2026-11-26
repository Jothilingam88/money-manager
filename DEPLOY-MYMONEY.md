# MyMoney — Supabase + GitHub Pages setup

This folder contains:
- `index.html` — the converted MyMoney app
- `supabase-schema.sql` — private database table and Row Level Security (RLS) policies

The app keeps the existing dashboard, transactions (add/edit/delete/search/filter), reports and charts, budgets, recurring entries, CSV import/export, currency/theme settings, and master reset. It uses Supabase Auth and a cloud JSON record for your account. Local browser storage is only a cache and a first-login migration source; the Supabase record is the cloud source of truth.

## 1. Create the private Supabase project

1. Create a Supabase project and keep its database password private.
2. In **Authentication / Providers / Email** (the exact menu labels may vary), turn **Allow new users to sign up** off. This is important: the app has sign-in only, no registration screen.
3. In **Authentication / Users**, add one user for your own email and set a strong, unique password. Confirm the email if the dashboard asks you to.
4. In **Authentication / URL Configuration**, set the Site URL to your published GitHub Pages URL. Add that exact URL (including the repository path, if applicable) to the allowed redirect URLs.

## 2. Create the database and security rules

1. Open **SQL Editor** in Supabase.
2. Open `supabase-schema.sql`, copy all of it, paste into a new SQL query and run it.
3. The script creates one row per authenticated user and enables RLS. The policies only permit a user to read, insert, update or delete the row whose `user_id` equals their authenticated Supabase user ID.
4. The script also tries to add the table to the `supabase_realtime` publication so open devices can receive changes. If your project doesn't allow this or realtime isn't enabled, check Database / Publications and enable `mymoney_data` in `supabase_realtime`.

## 3. Add your Supabase project keys to the HTML

1. In Supabase open **Project Settings / API** (or API Keys).
2. Copy the **Project URL**.
3. Copy the **publishable key** or legacy **anon public key**. This key is intended for browser apps and is not a secret; RLS is what protects your records.
4. Open `index.html` in a text editor and find these two lines near the start of the main script:

   ```js
   const SUPABASE_URL = "YOUR_SUPABASE_PROJECT_URL";
   const SUPABASE_ANON_KEY = "YOUR_SUPABASE_ANON_PUBLIC_KEY";
   ```

5. Replace the placeholder strings with your Project URL and publishable/anon key. Keep the quotation marks.

**Never put a `service_role` key or Supabase secret key in `index.html` or any GitHub Pages file.** Those keys bypass RLS and must remain server-side. Do not paste any secret key into ChatGPT or a public repository.

## 4. Deploy on GitHub Pages

1. Download/use the edited `index.html` and replace the old `index.html` in the repository's publishing folder.
2. If your Pages source is `main` + `/(root)`, put it in the repository root. If it publishes from `/docs`, put it in that folder instead.
3. Commit the change and push/upload it to GitHub.
4. Open the repository's **Settings / Pages** and verify the selected branch and folder match where `index.html` was uploaded.
5. Wait for the Pages deployment to finish, then open the published site and sign in with the one user created in Supabase.

GitHub Pages serves the HTML publicly, but it does not make your financial records public: the database is protected by Supabase Auth and RLS. Do not include real transaction data in the repository.

## 5. First sign-in and migration

- On the first sign-in, if the cloud row does not exist, the app uploads any existing local MyMoney transactions, budgets and preferences from that browser to your account.
- If a cloud row already exists, the app loads it and replaces the local cache with the cloud version.
- On other devices, open the same published URL and sign in with the same account. Changes are saved to Supabase; live updates between open tabs/devices require Realtime publication enabled.
- Sign out when using a shared computer. The app clears its local MyMoney cache on sign-out.

## 6. Important security and data notes

- Use a strong, unique password and enable email confirmation in Supabase.
- The browser's local cache is not encrypted against someone who can access your unlocked browser profile. Use your device lock and sign out on shared devices.
- Export CSV periodically as a personal backup. Supabase project backups depend on your project plan and settings.
- The app does not currently use a server-side API. The signed-in Supabase client sends the user's JWT, and Postgres RLS checks ownership for every database operation.
- If cloud sync fails, the app shows a sync error. Check your internet connection, Supabase project URL/key, table creation, and RLS policies before continuing to enter important records.

## Troubleshooting

**“Finish Supabase setup”** — the URL or public key placeholders were not replaced.

**Sign-in fails** — verify the exact email/password, that the user exists in Supabase Auth, and that email confirmation is complete.

**Cloud data could not load** — run the SQL file, verify the `mymoney_data` table and RLS policies, and check the browser console for the Supabase error.

**Changes don't appear on another device immediately** — refresh/sign in again, and verify `mymoney_data` is included in the `supabase_realtime` publication.
