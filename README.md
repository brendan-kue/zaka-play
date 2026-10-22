# Zaka Play - Android app (v1)

Play games and complete tasks for rewards. Built with Flutter.

## What's in this folder
- `lib/` - the app: splash, onboarding, sign-up, Home (balance + daily streak), Offers, Offer detail,
  Wallet (airtime, Takealot, Checkers, bank cash-outs) and Profile (levels, referral code, FAQ).
- `lib/config.dart` - the settings you change: coin rate, offerwall URL, backend URL, support email, links.
- `firebase/` - the backend: offerwall postback (credits coins), cash-out requests, Firestore security rules.
- `.github/workflows/build.yml` - builds the APK and Play Store bundle for you on GitHub, free.

Right now the app runs in **demo mode**: sample offers, coins saved on the phone. That's perfect for testing
and for showing offerwall networks during their review.

## 1. Get the app on your phone (no coding tools needed)
1. Make a free account at github.com.
2. Create a new **private** repository called `zaka-play`.
3. Click "uploading an existing file", drag in everything from this folder (including the hidden
   `.github` folder), and commit to the `main` branch.
4. Open the **Actions** tab. "Build Android app" runs by itself (about 8-10 minutes).
5. When it's green, open the run and download **zaka-play-android**. Inside is `app-release.apk`.
6. Send the APK to your phone, open it and allow "install unknown apps".

## 2. Make it real
1. **Offerwall**: apply to 2-3 networks (ayeT-Studios, Torox, AdGem, BitLabs for surveys). They give you
   a web offerwall URL. Put it in `offerwallUrl` in `lib/config.dart` with `{uid}` where the user id goes.
2. **Backend**: create a Firebase project (console.firebase.google.com) in region africa-south1,
   enable Authentication (phone or email) and Firestore, then deploy `firebase/`:
   `firebase deploy --only functions,firestore:rules`. Give your network the `postback` URL.
3. Hook the app to Firebase (FlutterFire: `flutterfire configure`) so balances come from Firestore
   instead of the phone. Never let the app add coins itself in the live version.

## 3. Publish on Google Play
1. Play Console account: US$25 once-off, ID in your legal name.
2. Create an upload key once on any PC with Java:
   `keytool -genkey -v -keystore upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload`
   Keep the file and passwords safe forever.
3. In GitHub: Settings > Secrets and variables > Actions, add `KEYSTORE_BASE64` (the .jks file base64-encoded),
   `KEYSTORE_PASSWORD`, `KEY_PASSWORD`, `KEY_ALIAS`. The next build signs the `.aab` with your key.
4. Upload `app-release.aab` to a closed test, get about 12 testers for 14 days, then go to production.
5. You need a privacy policy page, the Data safety form, and a test login for Google's reviewers.

## Rules to stay legit
- Honest listing: no "get rich fast". Say rewards depend on offers and country.
- 18+ only (already in sign-up).
- Only credit coins from the network's postback, and hold new coins as pending for fraud checks.
- Keep minimum cash-outs low but sensible, and watch your cash flow: networks pay you 30-60 days later.
