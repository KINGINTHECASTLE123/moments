const fs = require("fs");
const path = require("path");
const admin = require("firebase-admin");

const projectId = process.env.FIREBASE_PROJECT_ID || "moments-e2a58";
const bucketName =
    process.env.FIREBASE_STORAGE_BUCKET || "moments-e2a58.firebasestorage.app";

function getCredential() {
    // 1. Raw JSON string from env (for CI/CD like GitHub Actions)
    if (process.env.FIREBASE_SERVICE_ACCOUNT_JSON) {
        const serviceAccount = JSON.parse(process.env.FIREBASE_SERVICE_ACCOUNT_JSON);
        return admin.credential.cert(serviceAccount);
    }

    // 2. File path from env or local fallback (for local development)
    const serviceAccountPath =
        process.env.GOOGLE_APPLICATION_CREDENTIALS ||
        path.resolve(process.cwd(), "serviceAccountKey.json");

    if (!fs.existsSync(serviceAccountPath)) {
        throw new Error(
            "No Firebase credentials found.\n" +
            "Set FIREBASE_SERVICE_ACCOUNT_JSON (raw JSON) or GOOGLE_APPLICATION_CREDENTIALS (file path),\n" +
            "or place serviceAccountKey.json in the firebase-tools/ folder."
        );
    }

    return admin.credential.cert(require(serviceAccountPath));
}

function loadSeedData() {
    const seedPath = path.resolve(__dirname, "food_seed.json");
    return JSON.parse(fs.readFileSync(seedPath, "utf8"));
}

function toFirestoreDish(dish) {
    return {
        name: dish.name,
        pairing: dish.pairing,
        tags: dish.tags,
        imageURL: `gs://${bucketName}/${dish.imagePath}`,
        ingredients: dish.ingredients,
        instructions: dish.instructions,
        category: dish.category,
        sortOrder: dish.sortOrder
    };
}

async function main() {
    admin.initializeApp({
        credential: getCredential(),
        projectId,
        storageBucket: bucketName
    });

    const db = admin.firestore();
    const dishes = loadSeedData();

    const writes = dishes.map(async (dish) => {
        const docRef = db.collection("dishes").doc(dish.id);
        await docRef.set(toFirestoreDish(dish), { merge: true });
        console.log(`Seeded ${dish.id}`);
    });

    await Promise.all(writes);
    console.log(`Done. Seeded ${dishes.length} dishes.`);
}

main().catch((error) => {
    console.error(error.message);
    process.exit(1);
});
