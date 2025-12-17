const os = require("os");

const originalNetworkInterfaces = os.networkInterfaces.bind(os);

os.networkInterfaces = function patchedNetworkInterfaces() {
  try {
    return originalNetworkInterfaces();
  } catch {
    return {};
  }
};

