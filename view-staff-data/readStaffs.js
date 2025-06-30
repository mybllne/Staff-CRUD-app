const admin = require('firebase-admin');
const fs = require('fs');

// Initialize Firebase Admin SDK
const serviceAccount = require('./serviceAccountKey.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const db = admin.firestore();

async function readStaffs() {
  try {
    const snapshot = await db.collection('staffs').orderBy('createdAt', 'desc').get();

    if (snapshot.empty) {
      console.log('No staff found.');
      return;
    }

    const staffList = [];

    snapshot.forEach(doc => {
      const data = doc.data();
      const line = `👤 ${data.name} | ID: ${data.id} | Age: ${data.age}`;
      staffList.push(line);
      console.log(line);
    });

    // Save to a text file
    fs.writeFileSync('staff_list.txt', staffList.join('\n'));
    console.log('\n✅ Staff list saved to staff_list.txt');
    
  } catch (error) {
    console.error('❌ Error reading staff data:', error);
  }
}

readStaffs();
