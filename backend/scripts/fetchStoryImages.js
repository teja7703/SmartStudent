const fs = require("fs");
const path = require("path");

const file = path.join(__dirname, "../data/stories.json");

const sleep = (ms) => new Promise((r) => setTimeout(r, ms));

async function fetchImage(name) {
  const title = encodeURIComponent(name);
  for (let attempt = 0; attempt < 3; attempt++) {
    try {
      const res = await fetch(
        `https://en.wikipedia.org/api/rest_v1/page/summary/${title}`,
        { headers: { "User-Agent": "SmartStudent/1.0 (education app)" } }
      );
      if (!res.ok) {
        await sleep(1500);
        continue;
      }
      const j = await res.json();
      return j.thumbnail?.source || j.originalimage?.source || "";
    } catch (_) {
      await sleep(1500);
    }
  }
  return "";
}

async function run() {
  const stories = JSON.parse(fs.readFileSync(file, "utf8"));

  for (const s of stories) {
    // Keep an already-resolved image; only fetch when missing.
    if (s.imageUrl && s.imageUrl.startsWith("http")) {
      console.log(`${s.name} -> kept`);
      continue;
    }
    const url = await fetchImage(s.name);
    s.imageUrl = url;
    console.log(`${s.name} -> ${url ? "ok" : "MISSING"}`);
    await sleep(800);
  }

  fs.writeFileSync(file, JSON.stringify(stories, null, 2) + "\n");
  console.log("\n✅ Updated stories.json with image URLs");
}

run();
