const mongoose = require("mongoose");
const fs = require("fs");
const path = require("path");

require("dotenv").config();

const Story = require("../src/models/Story");

async function seed() {
  try {
    await mongoose.connect(process.env.MONGODB_URI);

    console.log("✅ MongoDB Connected");

    const filePath = path.join(__dirname, "../data", "stories.json");

    if (!fs.existsSync(filePath)) {
      console.log("⚠️  Missing file: stories.json");
      process.exit(1);
    }

    const data = JSON.parse(fs.readFileSync(filePath, "utf8"));

    console.log(`\n🌟 Seeding stories.json (${data.length} stories)`);

    // Clean reseed so the collection always matches the curated file.
    await Story.deleteMany({});
    const result = await Story.insertMany(data);

    console.log(`\n✅ Done. Inserted ${result.length} stories`);

    process.exit();
  } catch (error) {
    console.error("❌ Error:", error.message);
    process.exit(1);
  }
}

seed();
