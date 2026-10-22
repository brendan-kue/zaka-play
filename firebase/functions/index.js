/**
 * Zaka Play backend (Firebase Cloud Functions + Firestore).
 *
 * 1. postback  - your offerwall network calls this URL when a user completes an offer.
 *                It credits coins to users/{uid}. Duplicate transaction ids are ignored.
 * 2. cashout   - the app calls this to request a payout. Coins are deducted and a
 *                request is saved in cashouts/ for you to pay and mark as paid.
 *
 * Set the shared secret your network gives you:
 *   firebase functions:secrets:set POSTBACK_SECRET
 * Most networks sign postbacks with a hash; check their docs and adapt verify() below.
 */
const { onRequest, onCall, HttpsError } = require('firebase-functions/v2/https');
const { defineSecret } = require('firebase-functions/params');
const admin = require('firebase-admin');
const crypto = require('crypto');

admin.initializeApp();
const db = admin.firestore();
const POSTBACK_SECRET = defineSecret('POSTBACK_SECRET');
const COINS_PER_RAND = 500;
const REGION = 'africa-south1';

function verify(q, secret) {
  // Example: network sends ?uid=..&amount=..&tx=..&sig=sha256(uid+amount+tx+secret)
  const expected = crypto.createHash('sha256').update(`${q.uid}${q.amount}${q.tx}${secret}`).digest('hex');
  return typeof q.sig === 'string' && q.sig.length === expected.length &&
    crypto.timingSafeEqual(Buffer.from(q.sig), Buffer.from(expected));
}

exports.postback = onRequest({ region: REGION, secrets: [POSTBACK_SECRET] }, async (req, res) => {
  const q = req.query;
  if (!q.uid || !q.amount || !q.tx) return res.status(400).send('missing params');
  if (!verify(q, POSTBACK_SECRET.value())) return res.status(403).send('bad signature');

  const coins = parseInt(q.amount, 10);
  if (!Number.isFinite(coins) || coins === 0) return res.status(400).send('bad amount');

  const txRef = db.collection('transactions').doc(String(q.tx));
  const userRef = db.collection('users').doc(String(q.uid));
  try {
    await db.runTransaction(async (t) => {
      const tx = await t.get(txRef);
      if (tx.exists) return; // already credited
      t.set(txRef, { uid: q.uid, coins, offer: q.offer || null, at: admin.firestore.FieldValue.serverTimestamp() });
      // negative amounts are chargebacks from the network
      t.set(userRef, {
        available: admin.firestore.FieldValue.increment(coins),
        lifetime: admin.firestore.FieldValue.increment(Math.max(coins, 0)),
      }, { merge: true });
    });
    res.status(200).send('1'); // most networks expect 1 or OK
  } catch (e) {
    console.error(e);
    res.status(500).send('error');
  }
});

exports.cashout = onCall({ region: REGION }, async (request) => {
  if (!request.auth) throw new HttpsError('unauthenticated', 'Sign in first');
  const uid = request.auth.uid;
  const { method, rand, destination } = request.data || {};
  const mins = { airtime: 10, takealot: 50, checkers: 50, bank: 100 };
  if (!mins[method] || !Number.isInteger(rand) || rand < mins[method] || !destination) {
    throw new HttpsError('invalid-argument', 'Check the amount and details');
  }
  const cost = rand * COINS_PER_RAND;
  const userRef = db.collection('users').doc(uid);
  await db.runTransaction(async (t) => {
    const u = await t.get(userRef);
    const available = (u.exists && u.data().available) || 0;
    if (available < cost) throw new HttpsError('failed-precondition', 'Not enough coins');
    t.update(userRef, { available: admin.firestore.FieldValue.increment(-cost) });
    t.set(db.collection('cashouts').doc(), {
      uid, method, rand, cost, destination, status: 'processing',
      at: admin.firestore.FieldValue.serverTimestamp(),
    });
  });
  return { ok: true };
});
