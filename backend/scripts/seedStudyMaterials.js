const mongoose = require("mongoose");
const fs = require("fs");
const path = require("path");

require("dotenv").config();

const StudyMaterial = require(
  "../src/models/StudyMaterial"
);

async function seed() {
  try {
    await mongoose.connect(
      process.env.MONGODB_URI
    );

    console.log(
      "✅ MongoDB Connected"
    );

    const files = [
      "class10_math_english.json",
      "class10_math_telugu.json",
    ];

    let totalSeeded = 0;

    for (const fileName of files) {
      const filePath = path.join(
        __dirname,
        "../data",
        fileName
      );

      if (!fs.existsSync(filePath)) {
        console.log(`⚠️  Skipped missing file: ${fileName}`);
        continue;
      }

      const data = JSON.parse(
        fs.readFileSync(filePath, "utf8")
      );

      console.log(`\n📘 Seeding ${fileName} (${data.length} records)`);

      for (let index = 0; index < data.length; index++) {
        const item = data[index];

        const result =
          await StudyMaterial.findOneAndUpdate(
            {
              chapter: item.chapter,
              subject: item.subject,
              language: item.language,
            },
            { $set: { ...item, order: index } },
            {
              upsert: true,
              returnDocument: "after",
              includeResultMetadata: true,
            }
          );

        if (result.lastErrorObject?.updatedExisting) {
          console.log(`Updated ${item.chapter}`);
        } else {
          console.log(`Inserted ${item.chapter}`);
        }
      }

      totalSeeded += data.length;
    }

    console.log(
      `\n✅ Seeded ${totalSeeded} records`
    );

    process.exit();
  } catch (error) {
    console.error(
      "❌ Error:",
      error.message
    );
    process.exit(1);
  }
}

seed();