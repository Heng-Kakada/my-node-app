const express = require("express");
const app = express();
const PORT = process.env.PORT || 3000;

// Simple middleware to log requests
app.use((req, res, next) => {
  console.log(`${new Date().toISOString()} - ${req.method} ${req.url}`);
  next();
});

// Main Route
app.get("/", (req, res) => {
  res.json({
    status: "success",
    message: "Hello World V3",
    version: "3.0.0",
    node_version: process.version,
  });
});

/**
 * HEALTH CHECK ENDPOINT
 * This is what the Jenkins deploy script looks for.
 */
app.get("/health", (req, res) => {
  // In a real app, you would also check DB connectivity here
  res.status(200).send("OK");
});

const server = app.listen(PORT, () => {
  console.log(`Application is running on port ${PORT}`);
});

/**
 * GRACEFUL SHUTDOWN
 * Big companies ensure no requests are dropped during a rollout.
 */
process.on("SIGTERM", () => {
  console.info("SIGTERM signal received. Closing HTTP server...");
  server.close(() => {
    console.log("HTTP server closed.");
    process.exit(0);
  });
});
