const fs = require("fs");
const path = require("path");
const admin = require("firebase-admin");

const projectId = process.env.FIREBASE_PROJECT_ID || "moments-e2a58";
const bucketName =
    process.env.FIREBASE_STORAGE_BUCKET || "moments-e2a58.firebasestorage.app";

function getCredential() {
    const serviceAccountPath =
        process.env.GOOGLE_APPLICATION_CREDENTIALS ||
        path.resolve(process.cwd(), "serviceAccountKey.json");

    if (!fs.existsSync(serviceAccountPath)) {
        throw new Error(
            "Missing service account key. Set GOOGLE_APPLICATION_CREDENTIALS or add serviceAccountKey.json in the firebase-tools folder."
        );
    }

    return admin.credential.cert(require(serviceAccountPath));
}

function loadSeedData() {
    const seedPath = path.resolve(__dirname, "drinks_seed.json");
    return JSON.parse(fs.readFileSync(seedPath, "utf8"));
}

function toFirestoreDrink(drink) {
    return {
        name: drink.name,
        pairing: drink.pairing,
        tags: drink.tags,
        imageURL: `gs://${bucketName}/${drink.imagePath}`,
        ingredients: drink.ingredients,
        instructions: drink.instructions,
        category: drink.category,
        sortOrder: drink.sortOrder
    };
}

async function main() {
    admin.initializeApp({
        credential: getCredential(),
        projectId,
        storageBucket: bucketName
    });

    const db = admin.firestore();
    const drinks = loadSeedData();

    const writes = drinks.map(async (drink) => {
        const docRef = db.collection("drinks").doc(drink.id);
        await docRef.set(toFirestoreDrink(drink), { merge: true });
        console.log(`Seeded ${drink.id}`);
    });

    await Promise.all(writes);
    console.log(`Done. Seeded ${drinks.length} drinks.`);
}

main().catch((error) => {
    console.error(error.message);
    process.exit(1);
});
