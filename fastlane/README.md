# App Store submission

Everything App Store Connect asks for, kept next to the code so it changes with
it. The folders follow fastlane's `deliver` layout, so `fastlane deliver` could
upload them, but nothing here needs fastlane: paste the text into App Store
Connect by hand if you prefer.

- `metadata/<locale>/`: name, subtitle, keywords, promotional text,
  description and URLs, in English (`en-US`) and German (`de-DE`).
- `metadata/review_information/`: the App Review notes and the demo account's
  username. Its password never goes in this public repository: enter it in App
  Store Connect.
- `screenshots/en-US/`: iPhone 6.9" (1320×2868) and iPad 13" (2064×2752)
  screenshots, the only sizes App Store Connect requires (it scales them
  down for smaller devices). They show the real app, taken in the simulator by
  `Scripts/store-screenshots.sh` from a local server holding a synthetic
  account. Never take them from a real account.

## Before each submission

1. Reset the reviewers' account on production, from the Rails app:
   `bin/kamal app exec -i --reuse "bin/rails demo:reset"`, and give it the
   password stored in App Store Connect (the account is `appreview`). Reviewers
   may delete it, which is fine: resetting recreates it.
2. Tag `vX.Y.Z` on main and push the tag. Xcode Cloud's "Release" workflow
   (any tag) archives it and uploads it to App Store Connect, where it shows up
   in TestFlight; pushing to main runs the "Development" workflow, which only
   archives. Xcode Cloud sets the build number. By hand instead:
   `Scripts/archive-release.sh vX.Y.Z` and upload from Xcode's Organizer.

Xcode Cloud signs automatically but can't change App IDs, so the developer
portal must already have both App IDs ("Cluster Headache Tracker",
`me.paolino.Cluster-Headache-Tracker`, and "Cluster Headache Tracker Widgets",
`.Widgets`) with App Groups on and `group.me.paolino.Cluster-Headache-Tracker`
assigned. A new capability in the entitlements means enabling it there first.
Name identifiers, keys and profiles "Cluster Headache Tracker" (plus "Staging"
or "Dev"), never Xcode's generated "XC ..." names.

## App information

- Name: Cluster Headache Tracker. Subtitle and the rest: `metadata/`.
- Category: Medical (primary), Health & Fitness (secondary).
- Price: free. No in-app purchases.
- Support URL: https://clusterheadachetracker.com/faq (has the email address
  and the issue tracker). Marketing URL:
  https://clusterheadachetracker.com/cluster-headache-app. Privacy policy:
  https://clusterheadachetracker.com/privacy-policy.
- Copyright: 2026 Carmine Paolino.
- Regulated medical device (App Information, required for the EU/EEA, UK
  and US): No. It's a diary that measures, diagnoses and recommends nothing.
- Export compliance: answered in the build (`ITSAppUsesNonExemptEncryption`
  is false: only the system's HTTPS).
- Content rights: the app shows no third-party content.

## App Privacy ("nutrition label")

Data used to track you: none. No data is shared with data brokers or used for
advertising. Answer "Yes, we collect data" and declare:

| Data type | Linked to the user | Tracking | Purposes | What it is |
|---|---|---|---|---|
| Health & Fitness › Health | Yes | No | App Functionality | Attacks, intensity, medications and doses, triggers, notes, barometric pressure |
| User Content › Photos or Videos | Yes | No | App Functionality | Photos attached to a log |
| User Content › Other User Content | Yes | No | App Functionality, Other (product feedback) | Free-text notes, feedback survey answers |
| Identifiers › User ID | Yes | No | App Functionality | The username |
| Usage Data › Product Interaction | No | No | Analytics | Page views counted by our self-hosted Plausible, without cookies or stored IP addresses |
| Diagnostics › Other Diagnostic Data | Yes | No | App Functionality | Server error reports to our self-hosted Bugsink: the failed request, the account number and username; a failed save can include its health details |

Not collected: contact info (no email, name or phone), location, financial
info, contacts, browsing or search history, purchases, sensitive info beyond
health, crash data from the app (it has no crash SDK; Apple's own crash
reports don't count), device or advertising identifiers.

"Linked to the user" is the conservative answer: there's no email or real
name, but everything belongs to an account. `Cluster Headache
Tracker/PrivacyInfo.xcprivacy` declares the same; keep both in step with the
Rails app's privacy policy.

## Age rating

No violence, sexual content, profanity, gambling, contests, user-to-user
communication, user-generated content others can see, or unrestricted web
access (external links open in Safari's view controller, there's no address
bar). The one topic to declare is medical: people record their own
medications and treatments, though the app gives no medical information or
advice. Answer the medical or treatment question honestly as present but
infrequent; answer No to Health or Wellness Topics (it recommends no
self-care) and to every feature in step 1. App Store Connect computes 13+;
override it to 16+, the minimum age the privacy policy sets.

## Guidelines worth knowing

- 1.4.1 (medical apps): the app measures nothing and claims nothing; the
  description, Settings › About and the sign-up page say it's a tracking tool,
  not medical advice.
- 4.2 (minimum functionality): the review notes list the native features
  (widgets, Live Activity, App Intents, quick actions, Quick Look) beyond the
  web content.
- 5.1.1(v): accounts can be deleted in the app (Account › Delete account).
- 5.1.1(ix): apps in highly regulated fields such as healthcare, or that need
  sensitive data, should come from a legal entity rather than an individual.
  The developer account is an organization (PlentyLabs UG (haftungsbeschränkt)
  & Co. KG, team JPL7999US3), so this is covered.
- 3.1.1: the GitHub Sponsors links are hidden in the app (the server leaves
  them out for every iOS build); donations would have to use In-App Purchase.
