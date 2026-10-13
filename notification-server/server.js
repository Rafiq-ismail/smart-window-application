require("dotenv").config();

const express = require("express");

const {
  initializeApp,
  cert,
} = require("firebase-admin/app");

const {
  getMessaging,
} = require("firebase-admin/messaging");

const app = express();

app.use(express.json());
const verifyApiKey = (req, res, next) => {
  const apiKey = req.headers["x-api-key"];

  if (!apiKey || apiKey !== process.env.NOTIFICATION_API_KEY) {
    return res.status(401).json({
      success: false,
      message: "Unauthorized",
    });
  }

  next();
};
const serviceAccount = require("./service-account.json");

initializeApp({
  credential: cert(serviceAccount),
  projectId: "smartwindow-131e5",
});

// Test route
app.get("/", (req, res) => {
  res.send("SmartWindow Notification Server is running.");
});

// Send push notification
app.post("/send-notification", verifyApiKey, async (req, res) => {
  try {
    const { title, body, type } = req.body;

    if (!title || !body) {
      return res.status(400).json({
        success: false,
        message: "title and body are required",
      });
    }

    const message = {
      notification: {
        title: title,
        body: body,
      },

      data: {
        type: type || "general",
      },

      topic: "smartwindow_alerts",
    };

    const response = await getMessaging().send(message);

    console.log("Notification sent:", response);

    return res.status(200).json({
      success: true,
      message: "Notification sent successfully",
    });
  } catch (error) {
    console.error("Notification error:", error);

    return res.status(500).json({
      success: false,
      message: error.message,
    });
  }
});

// Direct device notification test
app.post(
  "/send-token-notification",
  verifyApiKey,
  async (req, res) => {
  try {
    const { token, title, body } = req.body;

    if (!token || !title || !body) {
      return res.status(400).json({
        success: false,
        message: "token, title and body are required",
      });
    }

    const message = {
      token: token,

      notification: {
        title: title,
        body: body,
      },

      data: {
        type: "direct_test",
      },
    };

    const response = await getMessaging().send(message);

    console.log("Direct notification sent:", response);

    return res.status(200).json({
      success: true,
      message: "Direct notification sent successfully",
      response: response,
    });
  } catch (error) {
    console.error("Direct notification error:", error);

    return res.status(500).json({
      success: false,
      message: error.message,
      code: error.code || "unknown",
    });
  }
});

const PORT = process.env.PORT || 3000;

app.listen(PORT, () => {
  console.log(
    `SmartWindow Notification Server running on port ${PORT}`
  );
});