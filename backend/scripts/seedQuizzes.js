const mongoose = require("mongoose");
const fs = require("fs");
const path = require("path");

require("dotenv").config();

const Quiz = require("../src/models/Quiz");

async function seed() {
  try {
    await mongoose.connect(process.env.MONGODB_URI);

    console.log("✅ MongoDB Connected");

    const filePath = path.join(__dirname, "../data", "quizzes.json");

    if (!fs.existsSync(filePath)) {
      console.log("⚠️  Missing file: quizzes.json");
      process.exit(1);
    }

    const data = JSON.parse(fs.readFileSync(filePath, "utf8"));

    console.log(`\n📝 Seeding quizzes.json (${data.length} questions)`);

    let inserted = 0;
    let updated = 0;

    for (const item of data) {
      const result = await Quiz.findOneAndUpdate(
        {
          question: item.question,
          classLevel: item.classLevel,
          category: item.category,
        },
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
