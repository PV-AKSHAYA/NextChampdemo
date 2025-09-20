const admin = require('firebase-admin');
const serviceAccount = require("./serviceAccountKey.json");

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const uid = "P0jfW4Z5ekUmTNuGAcUUG6UpZ723";  // Replace with actual user UID

admin.auth().setCustomUserClaims(uid, { admin: true })
  .then(() => {
    console.log('Custom claim "admin" added to user:', uid);
  })
  .catch(error => {
    console.error('Error setting custom claims:', error);
  });


//   admin.initializeApp({
//   credential: admin.credential.cert({
//     projectId: "nextchamp-3d291",
//     clientEmail: "firebase-adminsdk-fbsvc@nextchamp-3d291.iam.gserviceaccount.com",
//     privateKey: "-----BEGIN PRIVATE KEY-----\nMIIEvgIBADANBgkqhkiG9w0BAQEFAASCBKgwggSkAgEAAoIBAQCJN/NM85TU64Gf\nfGlC75YCtWExp82qg+NHRRoT6dfjkjorWX43X2p9WTPUKzeXbc1YTOrYLtVS8nAi\nTZou8hus2FkKlCp2sfRAOw038xd7Z5x0UL9JdyTY4j2W/Wj/4+SnWwRUbZMirNwr\n5syU2FxfHqIOPdrRhWyVL834qENJgb2g9JC7gjE3D3QfuhcQJc5muGveBISguYpA\nI7ZPK4afl7x6h4ZQdH1AO0L+JJesW23+xAe7btdJZD0JsFGWKs7ZnAkptoY8U1t4\nGT9a66bW9bz4zxulFortYtXrS2qA2Lsuf08o2SLEZekel/ziAW/T8NORGIwjcFtN\ntXJrvqHtAgMBAAECggEAFIno43hEKziS/t2+3bOB1ybyBN4ylRbHoqfPtvJWC6yc\nA1gSYdRo2plK/jN3zzUyushMkI42BQPfz+qgrO01QkJh1YkG8BxDzIdqO5kpxyFj\nlC9v6l2oiMQYZuzIViD03S3s8Hw0PUj1babOsWrPLLenlw0gHyNi9NOid1ksNSi7\nrnvoAIQ5YbBuvoa6OHbkiP3iJcDAhv8ROHMrL0AnspOwwohUXmLV4Qj4FATGGQjB\nQQaEwM84S7mRjmpMJUvdhzGbjRT4KxhnultqR5ZHOiaSQfJxR3zAK11Jws8lQ4bZ\neutUx/jcA1ZZBNgMGsIOOHD6ZQuw4KAxx2pvZqW7mwKBgQC9lhrlhioZ1jXl2ddV\n8wg3Mb+cpY5cWi8iMZc/laq7gKqkJuEoYZ+8cdjPykOIlXatL5LmCuIIvkKhKKqz\nPfIHIcAdzd1NCzqEg+mnCgIqxFxfkafm9Qukmxf6u9Ax9MOiIU1UiffDY5jEnban\nozC23p5J4jJKvl8zyHFZHm5mlwKBgQC5SY82xyfx2lY/6ti6AqMXNBLdI8uUO6SC\n0aq7ouGMy3UUF9vlDvAzT5HGNHhd/8nTkN1kQUJqBMlkqGhyZQJVQSppyA9Q9vAH\nQLmh3hiboD8i59vsNGS8K+rrd7HQcPA8RpMiKbaqO5B4cJ61U722FnKTjBwVNDzD\n5E5mIT6wGwKBgQCwzNQGaijG8XJQCOf8+mkV9+nmLqplS6Ea9T5EiNGwjFwWOz/M\nhcYOWelEVi7GqAQFnBEVQN7sImpGmoMeJs2Xgw0DfmE7oRYQUGhMY1QECBzQ7yey\nhaE2/3/MTuvoOodaok3YYdXRvAbSjPWyvcgHMfJRmoUmGQT1aJ7z6iIwvwKBgBA1\nXB7ZmyfwBp1+yMi01FmCR6gqqnNkKEb9Wmchn4N2hN5mG+lUvjRu4HyrOGBYsOoe\nAQ/1GX82vftdNA3Vwjd9BN3OD3DwuRyZT+PWDucGRJ+kErv99VX0rY89oENwrcNI\nFTTm20DXBxNSHsAT/EOCgTFhD0/Xiv1D6ovKmrZDAoGBAKFea6Vr4KM2d2JWuZjZ\nB6K/aj5IZt1uZrJBepfFA+XYQmUpYZdKDr9XlXlNTv5+iNDWefPWTwHYKdp5sO/u\ne9cmSPcKlqVsePO0RWFEm/idER3naCOt6lhUc/DZFuwyAJaDRhjnZo4DijMFv7mh\nTTBjdrnA2ix5kfZIhD/A6xMr\n-----END PRIVATE KEY-----\n",
// .replace(/\\n/g, '\n'),
//   }),
// });
