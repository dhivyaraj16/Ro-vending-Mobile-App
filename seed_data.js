// Run this script once to add sample RO machines to Firestore
// You can run it from Firebase Console > Firestore > Add documents

// Sample machines data - Add these documents to 'machines' collection

const machines = [
  {
    id: "machine001",
    name: "RO Station - Anna Nagar",
    address: "123, Anna Nagar East, Chennai - 600102",
    latitude: 13.0891,
    longitude: 80.2126,
    isOnline: true,
    isAvailable: true,
    pricePerLitre: 1.0,
    totalWaterDispensed: 1250.5,
    totalUsers: 340,
    machineCode: "RO-AN-001",
    lastMaintenance: new Date("2025-01-15"),
  },
  {
    id: "machine002",
    name: "RO Station - T Nagar",
    address: "45, Pondy Bazaar, T Nagar, Chennai - 600017",
    latitude: 13.0418,
    longitude: 80.2341,
    isOnline: true,
    isAvailable: true,
    pricePerLitre: 1.0,
    totalWaterDispensed: 2100.0,
    totalUsers: 520,
    machineCode: "RO-TN-001",
    lastMaintenance: new Date("2025-01-20"),
  },
  {
    id: "machine003",
    name: "RO Station - Adyar",
    address: "78, Gandhi Nagar, Adyar, Chennai - 600020",
    latitude: 13.0067,
    longitude: 80.2570,
    isOnline: false,
    isAvailable: false,
    pricePerLitre: 1.0,
    totalWaterDispensed: 890.0,
    totalUsers: 210,
    machineCode: "RO-AD-001",
    lastMaintenance: new Date("2024-12-10"),
  },
  {
    id: "machine004",
    name: "RO Station - Velachery",
    address: "12, Velachery Main Road, Chennai - 600042",
    latitude: 12.9793,
    longitude: 80.2209,
    isOnline: true,
    isAvailable: true,
    pricePerLitre: 0.75,
    totalWaterDispensed: 3200.0,
    totalUsers: 780,
    machineCode: "RO-VL-001",
    lastMaintenance: new Date("2025-02-01"),
  },
];

// To add via Firebase Admin SDK:
/*
const admin = require('firebase-admin');
admin.initializeApp();
const db = admin.firestore();

machines.forEach(async (machine) => {
  await db.collection('machines').doc(machine.id).set(machine);
  console.log(`Added: ${machine.name}`);
});
*/
