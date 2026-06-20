const mongoose = require("mongoose");
const fs = require("fs");
const path = require("path");

require("dotenv").config();

const Career = require("../src/models/Career");

async function seed() {
  try {
    await mongoose.connect(process.env.MONGODB_URI);

    console.log("✅ MongoDB Connected");

    const filePath = path.join(__dirname, "../data", "careers.json");

    if (!fs.existsSync(filePath)) {
      console.log("⚠️  Missing file: careers.json");
      process.exit(1);
    }

    const data = JSON.parse(fs.readFileSync(filePath, "utf8"));

    console.log(`\n💼 Seeding careers.json (${data.length} careers)`);

    let inserted = 0;
    let updated = 0;

    for (const item of data) {
      const result = await Career.findOneAndUpdate(
        { careerName: item.careerName, category: item.category },
        { $set: item },
        {
          upsert: true,
          returnDocument: "after",
          includeResultMetadata: true,
        }
      );

      if (result.lastErrorObject?.updatedExisting) {
        updated += 1;
      } else {
        inserted += 1;
      }
    }

    console.log(
      `\n✅ Done. Inserted ${inserted}, Updated ${updated}, Total ${data.length}`
    );

    process.exit();
  } catch (error) {
    console.error("❌ Error:", error.message);
    process.exit(1);
  }
}

seed();
